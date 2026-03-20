# 🌸 花期记录 Period Tracker

一款清新柔和风格的经期记录安卓 App，基于 Flutter 开发。

## 功能

- 📅 **日历视图** — 可视化经期、预测经期、排卵日、易孕期
- 📊 **周期统计** — 平均/最短/最长周期、趋势图、历史记录
- 📝 **每日记录** — 流量、9 种症状、6 种情绪状态、备注
- 💡 **健康建议** — 周期规律评估、不规律原因科普、调理建议、就医指引

## 技术栈

| 库 | 用途 |
|---|---|
| `sqflite` | 本地 SQLite 数据库 |
| `provider` | 全局状态管理 |
| `table_calendar` | 日历组件 |
| `fl_chart` | 周期趋势柱状图 |
| `intl` | 中文日期格式化 |

## 项目结构

```
lib/
├── main.dart                    # App 入口
├── models/
│   ├── period.dart              # 经期数据模型
│   └── daily_log.dart           # 每日记录模型（症状/情绪枚举）
├── database/
│   └── db_helper.dart           # SQLite 数据库操作
├── utils/
│   ├── cycle_predictor.dart     # 预测算法（周期/排卵/易孕期）
│   ├── app_state.dart           # Provider 全局状态
│   └── app_theme.dart           # 粉紫主题配置
└── screens/
    ├── home_screen.dart         # 主页（Hero + 导航）
    ├── calendar_screen.dart     # 日历页
    ├── stats_screen.dart        # 统计页
    ├── log_screen.dart          # 记录页
    └── insights_screen.dart     # 健康建议页
```

## 快速上手

### 1. 环境要求

- Flutter SDK ≥ 3.0
- Android Studio 或 VS Code + Flutter 插件
- Android 设备或模拟器（API 21+）

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 运行

```bash
flutter run
```

### 4. 打包 APK

```bash
flutter build apk --release
# 输出路径：build/app/outputs/flutter-apk/app-release.apk
```

## 预测算法说明

`cycle_predictor.dart` 基于以下逻辑预测：

1. **平均周期** = 近 N 次相邻经期开始日期之差的均值（过滤 10–60 天外的异常值）
2. **下次经期** = 上次经期开始日 + 平均周期
3. **排卵日** = 下次经期开始日 − 14 天（黄体期固定约 14 天）
4. **易孕期** = 排卵日前 5 天 ~ 排卵日后 1 天
5. **规律性评估** = 周期最大值 − 最小值：≤7天（规律）、≤14天（轻微不规律）、>14天（不规律）

## 数据隐私

所有数据存储在设备本地 SQLite 数据库，不上传任何服务器。

## 扩展方向

- [ ] 添加小组件（Widget）显示经期倒计时
- [ ] 支持数据导出（CSV/PDF）
- [ ] 体温记录（BBT 基础体温）
- [ ] 通知提醒（经期前 3 天提醒）
- [ ] 多语言支持
