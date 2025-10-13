import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? userName;
  final VoidCallback onLogout;
  final RxBool isDarkMode;
  final VoidCallback onToggleTheme;

  const CommonAppBar({
    super.key,
    required this.title,
    required this.userName,
    required this.onLogout,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700, fontSize: 18.sp),
      ),
      actions: [
        Text(
          "Hi, ${userName ?? ""}  ",
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700, fontSize: 16.sp),
        ),
        // Obx(
        //   () => IconButton(
        //     icon: Icon(isDarkMode.value ? Icons.light_mode : Icons.dark_mode),
        //     onPressed: onToggleTheme,
        //   ),
        // ),
        // IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
      ],
    );
  }

  // Required when implementing PreferredSizeWidget
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
