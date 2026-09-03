import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_mate/widgets/responsive_layout.dart';
import 'dart:math' as math;

class AnimatedDesktopSplitView extends StatefulWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final IconData? icon;

  const AnimatedDesktopSplitView({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
  });

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDark = theme.brightness == Brightness.dark;

        final leftSide = Container(
          margin: const EdgeInsets.only(
            left: 24.0,
            top: 24.0,
            bottom: 24.0,
            right: 12.0,
          ),
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
                    0,
                    15 * math.sin(_controller.value * 2 * math.pi),
                  ),
                  child: child,
                );
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(32.w),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon ?? Icons.auto_awesome,
                        size: 80.sp,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      widget.title ?? "Task Mate",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      widget.subtitle ??
                          "Simplify your workflow intelligently.",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        if (constraints.maxHeight == double.infinity) {
          // Parent is unbounded (e.g. inside a SingleChildScrollView).
          // We use Table instead of IntrinsicHeight to prevent crashes when
          // children use LayoutBuilder (like CustomDropdownField).
          return Table(
            columnWidths: const {0: FlexColumnWidth(5), 1: FlexColumnWidth(5)},
            children: [
              TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.fill,
                    child: leftSide,
                  ),
                  TableCell(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Parent is bounded (e.g. profile screen).
          // Take full height so internal ScrollViews can scroll.
          return SizedBox(
            height: constraints.maxHeight,
            child: Row(
              children: [
                Expanded(flex: 4, child: leftSide),
                Expanded(
                  flex: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [Flexible(child: widget.child)],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
