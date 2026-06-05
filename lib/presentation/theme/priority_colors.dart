import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

@immutable
class PriorityColors extends ThemeExtension<PriorityColors> {
  final Color low;
  final Color medium;
  final Color high;
  final Color urgent;

  const PriorityColors({
    required this.low,
    required this.medium,
    required this.high,
    required this.urgent,
  });

  Color forPriority(Priority priority) {
    switch (priority) {
      case Priority.low:
        return low;
      case Priority.medium:
        return medium;
      case Priority.high:
        return high;
      case Priority.urgent:
        return urgent;
    }
  }

  @override
  PriorityColors copyWith({
    Color? low,
    Color? medium,
    Color? high,
    Color? urgent,
  }) {
    return PriorityColors(
      low: low ?? this.low,
      medium: medium ?? this.medium,
      high: high ?? this.high,
      urgent: urgent ?? this.urgent,
    );
  }

  @override
  PriorityColors lerp(PriorityColors? other, double t) {
    if (other == null) return this;
    return PriorityColors(
      low: Color.lerp(low, other.low, t)!,
      medium: Color.lerp(medium, other.medium, t)!,
      high: Color.lerp(high, other.high, t)!,
      urgent: Color.lerp(urgent, other.urgent, t)!,
    );
  }

  static const light = PriorityColors(
    low: Colors.grey,
    medium: Colors.blue,
    high: Colors.orange,
    urgent: Colors.red,
  );
}
