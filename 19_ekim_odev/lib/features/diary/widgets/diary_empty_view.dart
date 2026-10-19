import 'package:flutter/material.dart';

/// Defterde sayfa bulunmadığında gösterilen boş durum bileşeni.
class DiaryEmptyView extends StatelessWidget {
  final VoidCallback onWriteFirstPage;
  final bool isFiltered;
  final String? customTitle;
  final String? customDescription;
  final VoidCallback? onClearFilter;

  const DiaryEmptyView({
    super.key,
    required this.onWriteFirstPage,
    this.isFiltered = false,
    this.customTitle,
    this.customDescription,
    this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = customTitle ??
        (isFiltered ? 'Bu Kriterde Sayfa Yok' : 'Defteriniz Henüz Boş');
    final desc = customDescription ??
        (isFiltered
            ? 'Seçilen filtreye uygun bir günlük sayfası bulunmuyor.'
            : 'Günün anılarını kalıcı kılmak için ilk sayfanızı yazın.');

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                isFiltered
                    ? Icons.bookmark_border_rounded
                    : Icons.menu_book_rounded,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(desc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 18),
            _ActionButton(
              isFiltered: isFiltered,
              onClearFilter: onClearFilter,
              onWriteFirstPage: onWriteFirstPage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback? onClearFilter;
  final VoidCallback onWriteFirstPage;

  const _ActionButton({
    required this.isFiltered,
    required this.onClearFilter,
    required this.onWriteFirstPage,
  });

  @override
  Widget build(BuildContext context) {
    if (isFiltered && onClearFilter != null) {
      return OutlinedButton.icon(
        onPressed: onClearFilter,
        icon: const Icon(Icons.clear_all_rounded),
        label: const Text('Tüm Sayfaları Göster'),
      );
    }
    return FilledButton.icon(
      onPressed: onWriteFirstPage,
      icon: const Icon(Icons.edit_note_rounded),
      label: const Text('İlk Sayfayı Yaz'),
    );
  }
}
