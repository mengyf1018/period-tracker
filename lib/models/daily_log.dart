// lib/models/daily_log.dart
// 每日记录：流量、症状、情绪

enum FlowLevel { none, light, medium, heavy, veryHeavy }

enum Symptom {
  cramps,        // 腹痛
  backPain,      // 腰酸
  headache,      // 头痛
  breastTender,  // 乳房胀痛
  fatigue,       // 疲劳
  nausea,        // 恶心
  bloating,      // 腹胀
  acne,          // 痘痘
  insomnia,      // 失眠
}

enum Mood {
  calm,      // 平静
  sad,       // 低落
  irritable, // 烦躁
  happy,     // 愉悦
  anxious,   // 焦虑
  sleepy,    // 嗜睡
}

extension FlowLevelExt on FlowLevel {
  String get label {
    switch (this) {
      case FlowLevel.none: return '无';
      case FlowLevel.light: return '少';
      case FlowLevel.medium: return '中';
      case FlowLevel.heavy: return '多';
      case FlowLevel.veryHeavy: return '极多';
    }
  }
}

extension SymptomExt on Symptom {
  String get label {
    const labels = {
      Symptom.cramps: '腹痛',
      Symptom.backPain: '腰酸',
      Symptom.headache: '头痛',
      Symptom.breastTender: '乳房胀痛',
      Symptom.fatigue: '疲劳',
      Symptom.nausea: '恶心',
      Symptom.bloating: '腹胀',
      Symptom.acne: '痘痘',
      Symptom.insomnia: '失眠',
    };
    return labels[this]!;
  }
}

extension MoodExt on Mood {
  String get label {
    const labels = {
      Mood.calm: '😌 平静',
      Mood.sad: '😔 低落',
      Mood.irritable: '😤 烦躁',
      Mood.happy: '😊 愉悦',
      Mood.anxious: '😩 焦虑',
      Mood.sleepy: '😴 嗜睡',
    };
    return labels[this]!;
  }
}

class DailyLog {
  final int? id;
  final DateTime date;
  final FlowLevel flowLevel;
  final List<Symptom> symptoms;
  final List<Mood> moods;
  final String? note;

  DailyLog({
    this.id,
    required this.date,
    this.flowLevel = FlowLevel.none,
    this.symptoms = const [],
    this.moods = const [],
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String().substring(0, 10),
    'flow_level': flowLevel.index,
    'symptoms': symptoms.map((s) => s.index).join(','),
    'moods': moods.map((m) => m.index).join(','),
    'note': note,
  };

  factory DailyLog.fromMap(Map<String, dynamic> map) => DailyLog(
    id: map['id'],
    date: DateTime.parse(map['date']),
    flowLevel: FlowLevel.values[map['flow_level'] ?? 0],
    symptoms: (map['symptoms'] as String?)
        ?.split(',')
        .where((s) => s.isNotEmpty)
        .map((s) => Symptom.values[int.parse(s)])
        .toList() ?? [],
    moods: (map['moods'] as String?)
        ?.split(',')
        .where((m) => m.isNotEmpty)
        .map((m) => Mood.values[int.parse(m)])
        .toList() ?? [],
    note: map['note'],
  );
}
