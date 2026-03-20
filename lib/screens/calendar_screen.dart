// lib/screens/calendar_screen.dart
// 日历页面

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../utils/app_state.dart';
import '../utils/app_theme.dart';
import '../utils/cycle_predictor.dart';
import 'log_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCalendar(state),
          const SizedBox(height: 12),
          _buildLegend(),
          const SizedBox(height, 16),
          if (_selectedDay != null) _buildDayDetail(_selectedDay!, state),
        ],
      ),
    );
  }

  Widget _buildCalendar(AppState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
        locale: 'zh_CN',
        startingDayOfWeek: StartingDayOfWeek.sunday,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppTheme.purpleDark,
          ),
          leftChevronIcon: const Icon(Icons.chevron_left,
              color: AppTheme.purpleDark),
          rightChevronIcon: const Icon(Icons.chevron_right,
              color: AppTheme.purpleDark),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle:
              TextStyle(fontSize: 11, color: Colors.grey.shade500),
          weekendStyle:
              TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: AppTheme.pink,
            fontWeight: FontWeight.w600,
          ),
          selectedDecoration: BoxDecoration(
            color: AppTheme.pink,
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) =>
              _dayBuilder(day, state, false),
          todayBuilder: (context, day, focusedDay) =>
              _dayBuilder(day, state, true),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _dayBuilder(DateTime day, AppState state, bool isToday) {
    final type = state.getDayType(day);
    final isSelected = isSameDay(day, _selectedDay);

    Color? bg;
    Color textColor = Colors.black87;
    BoxBorder? border;
    BoxShape shape = BoxShape.circle;

    switch (type) {
      case DayType.period:
        bg = AppTheme.pinkLight;
        textColor = const Color(0xFF72243E);
        break;
      case DayType.predicted:
        bg = AppTheme.purplePale;
        textColor = AppTheme.purpleDark;
        border =
            Border.all(color: AppTheme.purpleLight, width: 1, style: BorderStyle.solid);
        break;
      case DayType.ovulation:
        bg = const Color(0xFF9FE1CB);
        textColor = const Color(0xFF04342C);
        break;
      case DayType.fertile:
        bg = const Color(0xFFEAF3DE);
        textColor = AppTheme.fertileColor;
        break;
      case DayType.normal:
        break;
    }

    if (isSelected) {
      bg = AppTheme.pink;
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: bg,
          shape: shape,
          border: border,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isToday ? FontWeight.w600 : FontWeight.normal,
                  color: textColor,
                ),
              ),
              if (isToday && !isSelected)
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppTheme.pink,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final items = [
      (_legendDot(AppTheme.pinkLight), '经期'),
      (_legendDot(AppTheme.purplePale, dashed: true), '预测'),
      (_legendDot(const Color(0xFF9FE1CB)), '排卵日'),
      (_legendDot(const Color(0xFFEAF3DE)), '易孕期'),
    ];
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: items
          .map((e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  e.$1,
                  const SizedBox(width: 5),
                  Text(e.$2,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600)),
                ],
              ))
          .toList(),
    );
  }

  Widget _legendDot(Color color, {bool dashed = false}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: dashed
            ? Border.all(color: AppTheme.purpleLight, width: 1)
            : null,
      ),
    );
  }

  Widget _buildDayDetail(DateTime day, AppState state) {
    final type = state.getDayType(day);
    final dateStr = DateFormat('M月d日 EEEE', 'zh_CN').format(day);

    String typeLabel = '';
    Color typeColor = Colors.grey;
    switch (type) {
      case DayType.period:
        typeLabel = '经期';
        typeColor = AppTheme.pink;
        break;
      case DayType.predicted:
        typeLabel = '预测经期';
        typeColor = AppTheme.purple;
        break;
      case DayType.ovulation:
        typeLabel = '排卵日';
        typeColor = AppTheme.ovulationColor;
        break;
      case DayType.fertile:
        typeLabel = '易孕期';
        typeColor = AppTheme.fertileColor;
        break;
      case DayType.normal:
        typeLabel = '普通日';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateStr,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(typeLabel,
                    style: TextStyle(
                        fontSize: 11,
                        color: typeColor,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => LogScreen(date: day)),
              );
            },
            child: const Text('记录当天',
                style:
                    TextStyle(fontSize: 12, color: AppTheme.pink)),
          ),
        ],
      ),
    );
  }
}
