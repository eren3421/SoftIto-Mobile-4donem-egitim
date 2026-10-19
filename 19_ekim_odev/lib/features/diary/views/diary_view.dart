import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_model.dart';
import '../widgets/diary_calendar_bar.dart';
import '../widgets/diary_card.dart';
import '../widgets/diary_empty_view.dart';
import 'diary_compose_view.dart';

/// Defterin ana görünümü ve sayfaların listelendiği ana ekran.
/// project.md ve SKILL.md kurallarına uygun olarak ValueNotifier ile reaktif olarak çalışır.
class DiaryView extends StatelessWidget {
  final DiaryController controller;
  final ThemeController? themeController;

  const DiaryView({
    super.key,
    required this.controller,
    this.themeController,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = controller.selectedFilterDate.value ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      controller.setFilterDate(picked);
    }
  }

  void _openCompose(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DiaryComposeView(controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Defterim'),
        actions: [
          _FavoritesFilterButton(controller: controller),
          IconButton(
            tooltip: 'Tarihe Göre Sayfaları Seç',
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () => _pickDate(context),
          ),
          if (themeController != null)
            _ThemeToggleButton(themeController: themeController!),
        ],
      ),
      body: Column(
        children: [
          DiaryCalendarBar(
            controller: controller,
            onPickDate: () => _pickDate(context),
          ),
          Expanded(
            child: _DiaryContentBody(
              controller: controller,
              onWriteFirstPage: () => _openCompose(context),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCompose(context),
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Yeni Sayfa'),
      ),
    );
  }
}

class _FavoritesFilterButton extends StatelessWidget {
  final DiaryController controller;

  const _FavoritesFilterButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.onlyFavoritesFilter,
      builder: (context, isOnlyFavorites, _) {
        return IconButton(
          tooltip: isOnlyFavorites
              ? 'Tüm Sayfaları Göster'
              : 'Sadece Favorileri Göster',
          icon: Icon(
            isOnlyFavorites
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: isOnlyFavorites ? AppColors.favoriteActive : null,
          ),
          onPressed: controller.toggleFavoritesFilter,
        );
      },
    );
  }
}

class _DiaryContentBody extends StatelessWidget {
  final DiaryController controller;
  final VoidCallback onWriteFirstPage;

  const _DiaryContentBody({
    required this.controller,
    required this.onWriteFirstPage,
  });

  List<DiaryEntryModel> _filter(
    List<DiaryEntryModel> list,
    DateTime? date,
    bool onlyFav,
  ) {
    var result = list;
    if (date != null) {
      result = result.where((e) {
        return e.createdAt.year == date.year &&
            e.createdAt.month == date.month &&
            e.createdAt.day == date.day;
      }).toList();
    }
    if (onlyFav) {
      result = result.where((e) => e.isFavorite).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.onlyFavoritesFilter,
      builder: (context, onlyFav, _) {
        return ValueListenableBuilder<DateTime?>(
          valueListenable: controller.selectedFilterDate,
          builder: (context, filterDate, _) {
            return ValueListenableBuilder<List<DiaryEntryModel>>(
              valueListenable: controller.entries,
              builder: (context, allEntries, _) {
                final entryList = _filter(allEntries, filterDate, onlyFav);
                if (entryList.isEmpty) {
                  return DiaryEmptyView(
                    isFiltered: filterDate != null || onlyFav,
                    customTitle:
                        onlyFav ? 'Favori Sayfa Bulunmuyor' : null,
                    customDescription: onlyFav
                        ? 'Henüz favorilere eklenmiş bir anınız yok.'
                        : null,
                    onWriteFirstPage: onWriteFirstPage,
                    onClearFilter: () {
                      controller.setFilterDate(null);
                      if (controller.onlyFavoritesFilter.value) {
                        controller.toggleFavoritesFilter();
                      }
                    },
                  );
                }
                return _DiaryListView(
                  entries: entryList,
                  controller: controller,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  final ThemeController themeController;

  const _ThemeToggleButton({required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          tooltip: isDark ? 'Aydınlık Defter Modu' : 'Koyu Gece Modu',
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          ),
          onPressed: themeController.toggleTheme,
        );
      },
    );
  }
}

class _DiaryListView extends StatelessWidget {
  final List<DiaryEntryModel> entries;
  final DiaryController controller;

  const _DiaryListView({
    required this.entries,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return DiaryCard(
          entry: entry,
          onFavoriteToggle: () => controller.toggleFavorite(entry.id),
          onDelete: () => controller.deleteEntry(entry.id),
        );
      },
    );
  }
}
