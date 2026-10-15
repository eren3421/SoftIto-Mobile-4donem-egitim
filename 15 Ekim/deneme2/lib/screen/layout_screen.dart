import 'package:flutter/material.dart';

class LayoutStylingScreen extends StatefulWidget {
  const LayoutStylingScreen({super.key});

  @override
  State<LayoutStylingScreen> createState() => _LayoutStylingScreenState();
}

class _LayoutStylingScreenState extends State<LayoutStylingScreen> {
  bool isBalanceVisible = true;
  String lastAction = 'Hazır - Butonlara Tıklayabilirsiniz.';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil Online Rozeti.
          buildProfileHeader(),
          // Cüzdan Kartı.
          buildWalletCard(),
          // Aksiyon Butonları.
          buildQuickActions(),
          // İstatistiklik Bölümü.
          buildFlexStatistics(),
          // Notification Bildirim Banner.
          buildNotificationBanner(),
          // Canlı Durum Bildirimi.
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Son İşlem: $lastAction',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWalletCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF16366F),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Toplam Bakiye',
                  style: TextStyle(color: Colors.white70)),
              IconButton(
                tooltip:
                    isBalanceVisible ? 'Bakiyeyi gizle' : 'Bakiyeyi göster',
                color: Colors.white,
                icon: Icon(isBalanceVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () {
                  setState(() {
                    isBalanceVisible = !isBalanceVisible;
                    lastAction = isBalanceVisible
                        ? 'Bakiye gösterildi.'
                        : 'Bakiye gizlendi.';
                  });
                },
              ),
            ],
          ),
          Text(
            isBalanceVisible ? '₺24.580,00' : '••••••',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text('Örnek cüzdan verisi',
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          FilledButton.icon(
            onPressed: () {
              setState(() => lastAction = 'Para gönder seçildi.');
            },
            icon: const Icon(Icons.send_outlined),
            label: const Text('Gönder'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              setState(() => lastAction = 'Para al seçildi.');
            },
            icon: const Icon(Icons.call_received),
            label: const Text('Al'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              setState(() => lastAction = 'Para yatır seçildi.');
            },
            icon: const Icon(Icons.add),
            label: const Text('Yatır'),
          ),
        ],
      ),
    );
  }

  Widget buildFlexStatistics() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_downward, color: Colors.green),
                    SizedBox(height: 8),
                    Text('Örnek Gelir'),
                    Text('₺8.500,00',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.red),
                    SizedBox(height: 8),
                    Text('Örnek Gider'),
                    Text('₺3.200,00',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotificationBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: const Icon(Icons.notifications_outlined),
          title: const Text('Cüzdanını takip et'),
          subtitle:
              const Text('Gelir ve giderlerini düzenli olarak kontrol et.'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            setState(() => lastAction = 'Bildirim görüntülendi.');
          },
        ),
      ),
    );
  }

  Widget buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEDE9FE),
                  border: Border.all(
                    color: const Color(0xFF6366F1),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF6366F1),
                  size: 36,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF8FAFC),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoş Geldin,Eren',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cüzdanınıza genel bakış',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}