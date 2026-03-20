// lib/utils/cycle_predictor.dart
// 经期预测算法：基于历史数据推算下次经期、排卵日、易孕期

import '../models/period.dart';

class CyclePrediction {
  final DateTime nextPeriodStart;   // 预测下次经期开始日
  final DateTime nextPeriodEnd;     // 预测下次经期结束日
  final DateTime ovulationDay;      // 预测排卵日
  final DateTime fertileStart;      // 易孕期开始
  final DateTime fertileEnd;        // 易孕期结束
  final int avgCycleLength;         // 平均周期天数
  final int avgPeriodLength;        // 平均经期天数
  final int daysUntilNextPeriod;    // 距下次经期天数
  final CycleRegularity regularity; // 周期规律性评估

  CyclePrediction({
    required this.nextPeriodStart,
    required this.nextPeriodEnd,
    required this.ovulationDay,
    required this.fertileStart,
    required this.fertileEnd,
    required this.avgCycleLength,
    required this.avgPeriodLength,
    required this.daysUntilNextPeriod,
    required this.regularity,
  });
}

enum CycleRegularity {
  regular,    // 规律（波动 ≤ 7天）
  slightlyIrregular, // 轻微不规律（波动 8–14天）
  irregular,  // 不规律（波动 > 14天）
  insufficient, // 数据不足
}

extension CycleRegularityExt on CycleRegularity {
  String get label {
    switch (this) {
      case CycleRegularity.regular: return '周期规律';
      case CycleRegularity.slightlyIrregular: return '轻微不规律';
      case CycleRegularity.irregular: return '周期不规律';
      case CycleRegularity.insufficient: return '数据不足';
    }
  }

  String get description {
    switch (this) {
      case CycleRegularity.regular:
        return '你的周期非常规律，预测准确度较高。';
      case CycleRegularity.slightlyIrregular:
        return '周期存在一定波动，预测日期仅供参考。建议记录更多数据。';
      case CycleRegularity.irregular:
        return '周期波动较大，可能与压力、作息或健康状况有关，建议就医咨询。';
      case CycleRegularity.insufficient:
        return '数据不足，继续记录以获得更准确的预测。';
    }
  }
}

class CyclePredictor {
  static const int _defaultCycleLength = 28;
  static const int _defaultPeriodLength = 5;
  // 排卵日通常在下次经期前14天
  static const int _daysBeforeOvulation = 14;
  // 易孕期：排卵日前5天到排卵日后1天
  static const int _fertileBeforeOvulation = 5;
  static const int _fertileAfterOvulation = 1;

  /// 根据历史经期列表生成预测
  static CyclePrediction predict(List<Period> periods) {
    if (periods.isEmpty) {
      return _defaultPrediction();
    }

    final sorted = List<Period>.from(periods)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    // 计算平均经期长度
    final completedPeriods = sorted.where((p) => p.endDate != null).toList();
    final avgPeriodLength = completedPeriods.isNotEmpty
        ? (completedPeriods.map((p) => p.duration).reduce((a, b) => a + b) /
                completedPeriods.length)
            .round()
        : _defaultPeriodLength;

    // 计算周期长度（相邻经期开始日之差）
    final cycleLengths = <int>[];
    for (int i = 0; i < sorted.length - 1; i++) {
      final diff = sorted[i].startDate
          .difference(sorted[i + 1].startDate)
          .inDays;
      // 过滤异常值（10–60天内视为有效）
      if (diff >= 10 && diff <= 60) {
        cycleLengths.add(diff);
      }
    }

    final avgCycleLength = cycleLengths.isNotEmpty
        ? (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round()
        : _defaultCycleLength;

    // 评估规律性（周期最大值与最小值之差）
    CycleRegularity regularity;
    if (cycleLengths.length < 2) {
      regularity = CycleRegularity.insufficient;
    } else {
      final spread = cycleLengths.reduce((a, b) => a > b ? a : b) -
          cycleLengths.reduce((a, b) => a < b ? a : b);
      if (spread <= 7) {
        regularity = CycleRegularity.regular;
      } else if (spread <= 14) {
        regularity = CycleRegularity.slightlyIrregular;
      } else {
        regularity = CycleRegularity.irregular;
      }
    }

    // 预测下次经期开始日
    final lastStart = sorted.first.startDate;
    final nextStart = lastStart.add(Duration(days: avgCycleLength));
    final nextEnd = nextStart.add(Duration(days: avgPeriodLength - 1));

    // 排卵日和易孕期
    final ovulationDay =
        nextStart.subtract(Duration(days: _daysBeforeOvulation));
    final fertileStart =
        ovulationDay.subtract(Duration(days: _fertileBeforeOvulation));
    final fertileEnd =
        ovulationDay.add(Duration(days: _fertileAfterOvulation));

    final today = DateTime.now();
    final daysUntil = nextStart.difference(
            DateTime(today.year, today.month, today.day))
        .inDays;

    return CyclePrediction(
      nextPeriodStart: nextStart,
      nextPeriodEnd: nextEnd,
      ovulationDay: ovulationDay,
      fertileStart: fertileStart,
      fertileEnd: fertileEnd,
      avgCycleLength: avgCycleLength,
      avgPeriodLength: avgPeriodLength,
      daysUntilNextPeriod: daysUntil,
      regularity: regularity,
    );
  }

  /// 判断某天的日历状态
  static DayType getDayType(DateTime day, List<Period> periods,
      CyclePrediction? prediction) {
    final d = DateTime(day.year, day.month, day.day);

    // 检查是否在历史经期内
    for (final p in periods) {
      final s = DateTime(p.startDate.year, p.startDate.month, p.startDate.day);
      if (p.endDate != null) {
        final e =
            DateTime(p.endDate!.year, p.endDate!.month, p.endDate!.day);
        if (!d.isBefore(s) && !d.isAfter(e)) return DayType.period;
      } else {
        if (d == s || d.isAfter(s)) return DayType.period;
      }
    }

    if (prediction == null) return DayType.normal;

    final ns = DateTime(prediction.nextPeriodStart.year,
        prediction.nextPeriodStart.month, prediction.nextPeriodStart.day);
    final ne = DateTime(prediction.nextPeriodEnd.year,
        prediction.nextPeriodEnd.month, prediction.nextPeriodEnd.day);
    final ov = DateTime(prediction.ovulationDay.year,
        prediction.ovulationDay.month, prediction.ovulationDay.day);
    final fs = DateTime(prediction.fertileStart.year,
        prediction.fertileStart.month, prediction.fertileStart.day);
    final fe = DateTime(prediction.fertileEnd.year,
        prediction.fertileEnd.month, prediction.fertileEnd.day);

    if (!d.isBefore(ns) && !d.isAfter(ne)) return DayType.predicted;
    if (d == ov) return DayType.ovulation;
    if (!d.isBefore(fs) && !d.isAfter(fe)) return DayType.fertile;

    return DayType.normal;
  }

  static CyclePrediction _defaultPrediction() {
    final today = DateTime.now();
    final nextStart = today.add(const Duration(days: _defaultCycleLength));
    return CyclePrediction(
      nextPeriodStart: nextStart,
      nextPeriodEnd: nextStart.add(const Duration(days: _defaultPeriodLength - 1)),
      ovulationDay: nextStart.subtract(const Duration(days: _daysBeforeOvulation)),
      fertileStart: nextStart.subtract(
          const Duration(days: _daysBeforeOvulation + _fertileBeforeOvulation)),
      fertileEnd: nextStart.subtract(
          const Duration(days: _daysBeforeOvulation - _fertileAfterOvulation)),
      avgCycleLength: _defaultCycleLength,
      avgPeriodLength: _defaultPeriodLength,
      daysUntilNextPeriod: _defaultCycleLength,
      regularity: CycleRegularity.insufficient,
    );
  }
}

enum DayType { normal, period, predicted, ovulation, fertile }
