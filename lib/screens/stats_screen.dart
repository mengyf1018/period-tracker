// lib/screens/stats_screen.dart
// 统计页面：周期图表 + 历史记录

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/app_state.dart';
import '../utils/app_theme.dart';
import '../models/period.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pred = state.prediction;
    final periods = state.periods;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(pred?.avgCycleLength, pred?.avgPeriodLength, periods),
          const SizedBox(height: 16),
          if (periods.length >= 2) ...[
            _buildCycleChart(periods),
            const SizedBox(height: 16),
          ],
          _buildRegularityCard(state),
          const SizedBox(height: 16),
          _buildHistory(periods),
        ],
      ),
    );
  }

  Widget _buildStatCards(int? avgCycle, int? avgPeriod, List<Period> periods) {
    final completed = periods.where((p) => p.endDate != null).toList();
    final cycleLengths = <int>[];
    final sorted = List<Period>.from(periods)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    for (int i = 0; i < sorted.length - 1; i++) {
      final d = sorted[i].startDate.difference(sorted[i + 1].startDate).inDays;
      if (d >= 10 && d <= 60) cycleLengths.add(d);
    }
    final minCycle = cycleLengths.isNotEmpty
        ? cycleLengths.reduce((a, b) => a < b ? a : b)
        : null;
    final maxCycle = cycleLengths.isNotEmpty
        ? cycleLengths.reduce((a, b) => a > b ? a : b)
        : null;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _statCard('平均周期', avgCycle != null ? '$avgCycle 天' : '--'),
        _statCard('平均经期', avgPeriod != null ? '$avgPeriod 天' : '--'),
        _statCard('最短周期', minCycle != null ? '$minCycle 天' : '--'),
        _statCard('最长周期', maxCycle != null ? '$maxCycle 天' : '--'),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3C3489))),
        ],
      ),
    );
  }

  Widget _buildCycleChart(List<Period> periods) {
    final sorted = List<Period>.from(periods)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final cycleLengths = <MapEntry<String, int>>[];
    for (int i = 1; i < sorted.length && cycleLengths.length < 6; i++) {
      final d = sorted[i].startDate.difference(sorted[i - 1].startDate).inDays;
      if (d >= 10 && d <= 60) {
        final label = DateFormat('M月').format(sorted[i].startDate);
        cycleLengths.add(MapEntry(label, d));
      }
    }

    if (cycleLengths.isEmpty) return const SizedBox.shrink();

    final maxY = cycleLengths
            .map((e) => e.value)
            .reduce((a, b) => a > b ? a : b)
            .toDouble() +
        5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('周期天数趋势',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3C3489))),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 7,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= cycleLengths.length)
                          return const SizedBox.shrink();
                        return Text(
                          '${cycleLengths[i].value}',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= cycleLengths.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(cycleLengths[i].key,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: cycleLengths.asMap().entries.map((entry) {
                  final isLast = entry.key == cycleLengths.length - 1;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        color: isLast ? AppTheme.pink : AppTheme.purpleLight,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularityCard(AppState state) {
    final regularity = state.prediction?.regularity;
    if (regularity == null) return const SizedBox.shrink();

    final colors = {
      regularity.runtimeType: Colors.green,
    };
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (regularity.label) {
      case '周期规律':
        bgColor = const Color(0xFFEAF3DE);
        textColor = AppTheme.okColor;
        icon = Icons.check_circle_outline;
        break;
      case '轻微不规律':
        bgColor = const Color(0xFFFAEEDA);
        textColor = AppTheme.warnColor;
        icon = Icons.info_outline;
        break;
      default:
        bgColor = AppTheme.pinkPale;
        textColor = AppTheme.pink;
        icon = Icons.warning_amber_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(regularity.label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textColor)),
                const SizedBox(height: 4),
                Text(regularity.description,
                    style: TextStyle(fontSize: 12, color: textColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(List<Period> periods) {
    if (periods.isEmpty) {
      return Center(
        child: Text('还没有经期记录，去日历页标记开始吧',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('历史记录',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3C3489))),
        const SizedBox(height: 10),
        ...periods.take(10).map((p) => _historyItem(p)),
      ],
    );
  }

  Widget _historyItem(Period p) {
    final start = DateFormat('yyyy年M月d日').format(p.startDate);
    final duration = p.duration > 0 ? '${p.duration}天' : '进行中';
    final cycle = p.cycleLength != null ? '· 周期${p.cycleLength}天' : '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.pink,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(start,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w400)),
            ],
          ),
          Text('$duration $cycle',
              style:
                  TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
