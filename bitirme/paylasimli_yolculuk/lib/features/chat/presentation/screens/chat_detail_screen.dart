import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../rides/domain/entities/ride_entity.dart';
import '../../domain/entities/chat_entity.dart';
import '../providers/chat_provider.dart';

/// Gerçek zamanlı canlı konum paylaşımı için güzergah ara noktaları (İstanbul rotası).
const List<RideLocationPoint> _liveRouteWaypoints = [
  RideLocationPoint(
    name: 'Kadıköy Rıhtım Durağı',
    address: 'Kadıköy/İstanbul',
    lat: 40.9901,
    lng: 29.0234,
  ),
  RideLocationPoint(
    name: 'Söğütlüçeşme Metrobüs',
    address: 'Kadıköy/İstanbul',
    lat: 40.9958,
    lng: 29.0376,
  ),
  RideLocationPoint(
    name: 'Acıbadem Köprüsü',
    address: 'Üsküdar/İstanbul',
    lat: 41.0085,
    lng: 29.0450,
  ),
  RideLocationPoint(
    name: '15 Temmuz Şehitler Köprüsü',
    address: 'Boğaziçi/İstanbul',
    lat: 41.0451,
    lng: 29.0342,
  ),
  RideLocationPoint(
    name: 'Mecidiyeköy Metrobüs Durağı',
    address: 'Şişli/İstanbul',
    lat: 41.0668,
    lng: 28.9963,
  ),
  RideLocationPoint(
    name: 'Levent Büyükdere Caddesi',
    address: 'Beşiktaş/İstanbul',
    lat: 41.0820,
    lng: 29.0115,
  ),
  RideLocationPoint(
    name: 'İTÜ Ayazağa Kampüsü Girişi',
    address: 'Maslak, Sarıyer/İstanbul',
    lat: 41.1055,
    lng: 29.0252,
  ),
];

/// Faz 5: Gerçek zamanlı mesajlaşma, okunmamış mesaj sayacı (1, 2...), okundu bilgisi (✓✓),
/// gerçek zamanlı canlı konum yayını (`Geolocator` + Canlı Harita Stream) ve çevrimdışı
/// yerel önbellek destekli Sohbet Detay Ekranı (FR-06, FR-07, FR-09).
class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();

  // Gerçek zamanlı canlı konum yayını durumu
  bool _isSharingLiveLocation = false;
  String? _activeLiveMessageId;
  Timer? _liveRouteTimer;
  StreamSubscription<Position>? _gpsPositionSub;
  int _currentRouteStep = 0;
  double _currentLat = _liveRouteWaypoints.first.lat;
  double _currentLng = _liveRouteWaypoints.first.lng;
  String _currentLocationName = _liveRouteWaypoints.first.name;
  double _currentSpeedKmh = 42.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatsNotifierProvider.notifier).markChatAsRead(widget.chatId);
    });
  }

  @override
  void dispose() {
    _liveRouteTimer?.cancel();
    _gpsPositionSub?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  ChatEntity? _findCurrentChat(List<ChatEntity> chats) {
    for (final c in chats) {
      if (c.id == widget.chatId) return c;
    }
    return null;
  }

  Future<void> _sendText() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    _messageController.clear();
    await ref.read(chatsNotifierProvider.notifier).sendMessage(
          chatId: widget.chatId,
          senderId: user.id,
          text: text,
        );

    if (!mounted) return;
    _showRecipientNotificationSnackBar(user.id);
  }

  void _showRecipientNotificationSnackBar(String currentUserId) {
    final chats = ref.read(chatsNotifierProvider).valueOrNull ?? [];
    final chat = _findCurrentChat(chats);
    if (chat == null) return;

    final otherId = chat.otherParticipantId(currentUserId);
    final otherName = chat.otherParticipantName(currentUserId);
    final otherUnread = chat.unreadCountFor(otherId);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: AppColors.secondary,
        content: Row(
          children: [
            Badge(
              label: Text('$otherUnread'),
              backgroundColor: AppColors.error,
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$otherName adlı kullanıcıya bildirim gönderildi ($otherUnread okunmamış mesaj).',
              ),
            ),
          ],
        ),
        action: otherId.isNotEmpty
            ? SnackBarAction(
                label: 'Karşı Tarafa Geç ($otherUnread)',
                textColor: AppColors.primaryLight,
                onPressed: () async {
                  await ref
                      .read(authNotifierProvider.notifier)
                      .switchDemoAccount(otherId);
                  if (mounted) {
                    context.go('/home');
                  }
                },
              )
            : null,
      ),
    );
  }

  /// Cihazın gerçek GPS koordinatını `Geolocator` ile almaya çalışır;
  /// izin verilmezse veya masaüstünde kapalıysa varsayılan rota koordinatını döner.
  Future<({double lat, double lng, String label})> _acquireGpsPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 4),
            ),
          );
          return (
            lat: pos.latitude,
            lng: pos.longitude,
            label: 'Cihaz GPS Konumu',
          );
        }
      }
    } catch (_) {
      // Cihaz GPS'i kullanılamadığında İstanbul rota noktasına geri dönülür
    }
    final wp =
        _liveRouteWaypoints[_currentRouteStep % _liveRouteWaypoints.length];
    return (lat: wp.lat, lng: wp.lng, label: wp.name);
  }

  /// 1. Seçenek: Anlık Konum Gönder
  Future<void> _sendOneTimeGpsLocation() async {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    final gps = await _acquireGpsPosition();
    final coordStr =
        '${gps.lat.toStringAsFixed(4)}, ${gps.lng.toStringAsFixed(4)}';

    await ref.read(chatsNotifierProvider.notifier).sendMessage(
          chatId: widget.chatId,
          senderId: user.id,
          text: '📍 Anlık Konum Paylaşıldı: ${gps.label} ($coordStr)',
          type: 'location',
          lat: gps.lat,
          lng: gps.lng,
          locationName: gps.label,
          isLiveLocation: false,
        );

    if (!mounted) return;
    _showRecipientNotificationSnackBar(user.id);
  }

  /// 2. Seçenek: Gerçek Zamanlı Canlı Konum Yayını Başlat / Durdur
  Future<void> _startLiveLocationStream() async {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    final initial = await _acquireGpsPosition();
    _currentLat = initial.lat;
    _currentLng = initial.lng;
    _currentLocationName = initial.label;
    _currentRouteStep = 0;

    final coordStr =
        '${_currentLat.toStringAsFixed(4)}, ${_currentLng.toStringAsFixed(4)}';
    final sentMsg = await ref.read(chatsNotifierProvider.notifier).sendMessage(
          chatId: widget.chatId,
          senderId: user.id,
          text: '🔴 CANLI KONUM: $_currentLocationName ($coordStr)',
          type: 'location',
          lat: _currentLat,
          lng: _currentLng,
          locationName: _currentLocationName,
          isLiveLocation: true,
        );

    if (sentMsg == null || !mounted) return;

    setState(() {
      _isSharingLiveLocation = true;
      _activeLiveMessageId = sentMsg.id;
    });

    // Gerçek GPS akışını (`Geolocator.getPositionStream`) dinle
    try {
      _gpsPositionSub?.cancel();
      _gpsPositionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((pos) {
        if (!mounted || !_isSharingLiveLocation) return;
        setState(() {
          _currentLat = pos.latitude;
          _currentLng = pos.longitude;
          if (pos.speed > 0) {
            _currentSpeedKmh = pos.speed * 3.6;
          }
        });
      }, onError: (_) {});
    } catch (_) {}

    // Her 2 saniyede bir gerçek zamanlı konum güncellemesi yayınla
    _liveRouteTimer?.cancel();
    _liveRouteTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted || !_isSharingLiveLocation || _activeLiveMessageId == null) {
        timer.cancel();
        return;
      }

      _currentRouteStep = (_currentRouteStep + 1) % _liveRouteWaypoints.length;
      final nextWp = _liveRouteWaypoints[_currentRouteStep];

      setState(() {
        _currentLat = nextWp.lat;
        _currentLng = nextWp.lng;
        _currentLocationName = nextWp.name;
        _currentSpeedKmh = 38.0 + (_currentRouteStep * 4.5);
      });

      await ref.read(chatsNotifierProvider.notifier).updateLiveLocationMessage(
            chatId: widget.chatId,
            messageId: _activeLiveMessageId!,
            lat: _currentLat,
            lng: _currentLng,
            locationName: _currentLocationName,
            isLiveLocation: true,
          );
    });
  }

  Future<void> _stopLiveLocationStream() async {
    _liveRouteTimer?.cancel();
    _gpsPositionSub?.cancel();
    final msgId = _activeLiveMessageId;

    setState(() {
      _isSharingLiveLocation = false;
      _activeLiveMessageId = null;
    });

    if (msgId != null) {
      await ref.read(chatsNotifierProvider.notifier).updateLiveLocationMessage(
            chatId: widget.chatId,
            messageId: msgId,
            lat: _currentLat,
            lng: _currentLng,
            locationName: _currentLocationName,
            isLiveLocation: false,
          );
    }
  }

  void _showLocationOptionsSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Konum ve Canlı Takip Paylaşımı',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Gerçek zamanlı canlı konum akışı başlatabilir veya anlık GPS koordinatınızı gönderebilirsiniz.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.error.withValues(alpha: 0.15),
                    foregroundColor: AppColors.error,
                    child: const Icon(Icons.sensors_rounded),
                  ),
                  title: Text(
                    _isSharingLiveLocation
                        ? 'Canlı Konum Yayınını Durdur'
                        : 'Gerçek Zamanlı Canlı Konum Paylaş (Canlı Yayın)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _isSharingLiveLocation
                        ? 'Aktif canlı konum akışını sonlandırır'
                        : 'Konumunuz harita üzerinde her 2 saniyede bir gerçek zamanlı güncellenir',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (_isSharingLiveLocation) {
                      _stopLiveLocationStream();
                    } else {
                      _startLiveLocationStream();
                    }
                  },
                ),
              ),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    foregroundColor: AppColors.primary,
                    child: const Icon(Icons.my_location_rounded),
                  ),
                  title: const Text(
                    'Mevcut Anlık Konumumu Gönder (GPS)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Geolocator üzerinden tek seferlik anlık harita pini gönderir',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendOneTimeGpsLocation();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openLiveMapModal({
    required double initialLat,
    required double initialLng,
    required String initialTitle,
    required bool isLive,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _LiveLocationFullMapSheet(
        chatId: widget.chatId,
        initialLat: initialLat,
        initialLng: initialLng,
        initialTitle: initialTitle,
        isLive: isLive,
      ),
    );
  }

  Future<void> _simulateIncomingMessageFromOther(ChatEntity chat) async {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;
    final otherId = chat.otherParticipantId(user.id);
    final otherName = chat.otherParticipantName(user.id);
    if (otherId.isEmpty) return;

    await ref.read(chatsNotifierProvider.notifier).sendMessage(
          chatId: widget.chatId,
          senderId: otherId,
          text:
              'Merhaba, durağa yaklaştım! 5 dakika içinde oradayım. ($otherName)',
        );

    if (!mounted) return;
    final updatedChats = ref.read(chatsNotifierProvider).valueOrNull ?? [];
    final updatedChat = _findCurrentChat(updatedChats);
    final myUnread = updatedChat?.unreadCountFor(user.id) ?? 1;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Row(
          children: [
            Badge(
              label: Text('$myUnread'),
              backgroundColor: AppColors.error,
              child: const Icon(
                Icons.mark_chat_unread_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '🔔 Yeni Mesaj Bildirimi: $otherName size mesaj gönderdi! ($myUnread okunmamış mesaj)',
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Okundu İşaretle',
          textColor: Colors.white,
          onPressed: () {
            ref
                .read(chatsNotifierProvider.notifier)
                .markChatAsRead(widget.chatId);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final chatsAsync = ref.watch(chatsNotifierProvider);
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;

    final chats = chatsAsync.valueOrNull ?? [];
    final currentChat = _findCurrentChat(chats);
    final userId = currentUser?.id ?? '';
    final otherName =
        currentChat?.otherParticipantName(userId) ?? 'Yolculuk Sohbeti';
    final otherId = currentChat?.otherParticipantId(userId) ?? '';
    final otherUnread =
        otherId.isNotEmpty ? (currentChat?.unreadCountFor(otherId) ?? 0) : 0;
    final myUnread = currentChat?.unreadCountFor(userId) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              otherName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (currentChat != null && currentChat.rideSummaryTitle.isNotEmpty)
              Text(
                currentChat.rideSummaryTitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          if (currentChat != null)
            IconButton(
              tooltip: 'Karşı Taraftan Gelen Mesaj Simüle Et (+1 Bildirim)',
              onPressed: () => _simulateIncomingMessageFromOther(currentChat),
              icon: Badge(
                isLabelVisible: myUnread > 0,
                label: Text('$myUnread'),
                backgroundColor: AppColors.error,
                child: const Icon(Icons.mark_chat_unread_outlined),
              ),
            ),
          if (otherId.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message:
                    'Karşı tarafın ekranına geçerek okunmamış mesaj bildirimini görüntüle',
                child: TextButton.icon(
                  onPressed: () async {
                    await ref
                        .read(authNotifierProvider.notifier)
                        .switchDemoAccount(otherId);
                    if (context.mounted) {
                      context.go('/home');
                    }
                  },
                  icon: Badge(
                    isLabelVisible: otherUnread > 0,
                    label: Text('$otherUnread'),
                    backgroundColor: AppColors.error,
                    child: const Icon(Icons.swap_horiz_rounded, size: 20),
                  ),
                  label: Text(
                    otherUnread > 0 ? 'Karşıda ($otherUnread)' : 'Karşıya Geç',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: _isSharingLiveLocation
                ? 'Canlı Konum Yayını Aktif (Seçenekler)'
                : 'Canlı Konum Paylaş',
            onPressed: _showLocationOptionsSheet,
            icon: Icon(
              _isSharingLiveLocation
                  ? Icons.sensors_rounded
                  : Icons.my_location_rounded,
              color: _isSharingLiveLocation ? AppColors.error : null,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Gerçek Zamanlı Canlı Konum Yayını Aktif Bandı
          if (_isSharingLiveLocation)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                border: const Border(
                  bottom: BorderSide(color: AppColors.error, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sensors_rounded,
                    color: AppColors.error,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CANLI KONUM YAYINI AKTİF • ${_currentSpeedKmh.toStringAsFixed(0)} km/s',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$_currentLocationName (${_currentLat.toStringAsFixed(4)}, ${_currentLng.toStringAsFixed(4)})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openLiveMapModal(
                      initialLat: _currentLat,
                      initialLng: _currentLng,
                      initialTitle: _currentLocationName,
                      isLive: true,
                    ),
                    child: const Text('Harita'),
                  ),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: _stopLiveLocationStream,
                    child: const Text('Durdur'),
                  ),
                ],
              ),
            ),

          // Karşı tarafta veya bizde okunmamış mesaj varsa canlı durum bilgi çubuğu
          if (otherUnread > 0 || myUnread > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: (myUnread > 0 ? AppColors.error : AppColors.info)
                  .withValues(alpha: 0.12),
              child: Row(
                children: [
                  Badge(
                    label: Text('${myUnread > 0 ? myUnread : otherUnread}'),
                    backgroundColor:
                        myUnread > 0 ? AppColors.error : AppColors.info,
                    child: Icon(
                      Icons.notifications_active_outlined,
                      size: 18,
                      color: myUnread > 0 ? AppColors.error : AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      myUnread > 0
                          ? '$otherName tarafından gelen $myUnread okunmamış mesajınız var.'
                          : '$otherName kullanıcısında $otherUnread okunmamış mesaj bildirimi bekliyor.',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (myUnread > 0)
                    TextButton(
                      onPressed: () => ref
                          .read(chatsNotifierProvider.notifier)
                          .markChatAsRead(widget.chatId),
                      child: const Text('Okundu İşaretle'),
                    ),
                ],
              ),
            ),

          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Mesajlar alınamadı: $e')),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Henüz mesaj yok. İlk mesajı gönderin!'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser?.id;

                    if (msg.type == 'location') {
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: _LocationMessageCard(
                          message: msg,
                          isMe: isMe,
                          onOpenFullMap: () => _openLiveMapModal(
                            initialLat: msg.lat ?? 40.9901,
                            initialLng: msg.lng ?? 29.0234,
                            initialTitle:
                                msg.locationName ?? 'Paylaşılan Konum',
                            isLive: msg.isLiveLocation,
                          ),
                        ),
                      );
                    }

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: const BoxConstraints(maxWidth: 310),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.primary
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: isMe
                              ? null
                              : Border.all(
                                  color: !msg.isRead
                                      ? AppColors.primary
                                      : AppColors.lightBorder,
                                  width: !msg.isRead ? 1.5 : 1.0,
                                ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              msg.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : null,
                                fontWeight: !msg.isRead
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormatter.formatTime(msg.createdAt),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMe
                                        ? Colors.white70
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    msg.isRead
                                        ? Icons.done_all_rounded
                                        : Icons.done_rounded,
                                    size: 14,
                                    color: msg.isRead
                                        ? Colors.lightBlueAccent
                                        : Colors.white70,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    msg.isRead ? 'Okundu' : 'İletildi',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ] else if (!msg.isRead) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'YENİ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: const Border(
                  top: BorderSide(color: AppColors.lightBorder),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Canlı veya Anlık Konum Paylaş',
                    onPressed: _showLocationOptionsSheet,
                    icon: Icon(
                      _isSharingLiveLocation
                          ? Icons.sensors_rounded
                          : Icons.add_location_alt_outlined,
                      color: _isSharingLiveLocation
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendText(),
                      decoration: const InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendText,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sohbet balonu içinde mini etkileşimli harita (`FlutterMap`), canlı koordinat,
/// Zoom In (+) / Zoom Out (-) butonları ve "Canlı Haritada Takip Et" butonu gösteren bileşen.
class _LocationMessageCard extends StatefulWidget {
  final MessageEntity message;
  final bool isMe;
  final VoidCallback onOpenFullMap;

  const _LocationMessageCard({
    required this.message,
    required this.isMe,
    required this.onOpenFullMap,
  });

  @override
  State<_LocationMessageCard> createState() => _LocationMessageCardState();
}

class _LocationMessageCardState extends State<_LocationMessageCard> {
  final MapController _miniMapController = MapController();

  void _zoomIn() {
    try {
      final z = (_miniMapController.camera.zoom + 1.0).clamp(3.0, 18.5);
      _miniMapController.move(_miniMapController.camera.center, z);
    } catch (_) {}
  }

  void _zoomOut() {
    try {
      final z = (_miniMapController.camera.zoom - 1.0).clamp(3.0, 18.5);
      _miniMapController.move(_miniMapController.camera.center, z);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isMe = widget.isMe;
    final onOpenFullMap = widget.onOpenFullMap;
    final lat = message.lat ?? 40.9901;
    final lng = message.lng ?? 29.0234;
    final point = LatLng(lat, lng);
    final isLive = message.isLiveLocation;
    final placeName = message.locationName ?? 'Paylaşılan Konum';

    return Container(
      width: 290,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? AppColors.error : AppColors.primary,
          width: isLive ? 2.0 : 1.2,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Üst Durum Başlığı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (isLive ? AppColors.error : AppColors.primary)
                  .withValues(alpha: 0.12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(
                  isLive ? Icons.sensors_rounded : Icons.location_on_rounded,
                  size: 18,
                  color: isLive ? AppColors.error : AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isLive
                        ? 'GERÇEK ZAMANLI CANLI KONUM'
                        : 'ANLIK KONUM PAYLAŞIMI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isLive ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ),
                if (isLive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'CANLI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Mini Harita Önizlemesi (`FlutterMap` + Zoom In/Out)
          SizedBox(
            height: 145,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _miniMapController,
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 13.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.bitirme.paylasimli_yolculuk',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _liveRouteWaypoints
                              .map((w) => LatLng(w.lat, w.lng))
                              .toList(),
                          strokeWidth: 3.5,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 48,
                          height: 48,
                          child: Icon(
                            isLive
                                ? Icons.directions_car_filled_rounded
                                : Icons.location_on_rounded,
                            size: 34,
                            color: isLive ? AppColors.error : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: _zoomIn,
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(width: 18, height: 1, color: Colors.black12),
                        InkWell(
                          onTap: _zoomOut,
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.remove_rounded,
                              size: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Alt Detay ve Canlı Harita Butonu
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  placeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Koordinat: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onOpenFullMap,
                      icon: const Icon(Icons.map_outlined, size: 16),
                      label: Text(
                        isLive ? 'Canlı Haritada İzle' : 'Haritada Gör',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormatter.formatTime(message.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 15,
                            color: message.isRead
                                ? AppColors.primary
                                : AppColors.lightTextSecondary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tam ekran / alt pencere olarak açılan ve karşı tarafın veya sürücünün
/// hareketini gerçek zamanlı olarak `FlutterMap` üzerinde gösteren Canlı Takip Haritası.
class _LiveLocationFullMapSheet extends ConsumerStatefulWidget {
  final String chatId;
  final double initialLat;
  final double initialLng;
  final String initialTitle;
  final bool isLive;

  const _LiveLocationFullMapSheet({
    required this.chatId,
    required this.initialLat,
    required this.initialLng,
    required this.initialTitle,
    required this.isLive,
  });

  @override
  ConsumerState<_LiveLocationFullMapSheet> createState() =>
      _LiveLocationFullMapSheetState();
}

class _LiveLocationFullMapSheetState
    extends ConsumerState<_LiveLocationFullMapSheet> {
  final MapController _mapController = MapController();

  void _zoomIn() {
    try {
      final z = (_mapController.camera.zoom + 1.0).clamp(3.0, 18.5);
      _mapController.move(_mapController.camera.center, z);
    } catch (_) {}
  }

  void _zoomOut() {
    try {
      final z = (_mapController.camera.zoom - 1.0).clamp(3.0, 18.5);
      _mapController.move(_mapController.camera.center, z);
    } catch (_) {}
  }

  void _centerOn(LatLng target) {
    try {
      _mapController.move(target, _mapController.camera.zoom);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final msgs = messagesAsync.valueOrNull ?? [];
    final locationMsgs = msgs.where((m) => m.type == 'location').toList();

    final latestLoc = locationMsgs.isNotEmpty ? locationMsgs.last : null;
    final lat = latestLoc?.lat ?? widget.initialLat;
    final lng = latestLoc?.lng ?? widget.initialLng;
    final title = latestLoc?.locationName ?? widget.initialTitle;
    final liveActive = latestLoc?.isLiveLocation ?? widget.isLive;
    final point = LatLng(lat, lng);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.78,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                Icon(
                  liveActive
                      ? Icons.sensors_rounded
                      : Icons.location_on_rounded,
                  color: liveActive ? AppColors.error : AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        liveActive
                            ? 'Gerçek Zamanlı Canlı Konum Takibi'
                            : 'Paylaşılan Konum Detayı',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$title • (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.bitirme.paylasimli_yolculuk',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _liveRouteWaypoints
                              .map((w) => LatLng(w.lat, w.lng))
                              .toList(),
                          strokeWidth: 4.5,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 140,
                          height: 70,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: liveActive
                                      ? AppColors.error
                                      : Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Icon(
                                liveActive
                                    ? Icons.directions_car_filled_rounded
                                    : Icons.location_on_rounded,
                                size: 36,
                                color: liveActive
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Sağ Taraf Zoom In (+), Zoom Out (-) ve Konuma Odakla Butonları
                Positioned(
                  right: 14,
                  bottom: 20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Yakınlaştır (Zoom In +)',
                              icon: const Icon(
                                Icons.add_rounded,
                                color: Colors.black87,
                              ),
                              onPressed: _zoomIn,
                            ),
                            Container(
                              width: 28,
                              height: 1,
                              color: Colors.black12,
                            ),
                            IconButton(
                              tooltip: 'Uzaklaştır (Zoom Out -)',
                              icon: const Icon(
                                Icons.remove_rounded,
                                color: Colors.black87,
                              ),
                              onPressed: _zoomOut,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton.small(
                        heroTag: 'center_live_map_btn',
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        tooltip: 'Canlı Konuma Odakla',
                        onPressed: () => _centerOn(point),
                        child: const Icon(Icons.my_location_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
