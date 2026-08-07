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
    return Container(
      height: 70.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode.value
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
            ),
          ),
          const Spacer(),
          if (customActions != null) ...customActions!,
          SizedBox(width: 16.w),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDarkMode.value
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14.r,
                    backgroundColor: ThemeClass.primaryGreen,
                    child: Text(
                      userName?.isNotEmpty == true
                          ? userName![0].toUpperCase()
                          : "?",
                      style: TextStyle(
                        color: Colors.white,
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
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
      title: Text(
        title,
        style: theme.textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 18.sp,
          color: Colors.white,
        ),
      ),
      actions: [
        if (customActions != null) ...customActions!,
        SizedBox(width: 8.w),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
