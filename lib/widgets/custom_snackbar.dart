import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/theme.dart';

class CustomSnackBar {
  static void show({
    String? title,
    required String message,
    Color? backgroundColor,
    IconData? icon,
    int durationInSeconds = 3,
  }) {
    final isDark = Get.isDarkMode;

    Get.snackbar(
      title ?? '',
      message,
      titleText: title == null || title.isEmpty
          ? const SizedBox.shrink() // hides title widget
          : Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
      snackPosition: SnackPosition.TOP,
      backgroundColor:
          backgroundColor ?? (isDark ? ThemeClass.darkCardColor : ThemeClass.lightCardColor),
      colorText: isDark ? ThemeClass.textWhite : ThemeClass.textBlack,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: Duration(seconds: durationInSeconds),
      icon: Icon(icon, color: isDark ? ThemeClass.textWhite : ThemeClass.textBlack),
      shouldIconPulse: true,
    );
  }

  /// ✅ Success Snackbar (Green)
  static void success(String message, {String? title = "Success"}) {
    final isDark = Get.isDarkMode;
    show(
      title: title,
      message: message,
      backgroundColor: isDark ? ThemeClass.primaryGreen : ThemeClass.successColor,
      icon: Icons.check_circle_outline,
    );
  }

  /// ❌ Error Snackbar (Red)
  static void error(String message, {String? title = "Error"}) {
    final isDark = Get.isDarkMode;
    show(
      title: title,
      message: message,
      backgroundColor: isDark ? ThemeClass.errorColor : ThemeClass.errorColor,
      icon: Icons.error_outline,
    );
  }

  /// ⚠️ Warning Snackbar (Orange)
  static void warning(String message, {String? title = "Warning"}) {
    final isDark = Get.isDarkMode;
    show(
      title: title,
      message: message,
      backgroundColor: isDark ? ThemeClass.warningColor : ThemeClass.warningColor,
      icon: Icons.warning_amber_rounded,
    );
  }

  /// ℹ️ Info Snackbar (Blue)
  static void info(String message, {String? title = "Info"}) {
    final isDark = Get.isDarkMode;
    show(
      title: title,
      message: message,
      backgroundColor: isDark ? ThemeClass.darkBlue : ThemeClass.darkBlue,
      icon: Icons.info_outline,
    );
  }
}

// CustomSnackBar.show(
//   title: "Notice",
//   message: "Server will restart at 2 AM",
//   backgroundColor: Colors.purple,
//   icon: Icons.notifications_active,
// );
// CustomSnackBar.success("Employee added successfully!");
// CustomSnackBar.error("Failed to load data. Try again.");
// CustomSnackBar.warning("Please fill all required fields");
// CustomSnackBar.info("New version available!");
