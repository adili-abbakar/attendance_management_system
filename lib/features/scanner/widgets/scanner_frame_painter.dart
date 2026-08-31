
import 'package:flutter/material.dart';

class ScannerFramePainter extends CustomPainter {
  const ScannerFramePainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
  });

  final Color color;
  final double strokeWidth;
  final double cornerLength;

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path
      ..moveTo(0, cornerLength)
      ..lineTo(0, 0)
      ..lineTo(cornerLength, 0)

      ..moveTo(
        size.width - cornerLength,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(
        size.width,
        cornerLength,
      )

      ..moveTo(
        0,
        size.height - cornerLength,
      )
      ..lineTo(
        0,
        size.height,
      )
      ..lineTo(
        cornerLength,
        size.height,
      )

      ..moveTo(
        size.width - cornerLength,
        size.height,
      )
      ..lineTo(
        size.width,
        size.height,
      )
      ..lineTo(
        size.width,
        size.height - cornerLength,
      );

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant ScannerFramePainter oldDelegate,
  ) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerLength != cornerLength;
  }
}

