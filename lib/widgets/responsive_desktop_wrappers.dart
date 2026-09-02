import 'package:flutter/material.dart';
import 'package:task_mate/widgets/responsive_layout.dart';
import 'package:task_mate/widgets/animated_desktop_split_view.dart';

/// Wraps a form/content column to restrict its width on desktop screens.
class ResponsiveFormWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool wrapInCardOnDesktop;
  final EdgeInsetsGeometry? padding;

  const ResponsiveFormWrapper({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.wrapInCardOnDesktop = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context) ||
        ResponsiveLayout.isTablet(context);

    if (isDesktop) {
      return Center(
        child: AnimatedDesktopSplitView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: wrapInCardOnDesktop
                ? Card(
                    elevation: 4,
                    margin: padding ?? const EdgeInsets.all(24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: child,
                    ),
                  )
                : Padding(
                    padding: padding ?? const EdgeInsets.all(24.0),
                    child: child,
                  ),
          ),
        ),
      );
    }

    return Padding(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: child,
    );
  }
}

/// Automatically converts a ListView to a GridView on desktop screens.
class ResponsiveGridListWrapper extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final double desktopChildAspectRatio;
  final int Function(double width)? customCrossAxisCount;
  final bool allowDynamicHeight;

  const ResponsiveGridListWrapper({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.desktopChildAspectRatio = 1.0,
    this.customCrossAxisCount,
    this.allowDynamicHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 600;

        if (isDesktop) {
          int crossAxisCount = 2;
          if (customCrossAxisCount != null) {
            crossAxisCount = customCrossAxisCount!(constraints.maxWidth);
          } else {
            if (constraints.maxWidth >= 1200) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth >= 900) {
              crossAxisCount = 3;
            } else {
              crossAxisCount = 2;
            }
          }

          if (allowDynamicHeight) {
            final double spacing = 16.0;
            final double itemWidth = (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) / crossAxisCount;
            
            Widget wrap = Wrap(
              spacing: spacing,
              runSpacing: spacing,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: List.generate(itemCount, (index) {
                return SizedBox(
                  width: itemWidth,
                  child: itemBuilder(context, index),
                );
              }),
            );

            if (!shrinkWrap) {
              return SingleChildScrollView(
                physics: physics,
                padding: padding,
                child: wrap,
              );
            } else {
              return Padding(
                padding: padding ?? EdgeInsets.zero,
                child: wrap,
              );
            }
          }

          return GridView.builder(
            shrinkWrap: shrinkWrap,
            physics: physics,
            padding: padding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: desktopChildAspectRatio,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          );
        }

        return ListView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          padding: padding,
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
