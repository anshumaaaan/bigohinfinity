// Add this class to the camera_screen.dart file

import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final int horizontalLines;
  final int verticalLines;

  GridPainter(this.horizontalLines, this.verticalLines);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..strokeWidth = 1.0;

    // Draw horizontal lines
    final double horizontalSpacing = size.height / horizontalLines;
    for (int i = 1; i < horizontalLines; i++) {
      final double y = horizontalSpacing * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    final double verticalSpacing = size.width / verticalLines;
    for (int i = 1; i < verticalLines; i++) {
      final double x = verticalSpacing * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
