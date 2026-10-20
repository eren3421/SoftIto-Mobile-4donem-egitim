import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum ReservationStatus {
  pending,   // Talep Edildi / Onay Bekliyor
  approved,  // Araç Sahibi Onayladı
  active,    // Teslim Edildi / Aktif Kirada
  completed, // Tamamlandı
  cancelled; // İptal Edildi

  String get displayName {
    switch (this) {
      case ReservationStatus.pending:
        return 'Onay Bekliyor';
      case ReservationStatus.approved:
        return 'Onaylandı';
      case ReservationStatus.active:
        return 'Aktif Kirada';
      case ReservationStatus.completed:
        return 'Tamamlandı';
      case ReservationStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  Color get color {
    switch (this) {
      case ReservationStatus.pending:
        return AppColors.statusAmber;
      case ReservationStatus.approved:
        return AppColors.statusEmerald;
      case ReservationStatus.active:
        return AppColors.crimsonAccent;
      case ReservationStatus.completed:
        return AppColors.silverText;
      case ReservationStatus.cancelled:
        return AppColors.statusRed;
    }
  }

  IconData get icon {
    switch (this) {
      case ReservationStatus.pending:
        return Icons.hourglass_top;
      case ReservationStatus.approved:
        return Icons.verified;
      case ReservationStatus.active:
        return Icons.key;
      case ReservationStatus.completed:
        return Icons.check_circle_outline;
      case ReservationStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}
