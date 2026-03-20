// lib/models/period.dart
// 经期记录数据模型

class Period {
  final int? id;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLength; // 本次周期长度（天）

  Period({
    this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength,
  });

  int get duration {
    if (endDate == null) return 0;
    return endDate!.difference(startDate).inDays + 1;
  }

  bool get isActive => endDate == null;

  Map<String, dynamic> toMap() => {
    'id': id,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'cycle_length': cycleLength,
  };

  factory Period.fromMap(Map<String, dynamic> map) => Period(
    id: map['id'],
    startDate: DateTime.parse(map['start_date']),
    endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
    cycleLength: map['cycle_length'],
  );

  Period copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
  }) => Period(
    id: id ?? this.id,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    cycleLength: cycleLength ?? this.cycleLength,
  );
}
