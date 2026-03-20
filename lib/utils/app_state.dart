// lib/utils/app_state.dart
// 全局状态管理（Provider）

import 'package:flutter/foundation.dart';
import '../models/period.dart';
import '../models/daily_log.dart';
import '../database/db_helper.dart';
import 'cycle_predictor.dart';

class AppState extends ChangeNotifier {
  final DBHelper _db = DBHelper();

  List<Period> _periods = [];
  CyclePrediction? _prediction;
  DailyLog? _todayLog;
  bool _loading = true;

  List<Period> get periods => _periods;
  CyclePrediction? get prediction => _prediction;
  DailyLog? get todayLog => _todayLog;
  bool get loading => _loading;

  Period? get activePeriod {
    try {
      return _periods.firstWhere((p) => p.isActive);
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    _loading = true;
    notifyListeners();

    _periods = await _db.getAllPeriods();
    _prediction = CyclePredictor.predict(_periods);
    _todayLog = await _db.getDailyLog(DateTime.now());

    _loading = false;
    notifyListeners();
  }

  // ---- 经期操作 ----

  /// 标记经期开始
  Future<void> startPeriod() async {
    // 如果已有活跃经期，先结束它
    if (activePeriod != null) {
      await endPeriod();
    }
    final period = Period(startDate: DateTime.now());
    final id = await _db.insertPeriod(period);
    _periods.insert(0, period.copyWith(id: id));
    _recalculate();
    notifyListeners();
  }

  /// 标记经期结束
  Future<void> endPeriod() async {
    final active = activePeriod;
    if (active == null) return;

    final ended = active.copyWith(endDate: DateTime.now());
    await _db.updatePeriod(ended);

    final idx = _periods.indexWhere((p) => p.id == active.id);
    if (idx != -1) _periods[idx] = ended;

    _recalculate();
    notifyListeners();
  }

  /// 删除一条经期记录
  Future<void> deletePeriod(int id) async {
    await _db.deletePeriod(id);
    _periods.removeWhere((p) => p.id == id);
    _recalculate();
    notifyListeners();
  }

  // ---- 每日记录 ----

  Future<void> saveDailyLog(DailyLog log) async {
    await _db.upsertDailyLog(log);
    _todayLog = log;
    notifyListeners();
  }

  Future<DailyLog?> getLogForDate(DateTime date) async {
    return _db.getDailyLog(date);
  }

  // ---- 工具 ----

  DayType getDayType(DateTime day) {
    return CyclePredictor.getDayType(day, _periods, _prediction);
  }

  void _recalculate() {
    _prediction = CyclePredictor.predict(_periods);
  }

  String get heroTitle {
    final pred = _prediction;
    if (activePeriod != null) {
      final days = DateTime.now()
          .difference(activePeriod!.startDate)
          .inDays + 1;
      return '经期第 $days 天';
    }
    if (pred == null) return '开始记录你的经期';
    final d = pred.daysUntilNextPeriod;
    if (d < 0) return '经期可能已到来';
    if (d == 0) return '今天可能是经期开始日';
    return '距下次经期还有 $d 天';
  }

  String get heroSub {
    final pred = _prediction;
    if (pred == null) return '点击下方记录第一次经期';
    final m = pred.nextPeriodStart.month;
    final d = pred.nextPeriodStart.day;
    return '预计 $m月$d日来潮 · 平均周期 ${pred.avgCycleLength} 天';
  }
}
