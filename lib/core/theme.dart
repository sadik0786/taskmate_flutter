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
  static const Color darkBgColor = Color(0xFF232323);
  static const Color lightBgColor = Color(0xFFF4F4F4);

  static const Color darkCardColor = Color(0xFF3f3f3f);
  static const Color lightCardColor = Color(0xFFF8F8F8);

  // Text colors
  static const Color textBlack = Color(0xFF484848);
  static const Color textWhite = Color(0xFFffffff);

  // Common font
  static const String fontFamily = 'OpenSansRegular';

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: lightBgColor,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    cardColor: lightCardColor,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryLightBlue,
      surface: lightCardColor,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 1,
      titleTextStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    textTheme: TextTheme(
      bodySmall: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600, color: textWhite),

      titleLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: textWhite),
      titleMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: textWhite),
      titleSmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: textWhite),
    ),
    fontFamily: fontFamily,
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: textWhite, width: 1.w),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.r)),
        borderSide: BorderSide(color: primaryGreen, width: 1.5.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.red, width: 1.w),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.red, width: 1.5.w),
      ),
      fillColor: darkCardColor,
      filled: true,
      // Text styles
      hintStyle: TextStyle(fontSize: 12.sp),
      errorStyle: TextStyle(fontSize: 12.sp),
      labelStyle: TextStyle(fontSize: 14.sp),
      // Counter text style (for maxLength)
      counterStyle: TextStyle(fontSize: 12.sp),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: darkBgColor,
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    cardColor: darkCardColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: secondaryLightBlue,
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
      bodySmall: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600, color: textWhite),
      titleLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: textWhite,
      ),
      titleMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: textWhite,
      ),
      titleSmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: textWhite,
      ),
    ),
    fontFamily: fontFamily,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: primaryGreen),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.r)),
        borderSide: BorderSide(color: primaryGreen),
      ),
      fillColor: darkCardColor,
      filled: true,
    ),
  );
}
