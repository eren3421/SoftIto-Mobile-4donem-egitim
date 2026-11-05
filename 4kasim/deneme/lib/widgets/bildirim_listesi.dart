import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/bildirim_modeli.dart';

class BildirimListesiKarti extends StatelessWidget {
  final List<BildirimModeli> bildirimler;
  final String? token;
  final bool konuyaAboneMi;
  final ValueChanged<bool> onAboneDegisti;
  final VoidCallback? onTestBildirimiGonder;
  final void Function(String baslik, String icerik)? onOzelBildirimGonder;
  final ValueChanged<BildirimModeli>? onBildirimTiklandi;
  final ValueChanged<String>? onBildirimSil;
  final VoidCallback? onTumunuOkunduIsaretle;
  final VoidCallback? onTumunuTemizle;

  const BildirimListesiKarti({
    super.key,
    required this.bildirimler,
    required this.token,
    required this.konuyaAboneMi,
    required this.onAboneDegisti,
    this.onTestBildirimiGonder,
    this.onOzelBildirimGonder,
    this.onBildirimTiklandi,
    this.onBildirimSil,
    this.onTumunuOkunduIsaretle,
    this.onTumunuTemizle,
  });

  int get _okunmamisSayisi =>
      bildirimler.where((b) => !b.okunduMu).length;

  IconData _turIkonu(BildirimTuru tur, bool okunduMu) {
    switch (tur) {
      case BildirimTuru.yukleme:
        return Icons.cloud_done_outlined;
      case BildirimTuru.abone:
        return Icons.campaign_outlined;
      case BildirimTuru.test:
        return Icons.notifications_active_outlined;
      case BildirimTuru.fcm:
        return okunduMu
            ? Icons.mark_email_read_outlined
            : Icons.mark_email_unread_outlined;
    }
  }

  Color _turRengi(BildirimTuru tur) {
    switch (tur) {
      case BildirimTuru.yukleme:
        return const Color(0xFF2563EB);
      case BildirimTuru.abone:
        return const Color(0xFFD97706);
      case BildirimTuru.test:
        return const Color(0xFF7C3AED);
      case BildirimTuru.fcm:
        return const Color(0xFF006C4A);
    }
  }

  void _ozelBildirimDialogGoster(BuildContext context) {
    final baslikController = TextEditingController();
    final icerikController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.send_outlined, color: Color(0xFF006C4A)),
            SizedBox(width: 8),
            Text(
              'Özel Bildirim Gönder',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: baslikController,
              decoration: const InputDecoration(
                labelText: 'Bildirim Başlığı',
                hintText: 'Örn: Duyuru',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: icerikController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bildirim İçeriği',
                hintText: 'Mesajınızı yazın...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF006C4A),
            ),
            onPressed: () {
              final baslik = baslikController.text.trim();
              final icerik = icerikController.text.trim();
              if (baslik.isEmpty && icerik.isEmpty) return;
              Navigator.of(ctx).pop();
              onOzelBildirimGonder?.call(
                baslik.isEmpty ? 'Yeni Bildirim' : baslik,
                icerik.isEmpty ? 'Bildirim içeriği' : icerik,
              );
            },
            icon: const Icon(Icons.notifications_active, size: 18),
            label: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFF006C4A),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'FCM Bildirim Merkezi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Switch(
                  value: konuyaAboneMi,
                  onChanged: onAboneDegisti,
                  activeThumbColor: const Color(0xFF006C4A),
                ),
              ],
            ),
            Text(
              konuyaAboneMi ? 'tüm_sınıf yayını aktif' : 'Yayın Kapalı',
              style: TextStyle(
                fontSize: 12,
                color: konuyaAboneMi
                    ? const Color(0xFF006C4A)
                    : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cihazın FCM Tokeni',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (token != null && token!.isNotEmpty)
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: token!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('FCM Token panoya kopyalandı'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Row(
                            children: [
                              Icon(
                                Icons.copy_rounded,
                                size: 13,
                                color: Color(0xFF38BDF8),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Kopyala',
                                style: TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    token ?? 'Yerel bildirim modu aktif (FCM token bekleniyor...)',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTestBildirimiGonder,
                    icon: const Icon(
                      Icons.notification_add_outlined,
                      size: 18,
                    ),
                    label: const Text('Test Bildirimi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF006C4A),
                      side: const BorderSide(color: Color(0xFF006C4A)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _ozelBildirimDialogGoster(context),
                    icon: const Icon(Icons.edit_notifications_outlined, size: 18),
                    label: const Text('Özel Bildirim'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF006C4A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Gelen Bildirimler (${bildirimler.length}):',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (_okunmamisSayisi > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006C4A).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_okunmamisSayisi yeni',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006C4A),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (bildirimler.isNotEmpty) ...[
                  if (_okunmamisSayisi > 0)
                    IconButton(
                      onPressed: onTumunuOkunduIsaretle,
                      tooltip: 'Tümünü Okundu İşaretle',
                      icon: const Icon(
                        Icons.done_all_rounded,
                        size: 20,
                        color: Color(0xFF006C4A),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  IconButton(
                    onPressed: onTumunuTemizle,
                    tooltip: 'Tümünü Temizle',
                    icon: Icon(
                      Icons.delete_sweep_outlined,
                      size: 20,
                      color: Colors.red.shade600,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            bildirimler.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 36,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Henüz gelen bildirim yok',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bildirimler.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final b = bildirimler[index];
                      final renk = _turRengi(b.tur);
                      return Container(
                        decoration: BoxDecoration(
                          color: b.okunduMu
                              ? Colors.transparent
                              : renk.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          onTap: () => onBildirimTiklandi?.call(b),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: renk.withValues(alpha: 0.14),
                            child: Icon(
                              _turIkonu(b.tur, b.okunduMu),
                              color: renk,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  b.baslik,
                                  style: TextStyle(
                                    fontWeight: b.okunduMu
                                        ? FontWeight.w500
                                        : FontWeight.bold,
                                    fontSize: 14,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              if (!b.okunduMu)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: BoxDecoration(
                                    color: renk,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            b.icerik,
                            style: TextStyle(
                              fontSize: 12,
                              color: b.okunduMu
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade800,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${b.tarih.hour.toString().padLeft(2, '0')}:${b.tarih.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              if (onBildirimSil != null) ...[
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () => onBildirimSil!(b.id),
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Bildirimi Sil',
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}