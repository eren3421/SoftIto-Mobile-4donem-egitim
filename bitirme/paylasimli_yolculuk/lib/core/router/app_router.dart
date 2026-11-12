import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/bookings/presentation/screens/my_rides_screen.dart';
import '../../features/chat/presentation/providers/chat_provider.dart';
import '../../features/chat/presentation/screens/chat_detail_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/profile/presentation/screens/add_vehicle_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/rides/presentation/screens/create_ride_screen.dart';
import '../../features/rides/presentation/screens/home_search_screen.dart';
import '../../features/rides/presentation/screens/ride_detail_screen.dart';
import '../constants/app_colors.dart';
import '../storage/seed_data_service.dart';

/// Router yenilemelerini tetikleyen Notifier.
/// `authNotifierProvider` değiştiğinde GoRouter'ı baştan oluşturmak yerine
/// sadece `refreshListenable` ile yönlendirmeleri (redirect) tetikler.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (previous, next) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// GoRouter üzerinde oturum kontrolü (Auth Guard) ve uygulama yönlendirmesi.
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      if (authState.isLoading) return null;

      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainShellScreen(),
      ),
      GoRoute(
        path: '/create-ride',
        builder: (context, state) => const CreateRideScreen(),
      ),
      GoRoute(
        path: '/ride/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return RideDetailScreen(rideId: id);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ChatDetailScreen(chatId: id);
        },
      ),
      GoRoute(
        path: '/add-vehicle',
        builder: (context, state) => const AddVehicleScreen(),
      ),
    ],
  );
});

/// 4 Sekmeli Ana Uygulama İskeleti (Yolculuk Ara, Yolculuklarım, Mesajlar, Profil).
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomeSearchScreen(),
    MyRidesScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  static const List<String> _titles = [
    'Paylaşımlı Yolculuk',
    'Yolculuklarım & Rezervasyonlar',
    'Mesajlar',
    'Profil & Araç Yönetimi',
  ];

  void _showNotificationsModal(BuildContext context) {
    final user = ref.read(authNotifierProvider).valueOrNull;
    final chats = ref.read(chatsNotifierProvider).valueOrNull ?? [];
    final userId = user?.id ?? '';
    final unreadChats =
        chats.where((c) => c.unreadCountFor(userId) > 0).toList();

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mesaj Bildirimleri',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (unreadChats.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        for (final c in unreadChats) {
                          await ref
                              .read(chatsNotifierProvider.notifier)
                              .markChatAsRead(c.id);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Tümünü Okundu İşaretle'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (unreadChats.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 44,
                        color: AppColors.lightTextSecondary,
                      ),
                      SizedBox(height: 8),
                      Text('Okunmamış yeni mesaj bildiriminiz bulunmuyor.'),
                    ],
                  ),
                )
              else
                ...unreadChats.map((chat) {
                  final count = chat.unreadCountFor(userId);
                  final senderName = chat.otherParticipantName(userId);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Badge(
                        label: Text('$count'),
                        backgroundColor: AppColors.error,
                        child: const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.mark_chat_unread_rounded, size: 20),
                        ),
                      ),
                      title: Text(
                        '$senderName ($count okunmamış mesaj)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/chat/${chat.id}');
                      },
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(isOfflineModeProvider);
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final totalUnread = ref.watch(totalUnreadMessagesCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.directions_car_filled_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _titles[_selectedIndex],
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          // Okunmamış Mesaj Bildirim Çanı (1, 2... rozetli)
          IconButton(
            tooltip: totalUnread > 0
                ? '$totalUnread Okunmamış Mesaj Bildirimi'
                : 'Bildirimler',
            onPressed: () => _showNotificationsModal(context),
            icon: Badge(
              isLabelVisible: totalUnread > 0,
              label: Text(
                '$totalUnread',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.error,
              child: Icon(
                totalUnread > 0
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: totalUnread > 0 ? AppColors.primary : null,
              ),
            ),
          ),

          // Çevrimdışı / Uçak Modu Hızlı Test Butonu (FR-09 kabul kriteri kanıtı için)
          IconButton(
            tooltip: isOffline
                ? 'Çevrimdışı Mod Aktif (Çevrimiçine Geç)'
                : 'Çevrimdışı (Uçak Modu) Testini Aç',
            onPressed: () {
              ref.read(isOfflineModeProvider.notifier).state = !isOffline;
            },
            icon: Icon(
              isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_outlined,
              color: isOffline ? AppColors.warning : AppColors.primary,
            ),
          ),

          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ActionChip(
                onPressed: () => setState(() => _selectedIndex = 3),
                avatar: const Icon(Icons.person_outline, size: 16),
                label: Text(
                  user.fullName.split(' ').first,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Okunmamış mesaj varsa ekranın üstünde beliren canlı bildirim çubuğu
          if (totalUnread > 0 && _selectedIndex != 2)
            Material(
              color: AppColors.primary.withValues(alpha: 0.12),
              child: InkWell(
                onTap: () => setState(() => _selectedIndex = 2),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Badge(
                        label: Text('$totalUnread'),
                        backgroundColor: AppColors.error,
                        child: const Icon(
                          Icons.mark_chat_unread_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Yeni Mesaj Bildirimi: $totalUnread okunmamış mesajınız var!',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Text(
                        'Mesajları Aç →',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Ara',
          ),
          const NavigationDestination(
            icon: Icon(Icons.commute_outlined),
            selectedIcon: Icon(Icons.commute_rounded),
            label: 'Yolculuklarım',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: totalUnread > 0,
              label: Text(
                '$totalUnread',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.chat_bubble_outline_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: totalUnread > 0,
              label: Text(
                '$totalUnread',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.chat_bubble_rounded),
            ),
            label: totalUnread > 0 ? 'Mesajlar ($totalUnread)' : 'Mesajlar',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
