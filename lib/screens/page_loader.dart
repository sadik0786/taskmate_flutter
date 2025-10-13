import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageLoader extends StatefulWidget {
  const PageLoader({super.key});

  @override
  State<PageLoader> createState() => _PageLoaderState();
}

class _PageLoaderState extends State<PageLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _ripple(double phase) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // wrap the progress with a phase shift
        final t = (_controller.value + phase) % 1.0;
        final size = 40.0 + (t * 120.0);
        final opacity = (1.0 - t).clamp(0.0, 1.0);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // ignore: deprecated_member_use
            color: Colors.blue.withOpacity(opacity * 0.5),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          _ripple(0.00), // first wave
          _ripple(0.33), // second wave (phase shifted)
          _ripple(0.66), // third wave
          Container(
            width: 50.w,
            height: 50.h,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
            child: Icon(Icons.access_time, color: Colors.white, size: 50.sp),
          ),
        ],
      ),
    );
  }
}
