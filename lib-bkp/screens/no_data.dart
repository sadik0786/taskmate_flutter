// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoTasksWidget extends StatefulWidget {
  final String message; 

  const NoTasksWidget({
    super.key,
    this.message = "No tasks found",
  });

  @override
  State<NoTasksWidget> createState() => _NoTasksWidgetState();
}

class _NoTasksWidgetState extends State<NoTasksWidget> with TickerProviderStateMixin {
  late AnimationController _eyeMoveController;
  late Animation<double> _eyeMove;

  late AnimationController _blinkController;
  late Animation<double> _blink;

  @override
  void initState() {
    super.initState();

    // 👀 Left-right movement
    _eyeMoveController = AnimationController(duration: const Duration(seconds: 3), vsync: this)
      ..repeat(reverse: true);

    _eyeMove = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _eyeMoveController, curve: Curves.easeInOut));

    // 👁️ Blink
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _blink = Tween<double>(
      begin: 1.0,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut));

    _scheduleBlink();
  }

  void _scheduleBlink() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: 2 + Random().nextInt(5)));
      if (mounted) {
        await _blinkController.forward();
        await _blinkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _eyeMoveController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  Widget _buildEye() {
    return AnimatedBuilder(
      animation: Listenable.merge([_eyeMove, _blink]),
      builder: (context, child) {
        return Transform.scale(
          scaleY: _blink.value, 
          child: Container(
            width: 50.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Align(
              alignment: Alignment(_eyeMove.value / 10, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // iris
                  Container(
                    width: 26.w,
                    height: 26.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.blue, Colors.black],
                        center: Alignment(-0.2, -0.2),
                        radius: 0.8,
                      ),
                    ),
                  ),
                  // pupil
                  Container(
                    width: 14.w,
                    height: 14.h,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                  ),
                  // shine (gloss highlight)
                  Positioned(
                    top: 6.h,
                    left: 8.w,
                    child: Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEye(),
              SizedBox(width: 10.w),
              _buildEye(),
            ],
          ),
          SizedBox(height: 20.h),
          AnimatedBuilder(
            animation: _blink,
            builder: (context, child) {
              final wiggle = (_blink.value < 0.9)
                  ? sin(DateTime.now().millisecondsSinceEpoch / 80) * 0.1
                  : 0.0;
              return Transform.rotate(angle: wiggle, child: child);
            },
            child: Text(
              widget.message,
              style: Theme.of(context).textTheme.titleLarge,
              // style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}
