import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../providers/profile_provider.dart';

/// Karanlık/Aydınlık Tema Durumu Sağlayıcısı (NFR-04).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authNotifierProvider.notifier).refreshCurrentUser();
      final user = ref.read(authNotifierProvider).valueOrNull;
      if (user != null) {
        ref.invalidate(userReviewsProvider(user.id));
      }
    });
  }

  void _showEditProfileDialog(UserEntity user) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final bioCtrl = TextEditingController(text: user.bio);
    final phoneCtrl = TextEditingController(text: user.phoneNumber);
    final musicCtrl = TextEditingController(
      text: user.preferences.musicPreference,
    );
    bool smoking = user.preferences.smokingAllowed;
    bool pets = user.preferences.petsAllowed;
    String chatLevel = user.preferences.chatLevel;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Profil ve Yolculuk Tercihlerini Düzenle',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Ad Soyad'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Telefon'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bioCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Biyografi'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: musicCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Müzik Tercihi (Örn: Pop / Akustik)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Sigara İçilebilir'),
                      value: smoking,
                      onChanged: (v) => setModalState(() => smoking = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Evcil Hayvan Kabul Edilir'),
                      value: pets,
                      onChanged: (v) => setModalState(() => pets = v),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: chatLevel,
                      decoration: const InputDecoration(
                        labelText: 'Sohbet Düzeyi',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'quiet',
                          child: Text('Sessiz Yolculuk'),
                        ),
                        DropdownMenuItem(
                          value: 'moderate',
                          child: Text('Dengeli Sohbet'),
                        ),
                        DropdownMenuItem(
                          value: 'chatty',
                          child: Text('Sohbet Sever'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setModalState(() => chatLevel = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final updated = user.copyWith(
                          fullName: nameCtrl.text.trim(),
                          phoneNumber: phoneCtrl.text.trim(),
                          bio: bioCtrl.text.trim(),
                          preferences: user.preferences.copyWith(
                            smokingAllowed: smoking,
                            petsAllowed: pets,
                            musicPreference: musicCtrl.text.trim(),
                            chatLevel: chatLevel,
                          ),
                        );
                        await ref
                            .read(userVehiclesProvider.notifier)
                            .updateProfile(updated);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Değişiklikleri Kaydet'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authNotifierProvider);
    final vehiclesAsync = ref.watch(userVehiclesProvider);
    final isOffline = ref.watch(isOfflineModeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return authAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Hata: $err')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Oturum açılmadı.'));
        }
        final reviewsAsync = ref.watch(userReviewsProvider(user.id));
        final reviews = reviewsAsync.valueOrNull ?? [];
        final effectiveCount =
            reviews.isNotEmpty ? reviews.length : user.ratingCount;
        final effectiveAvg = reviews.isNotEmpty
            ? (reviews.fold<double>(0.0, (sum, r) => sum + r.rating) /
                reviews.length)
            : user.ratingAvg;

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(authNotifierProvider.notifier).refreshCurrentUser();
            ref.invalidate(userReviewsProvider(user.id));
            ref.invalidate(userVehiclesProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
            // Kullanıcı Özeti Kartı
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          foregroundColor: AppColors.primary,
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      user.fullName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  if (user.isVerified) ...[
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.warning,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    effectiveCount > 0
                                        ? '${effectiveAvg.toStringAsFixed(1)} ($effectiveCount değerlendirme)'
                                        : 'Henüz değerlendirme yok',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Profili Düzenle',
                          onPressed: () => _showEditProfileDialog(user),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                    if (user.bio.isNotEmpty) ...[
                      const Divider(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(user.bio),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.music_note, size: 16),
                          label: Text(user.preferences.musicPreference),
                        ),
                        Chip(
                          avatar: Icon(
                            user.preferences.smokingAllowed
                                ? Icons.smoking_rooms
                                : Icons.smoke_free,
                            size: 16,
                          ),
                          label: Text(
                            user.preferences.smokingAllowed
                                ? 'Sigara Serbest'
                                : 'Sigara İçilmez',
                          ),
                        ),
                        Chip(
                          avatar: const Icon(Icons.pets, size: 16),
                          label: Text(
                            user.preferences.petsAllowed
                                ? 'Evcil Hayvan Uygun'
                                : 'Evcil Hayvan Yok',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Araçlar Bölümü
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kayıtlı Araçlarım',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/add-vehicle'),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Araç Ekle'),
                ),
              ],
            ),
            vehiclesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Araçlar yüklenemedi: $e'),
              data: (vehicles) {
                if (vehicles.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_car_outlined),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Henüz kayıtlı aracınız yok. Sürücü olarak ilan açmak için araç ekleyin.',
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => context.push('/add-vehicle'),
                            child: const Text('Ekle'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: vehicles
                      .map(
                        (v) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              child: Icon(Icons.directions_car_rounded),
                            ),
                            title: Text(
                              '${v.brand} ${v.model} (${v.year})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Plaka: ${v.licensePlate} • Renk: ${v.color} • ${v.totalSeats} Koltuk',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () => ref
                                  .read(userVehiclesProvider.notifier)
                                  .deleteVehicle(v.id),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 16),

            // Hakkımdaki Değerlendirmeler (FR-08)
            Text(
              'Hakkımdaki Değerlendirmeler',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            reviewsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Değerlendirmeler alınamadı: $e'),
              data: (reviews) {
                if (reviews.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Henüz değerlendirme yapılmamış.'),
                    ),
                  );
                }
                return Column(
                  children: reviews
                      .map(
                        (r) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.warning.withValues(alpha: 0.2),
                              child: Text(
                                '${r.rating}★',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                            title: Text(r.reviewerName),
                            subtitle: Text(r.comment),
                            trailing: Text(
                              DateFormatter.formatDate(r.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 16),

            // Uygulama Ayarları
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.airplanemode_active_rounded),
                    title: const Text('Çevrimdışı (Uçak Modu) Simülasyonu'),
                    subtitle: const Text(
                      'Aktif edildiğinde tüm veriler yerel Hive önbelleğinden okunur',
                    ),
                    value: isOffline,
                    onChanged: (val) {
                      ref.read(isOfflineModeProvider.notifier).state = val;
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Karanlık Tema (Dark Mode)'),
                    value: themeMode == ThemeMode.dark,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).state =
                          val ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      'Oturumu Kapat',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      await ref.read(authNotifierProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      },
    );
  }
}

