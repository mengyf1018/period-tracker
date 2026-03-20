// lib/utils/app_theme.dart
// 清新柔和粉紫主题

import 'package:flutter/material.dart';

class AppTheme {
  // 主色调
  static const pink = Color(0xFFD4537E);
  static const pinkLight = Color(0xFFF4C0D1);
  static const pinkPale = Color(0xFFFBEAF0);
  static const purple = Color(0xFF7F77DD);
  static const purpleLight = Color(0xFFCECBF6);
  static const purplePale = Color(0xFFEEEDFE);
  static const purpleDark = Color(0xFF3C3489);

  // 语义色
  static const ovulationColor = Color(0xFF1D9E75);
  static const fertileColor = Color(0xFF639922);
  static const warnColor = Color(0xFFBA7517);
  static const okColor = Color(0xFF3B6D11);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: pink,
      primary: pink,
      secondary: purple,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF8FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: purpleDark,
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(color: purpleDark),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: pinkPale,
      side: BorderSide(color: Colors.grey.shade300, width: 0.5),
      labelStyle: const TextStyle(fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: pink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: pinkPale,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
              color: pink, fontSize: 11, fontWeight: FontWeight.w500);
        }
        return TextStyle(color: Colors.grey.shade500, fontSize: 11);
      }),
    ),
  );
}
