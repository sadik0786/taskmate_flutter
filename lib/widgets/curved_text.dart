import 'dart:math' as math;
import 'package:flutter/material.dart';

class CurvedText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final double radius;
  final bool isTop;

  const CurvedText({
    super.key,
    required this.text,
    required this.textStyle,
    required this.radius,
    this.isTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ArcTextPainter(
        text: text,
        textStyle: textStyle,
        radius: radius,
        isTop: isTop,
      ),
    );
  }
}

class _ArcTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final double radius;
  final bool isTop;

  _ArcTextPainter({
    required this.text,
    required this.textStyle,
    required this.radius,
    required this.isTop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Translate to the center of the widget
    canvas.translate(size.width / 2, size.height / 2);

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Measure each character to find the total angle accurately
    double totalAngle = 0;
    List<double> charWidths = [];
    final double extraSpacing = textStyle.letterSpacing ?? 1.5;

    for (int i = 0; i < text.length; i++) {
      textPainter.text = TextSpan(text: text[i], style: textStyle);
      textPainter.layout();
      double cw = textPainter.width + extraSpacing;
      charWidths.add(cw);
      totalAngle += cw / radius;
    }

    // Start drawing
    final double startAngle = isTop ? -math.pi / 2 : math.pi / 2;

    // For bottom text, Left is theta > pi/2, Right is theta < pi/2. We draw Left to Right (decrease angle).
    // For top text, Left is theta < -pi/2, Right is theta > -pi/2. We draw Left to Right (increase angle).
    double currentAngle = isTop
        ? startAngle - (totalAngle / 2)
        : startAngle + (totalAngle / 2);

    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      textPainter.text = TextSpan(text: char, style: textStyle);
      textPainter.layout();

      final double charWidth = textPainter.width;
      final double charAngle = charWidths[i] / radius;

      // Center the character horizontally within its angular slice
      final double paintAngle = isTop
          ? currentAngle + charAngle / 2
          : currentAngle - charAngle / 2;

      canvas.save();

      // Move to the point on the circumference
      canvas.translate(
        radius * math.cos(paintAngle),
        radius * math.sin(paintAngle),
      );

      // Rotate the canvas so the character stands upright relative to the center.
      if (isTop) {
        canvas.rotate(paintAngle + (math.pi / 2));
        // Center the character exactly on the radius line
        textPainter.paint(
          canvas,
          Offset(-charWidth / 2, -textPainter.height / 2),
        );
      } else {
        canvas.rotate(paintAngle - (math.pi / 2));
        // Center the character exactly on the radius line
        textPainter.paint(
          canvas,
          Offset(-charWidth / 2, -textPainter.height / 2),
        );
      }

      canvas.restore();

      if (isTop) {
        currentAngle += charAngle;
      } else {
        currentAngle -= charAngle;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ArcTextPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.radius != radius ||
        oldDelegate.isTop != isTop;
  }
}
