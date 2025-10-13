import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemeClass {
  // Brand Colors
  static const Color primaryColor = Color(0xFF0288D1);
  static const Color secondaryColor = Color(0xFF4DD0E1);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color errorColor = Color(0xFFE53935);

  // Backgrounds
  static const Color lightBackgroundColor = Color(0xFFF8F9FA);
  static const Color lightCardColor = Color(0xFFFFFFFF);

  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);

  // Text colors
  static const Color textPrimaryDark = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF6C757D);

  // Common font
  static const String fontFamily = 'OpenSansRegular';

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: lightBackgroundColor,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    cardColor: lightCardColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightCardColor,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 1,
      titleTextStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: textPrimaryDark),
      titleMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: textPrimaryDark),
      titleSmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: textPrimaryDark),
    ),
    fontFamily: fontFamily,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
        borderSide: BorderSide(color: primaryColor, width: 1.5.w),
      ),
      fillColor: Colors.white,
      filled: true,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: darkBackgroundColor,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    cardColor: darkCardColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkCardColor,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkCardColor,
      foregroundColor: Colors.white,
      elevation: 1,
      titleTextStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: textSecondaryLight,
      ),
      titleMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: textSecondaryLight,
      ),
      titleSmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: textSecondaryLight,
      ),
    ),
    fontFamily: fontFamily,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
        borderSide: BorderSide(color: primaryColor, width: 1.5.w),
      ),
      fillColor: darkCardColor,
      filled: true,
    ),
  );
}
