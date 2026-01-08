import 'package:flutter/material.dart';

class NailPainter extends CustomPainter {
  final double progress; // 0..1

  NailPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0xFF63CCE9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = const Color(0xFF63CCE9).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final headHeight = size.height * 0.06;
    final shaftWidth = size.width * 0.20;
    final shaftLeft = (size.width - shaftWidth) / 2;
    final shaftHeight = size.height * 0.75;
    final shaftBottom = headHeight + shaftHeight;

    final nailPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.15, 0, size.width * 0.7, headHeight),
          const Radius.circular(8),
        ),
      )
      ..addRect(Rect.fromLTWH(shaftLeft, headHeight, shaftWidth, shaftHeight))
      ..moveTo(shaftLeft, shaftBottom)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(shaftLeft + shaftWidth, shaftBottom)
      ..close();

    canvas.save();
    canvas.clipPath(nailPath);

    final p = progress.clamp(0.0, 1.0);
    final fillHeight = size.height * p;
    final fillRect = Rect.fromLTWH(
      0,
      size.height - fillHeight,
      size.width,
      fillHeight,
    );
    canvas.drawRect(fillRect, fillPaint);

    canvas.restore();

    // Contour
    canvas.drawPath(nailPath, stroke);
  }

  @override
  bool shouldRepaint(covariant NailPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
