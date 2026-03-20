// lib/screens/home_screen.dart
// 主页：顶部 Hero 卡片 + 底部导航

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import '../utils/app_theme.dart';
import 'calendar_screen.dart';
import 'stats_screen.dart';
import 'log_screen.dart';
import 'insights_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = [
    const CalendarScreen(),
    const StatsScreen(),
    const InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero(state)),
          SliverFillRemaining(
            hasScrollBody: true,
            child: _pages[_currentIndex],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => LogScreen(date: DateTime.now())),
          );
        },
        backgroundColor: AppTheme.pink,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit_outlined),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: AppTheme.pink),
            label: '日历',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: AppTheme.pink),
            label: '统计',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: AppTheme.pink),
            label: '健康建议',
          ),
        ],
      ),
    );
  }

  Widget _buildHero(AppState state) {
    final hasActive = state.activePeriod != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4C0D1), Color(0xFFCECBF6)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🌸 花期记录',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3C3489))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  state.prediction != null
                      ? '周期 ${state.prediction!.avgCycleLength} 天'
                      : '记录中',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF3C3489)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.pink.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      hasActive ? '🌺' : '🌷',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.heroTitle,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF26215C))),
                      const SizedBox(height: 3),
                      Text(state.heroSub,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF534AB7))),
                    ],
                  ),
                ),
                // 经期开始/结束按钮
                GestureDetector(
                  onTap: () => _showPeriodDialog(state),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasActive ? Colors.white : AppTheme.pink,
                      borderRadius: BorderRadius.circular(20),
                      border: hasActive
                          ? Border.all(
                              color: AppTheme.pink, width: 0.5)
                          : null,
                    ),
                    child: Text(
                      hasActive ? '结束经期' : '开始经期',
                      style: TextStyle(
                          fontSize: 11,
                          color: hasActive ? AppTheme.pink : Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  void _showPeriodDialog(AppState state) {
    final hasActive = state.activePeriod != null;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(hasActive ? '结束今次经期？' : '标记经期开始'),
        content: Text(hasActive
            ? '将今天设为经期结束日，确认吗？'
            : '将今天设为经期开始日，确认吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消',
                  style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (hasActive) {
                await state.endPeriod();
              } else {
                await state.startPeriod();
              }
            },
            child: Text(hasActive ? '结束' : '开始',
                style: const TextStyle(color: AppTheme.pink)),
          ),
        ],
      ),
    );
  }
}
