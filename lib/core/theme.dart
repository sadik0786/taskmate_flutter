import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemeClass {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF009372);
  static const Color tealGreen = Color(0x5076c8af);
  static const Color secondaryLightBlue = Color(0xFF6dcff6);
  static const Color darkBlue = Color(0xFF5588c7);
  static const Color successColor = Color(0xFF74bb44);
  static const Color warningColor = Color(0xFFfaa749);
  static const Color errorColor = Color(0xFFE53935);

  // Backgrounds
  static const Color darkBgColor = Color(0xFF1E1E1E); // Modern dark surface
  static const Color lightBgColor = Color(0xFFF9FAFB); // Modern light surface

  static const Color darkCardColor = Color(0xFF2C2C2C);
  static const Color lightCardColor = Color(0xFFFFFFFF);

  // Text colors
  static const Color textBlack = Color(0xFF1F2937); // Softer black (gray-800)
  static const Color textWhite = Color(0xFFF9FAFB); // Softer white (gray-50)

  // Common font
  static const String fontFamily = 'OpenSansRegular';

  // Base Text Theme generator
  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w700, color: color, letterSpacing: -1),
      displayMedium: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.5),
      headlineLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600, color: color),
      headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: color),
      titleLarge: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: color),
      titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: color),
      titleSmall: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: color),
      bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: color),
      bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: color),
      bodySmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: color),
      labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: color),
      labelMedium: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: color),
      labelSmall: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: color),
    );
  }

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: lightBgColor,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    cardColor: lightCardColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
      primary: primaryGreen,
      secondary: secondaryLightBlue,
      surface: lightBgColor,
      surfaceContainer: lightCardColor,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBgColor,
      foregroundColor: textBlack,
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: textBlack),
    ),
    textTheme: _buildTextTheme(textBlack),
    fontFamily: fontFamily,
    cardTheme: CardThemeData(
      color: lightCardColor,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
      labelStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: darkBgColor,
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    cardColor: darkCardColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.dark,
      primary: primaryGreen,
      secondary: secondaryLightBlue,
      surface: darkBgColor,
      surfaceContainer: darkCardColor,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBgColor,
      foregroundColor: textWhite,
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: textWhite),
    ),
    textTheme: _buildTextTheme(textWhite),
    fontFamily: fontFamily,
    cardTheme: CardThemeData(
      color: darkCardColor,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade700, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade700, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
      labelStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade300),
    ),
  );
}
