import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/theme.dart';

class DesktopAppBar extends StatelessWidget {
  final String title;
  final String? userName;
  final VoidCallback onLogout;
  final RxBool isDarkMode;
  final VoidCallback onToggleTheme;
  final List<Widget>? customActions;

  const DesktopAppBar({
    super.key,
    required this.title,
    required this.userName,
    required this.onLogout,
    required this.isDarkMode,
    required this.onToggleTheme,
    this.customActions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final isDark = isDarkMode.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 75.h,
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        decoration: BoxDecoration(
          color: ThemeClass.primaryGreen,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20.sp,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: onToggleTheme,
            ),
            SizedBox(width: 8.w),
            if (customActions != null)
              IconTheme(
                data: const IconThemeData(color: Colors.white),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: customActions!,
                ),
              ),
            SizedBox(width: 16.w),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14.r,
                      backgroundColor: Colors.white,
                      child: Text(
                        userName?.isNotEmpty == true
                            ? userName![0].toUpperCase()
                            : "?",
                        style: TextStyle(
                          color: ThemeClass.primaryGreen,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Hi, ${userName ?? ""}",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? userName;
  final VoidCallback onLogout;
  final RxBool isDarkMode;
  final VoidCallback onToggleTheme;
  final List<Widget>? customActions;

  const MobileAppBar({
    super.key,
    required this.title,
    required this.userName,
    required this.onLogout,
    required this.isDarkMode,
    required this.onToggleTheme,
    this.customActions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: ThemeClass.primaryGreen,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: theme.textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 18.sp,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
          onPressed: onToggleTheme,
        ),
        if (customActions != null) ...customActions!,
        SizedBox(width: 8.w),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
