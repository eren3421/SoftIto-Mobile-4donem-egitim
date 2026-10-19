import 'package:flutter/foundation.dart';

@immutable
final class WaterLog {
  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  final String id;
  final int amountMl;
  final DateTime timestamp;
}
