// lib/screens/log_screen.dart
// 每日记录页面：流量 + 症状 + 情绪

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/daily_log.dart';
import '../utils/app_state.dart';
import '../utils/app_theme.dart';

class LogScreen extends StatefulWidget {
  final DateTime date;
  const LogScreen({super.key, required this.date});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  FlowLevel _flow = FlowLevel.none;
  Set<Symptom> _symptoms = {};
  Set<Mood> _moods = {};
  final _noteController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final state = context.read<AppState>();
    final log = await state.getLogForDate(widget.date);
    if (log != null) {
      setState(() {
        _flow = log.flowLevel;
        _symptoms = Set.from(log.symptoms);
        _moods = Set.from(log.moods);
        _noteController.text = log.note ?? '';
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final log = DailyLog(
      date: widget.date,
      flowLevel: _flow,
      symptoms: _symptoms.toList(),
      moods: _moods.toList(),
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    await context.read<AppState>().saveDailyLog(log);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('记录已保存 ✓'),
          backgroundColor: AppTheme.pink,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy年M月d日 EEEE', 'zh_CN').format(widget.date);
    final isToday = isSameDay(widget.date, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(isToday ? '今日记录' : '记录'),
        leading: const BackButton(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500)),
                  const SizedBox(height: 20),
                  _sectionLabel('流量'),
                  const SizedBox(height: 8),
                  _buildFlowSelector(),
                  const SizedBox(height: 20),
                  _sectionLabel('症状'),
                  const SizedBox(height: 8),
                  _buildChips(
                    items: Symptom.values,
                    label: (s) => s.label,
                    isSelected: (s) => _symptoms.contains(s),
                    onToggle: (s) => setState(() {
                      _symptoms.contains(s)
                          ? _symptoms.remove(s)
                          : _symptoms.add(s);
                    }),
                    selectedBg: AppTheme.purplePale,
                    selectedBorder: AppTheme.purpleLight,
                    selectedText: AppTheme.purpleDark,
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('情绪'),
                  const SizedBox(height: 8),
                  _buildChips(
                    items: Mood.values,
                    label: (m) => m.label,
                    isSelected: (m) => _moods.contains(m),
                    onToggle: (m) => setState(() {
                      _moods.contains(m)
                          ? _moods.remove(m)
                          : _moods.add(m);
                    }),
                    selectedBg: AppTheme.pinkPale,
                    selectedBorder: AppTheme.pinkLight,
                    selectedText: const Color(0xFF72243E),
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('备注（可选）'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '记录一些想法或其他症状...',
                      hintStyle: TextStyle(
                          fontSize: 13, color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('保存记录'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF7F77DD),
        letterSpacing: 0.5),
  );

  Widget _buildFlowSelector() {
    return Row(
      children: FlowLevel.values.map((f) {
        final sel = _flow == f;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _flow = f),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? AppTheme.pinkPale : Colors.white,
                border: Border.all(
                  color: sel ? AppTheme.pink : Colors.grey.shade200,
                  width: sel ? 1 : 0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(f.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          sel ? FontWeight.w500 : FontWeight.normal,
                      color: sel
                          ? const Color(0xFF72243E)
                          : Colors.grey.shade500)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChips<T>({
    required List<T> items,
    required String Function(T) label,
    required bool Function(T) isSelected,
    required void Function(T) onToggle,
    required Color selectedBg,
    required Color selectedBorder,
    required Color selectedText,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final sel = isSelected(item);
        return GestureDetector(
          onTap: () => onToggle(item),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: sel ? selectedBg : Colors.white,
              border: Border.all(
                color: sel ? selectedBorder : Colors.grey.shade200,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label(item),
                style: TextStyle(
                    fontSize: 12,
                    color: sel ? selectedText : Colors.grey.shade600,
                    fontWeight:
                        sel ? FontWeight.w500 : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
