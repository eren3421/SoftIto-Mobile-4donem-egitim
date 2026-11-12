import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/review_entity.dart';
import '../providers/chat_provider.dart';

/// Faz 5: Tamamlanan (`completed`) yolculuklar için 1-5 yıldız ve yorum içeren Değerlendirme Modal'ı (FR-08).
class ReviewModalSheet extends ConsumerStatefulWidget {
  final String rideId;
  final String revieweeId;
  final String revieweeName;

  const ReviewModalSheet({
    super.key,
    required this.rideId,
    required this.revieweeId,
    required this.revieweeName,
  });

  @override
  ConsumerState<ReviewModalSheet> createState() => _ReviewModalSheetState();
}

class _ReviewModalSheetState extends ConsumerState<ReviewModalSheet> {
  int _selectedRating = 5;
  final _commentController = TextEditingController(
    text: 'Çok güvenli ve dakik bir yolculuktu, teşekkürler.',
  );
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isSubmitting = true);
    final review = ReviewEntity(
      id: '',
      rideId: widget.rideId,
      reviewerId: user.id,
      reviewerName: user.fullName,
      revieweeId: widget.revieweeId,
      rating: _selectedRating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    final ok =
        await ref.read(chatsNotifierProvider.notifier).submitReview(review);
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text(
              'Değerlendirmeniz kaydedildi ve kullanıcının ortalama puanı güncellendi!',
            ),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.revieweeName} İçin Değerlendirme Yap',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Deneyiminizi 1-5 arası yıldız ve yorumla puanlayın (FR-08)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return IconButton(
                iconSize: 38,
                onPressed: () => setState(() => _selectedRating = starValue),
                icon: Icon(
                  starValue <= _selectedRating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: AppColors.warning,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Yorumunuz',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: const Icon(Icons.send_rounded),
            label: Text(
              _isSubmitting ? 'Kaydediliyor...' : 'Puanı ve Yorumu Gönder',
            ),
          ),
        ],
      ),
    );
  }
}

