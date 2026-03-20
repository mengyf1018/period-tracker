// lib/screens/insights_screen.dart
// 健康建议页面：周期不规律原因 + 科普 + 调理建议

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import '../utils/app_theme.dart';
import '../utils/cycle_predictor.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pred = state.prediction;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (pred != null) _buildRegularityBanner(pred.regularity),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: '💡',
            title: '什么是经期不规律？',
            body:
                '正常月经周期为 21–35 天，经期持续 2–7 天。若周期持续短于 21 天或长于 35 天、每次波动超过 7 天，或连续 3 个月经期消失，则视为不规律。',
            bgColor: AppTheme.purplePale,
            borderColor: AppTheme.purpleLight,
            titleColor: AppTheme.purpleDark,
            bodyColor: const Color(0xFF534AB7),
          ),
          const SizedBox(height: 12),
          _buildCausesCard(),
          const SizedBox(height: 12),
          _buildTipsCard(),
          const SizedBox(height: 12),
          _buildWhenToSeeDoctor(),
        ],
      ),
    );
  }

  Widget _buildRegularityBanner(CycleRegularity regularity) {
    Color bg;
    Color border;
    Color titleColor;
    Color bodyColor;
    String icon;

    switch (regularity) {
      case CycleRegularity.regular:
        bg = const Color(0xFFEAF3DE);
        border = const Color(0xFFC0DD97);
        titleColor = AppTheme.okColor;
        bodyColor = const Color(0xFF3B6D11);
        icon = '✅';
        break;
      case CycleRegularity.slightlyIrregular:
        bg = const Color(0xFFFAEEDA);
        border = const Color(0xFFFAC775);
        titleColor = AppTheme.warnColor;
        bodyColor = const Color(0xFF854F0B);
        icon = '⚠️';
        break;
      case CycleRegularity.irregular:
        bg = AppTheme.pinkPale;
        border = AppTheme.pinkLight;
        titleColor = const Color(0xFF72243E);
        bodyColor = const Color(0xFF993556);
        icon = '⚠️';
        break;
      case CycleRegularity.insufficient:
        bg = AppTheme.purplePale;
        border = AppTheme.purpleLight;
        titleColor = AppTheme.purpleDark;
        bodyColor = const Color(0xFF534AB7);
        icon = '📊';
    }

    return _buildInfoCard(
      icon: icon,
      title: regularity.label,
      body: regularity.description,
      bgColor: bg,
      borderColor: border,
      titleColor: titleColor,
      bodyColor: bodyColor,
    );
  }

  Widget _buildInfoCard({
    required String icon,
    required String title,
    required String body,
    required Color bgColor,
    required Color borderColor,
    required Color titleColor,
    required Color bodyColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: titleColor)),
            ],
          ),
          const SizedBox(height: 8),
          Text(body,
              style: TextStyle(
                  fontSize: 12, color: bodyColor, height: 1.7)),
        ],
      ),
    );
  }

  Widget _buildCausesCard() {
    final causes = [
      ('😰 压力过大', '皮质醇升高会干扰雌激素与孕激素的分泌，导致排卵延迟或月经推迟。'),
      ('⚖️ 体重骤变', '过度节食或暴饮暴食会扰乱下丘脑-垂体-卵巢轴，影响激素水平。'),
      ('😴 睡眠不足', '褪黑素与促性腺激素紧密相关，长期熬夜可打乱排卵节律。'),
      ('🏃 过度运动', '高强度训练导致体脂过低，可引发功能性下丘脑闭经。'),
      ('🔬 多囊卵巢综合征', '最常见的妇科内分泌疾病，以月经稀发、雄激素过高为特征，需医学诊断。'),
      ('🦋 甲状腺问题', '甲状腺功能亢进或低下均可影响月经周期规律性。'),
      ('💊 药物影响', '避孕药、抗抑郁药、抗凝血药等多种药物可影响月经周期。'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.pinkPale,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.pinkLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('⚠️', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('不规律的常见原因',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A1528))),
            ],
          ),
          const SizedBox(height: 12),
          ...causes.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.$1,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF72243E))),
                          const SizedBox(height: 2),
                          Text(c.$2,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF993556),
                                  height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    final tips = [
      '保持规律作息，每晚保证 7–8 小时睡眠',
      '均衡饮食，经期前后补充铁、镁、维生素B6',
      '适度运动，推荐瑜伽、散步、游泳',
      '学会压力管理，冥想、深呼吸均有帮助',
      '减少咖啡因与高糖食品，尤其在经期前',
      '保持健康体重，避免极端节食',
      '坚持记录，积累至少 3 个周期的数据以获得更准确的预测',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3DE),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFC0DD97), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🌿', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('日常调理建议',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF173404))),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            color: Color(0xFF3B6D11), fontSize: 12)),
                    Expanded(
                      child: Text(t,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF3B6D11),
                              height: 1.5)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildWhenToSeeDoctor() {
    final signs = [
      '周期持续短于 21 天或长于 35 天',
      '连续 3 个月经期消失（非怀孕）',
      '经量异常增多，需每小时更换卫生巾',
      '经期疼痛剧烈，影响日常生活',
      '经期持续超过 7 天',
      '两次月经之间有不规则出血',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAEEDA),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFFAC775), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🏥', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('这些情况请及时就医',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF633806))),
            ],
          ),
          const SizedBox(height: 10),
          ...signs.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            color: Color(0xFF854F0B), fontSize: 12)),
                    Expanded(
                      child: Text(s,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF854F0B),
                              height: 1.5)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
