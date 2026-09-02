import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_mate/widgets/responsive_layout.dart';
import 'dart:math' as math;

class AnimatedDesktopSplitView extends StatefulWidget {
  final Widget child;
  const AnimatedDesktopSplitView({super.key, required this.child});

  @override
  State<AnimatedDesktopSplitView> createState() =>
      _AnimatedDesktopSplitViewState();
}

class _AnimatedDesktopSplitViewState extends State<AnimatedDesktopSplitView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveLayout.isDesktop(context)) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Container(
            margin: EdgeInsets.only(right: 24.w),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainer
                  : theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        0, 15 * math.sin(_controller.value * 2 * math.pi)),
                    child: child,
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(32.w),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 80.sp,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      "Task Mate",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Simplify your workflow intelligently.",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: widget.child,
        ),
      ],
    );
  }
}
