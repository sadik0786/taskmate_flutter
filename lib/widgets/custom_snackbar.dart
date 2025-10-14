import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static void show({
    required String title,
    required String message,
    Color? backgroundColor,
    IconData? icon,
    int durationInSeconds = 3,
  }) {
    final isDark = Get.isDarkMode;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor ?? (isDark ? Colors.grey[800] : Colors.grey[300]),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: Duration(seconds: durationInSeconds),
      icon: Icon(icon, color: Colors.white),
      shouldIconPulse: true,
    );
  }

  /// ✅ Success Snackbar (Green)
  static void success(String message, {String title = "Success"}) {
    final isDark = Get.isDarkMode;
    show(
      title: title,
      message: message,
      backgroundColor: isDark ? Colors.green[700] : Colors.green,
      icon: Icons.check_circle_outline,
    );
  }

  /// ❌ Error Snackbar (Red)
  static void error(String message, {String title = "Error"}) {
    final isDark = Get.isDarkMode;
    show(
      title: title,
      message: message,
      backgroundColor: isDark ? Colors.red[700] : Colors.red,
      icon: Icons.error_outline,
    );
  }

  /// ⚠️ Warning Snackbar (Orange)
  static void warning(String message, {String title = "Warning"}) {
    final isDark = Get.isDarkMode;
    show(
      title: title,
      message: message,
      backgroundColor: isDark ? Colors.orange[700] : Colors.orange,
      icon: Icons.warning_amber_rounded,
    );
  }

  /// ℹ️ Info Snackbar (Blue)
  static void info(String message, {String title = "Info"}) {
    final isDark = Get.isDarkMode;
    show(
      title: title,
      message: message,
      backgroundColor: isDark ? Colors.blue[700] : Colors.blue,
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
