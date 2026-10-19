import 'package:flutter/foundation.dart';

@immutable
class WaterLog {
  final String id;
  final int amountMl;
  final DateTime timestamp;

  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  WaterLog copyWith({
    String? id,
    int? amountMl,
    DateTime? timestamp,
  }) {
    return WaterLog(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amountMl': amountMl,
    'timestamp': timestamp.toIso8601String(),
  };

  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog(
    id: json['id'] as String,
    amountMl: json['amountMl'] as int,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
