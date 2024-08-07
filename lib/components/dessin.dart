import 'package:flutter/material.dart';

enum AnnotationType {
  Rectangle,
  Circle,
}

class Annotation {
  final AnnotationType type;
  final Rect rect;

  Annotation(this.type, this.rect);
}

class DrawRectangle extends StatelessWidget {
  final Rect rect;

  DrawRectangle(this.rect);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RectanglePainter(rect),
    );
  }
}

class RectanglePainter extends CustomPainter {
  final Rect rect;

  RectanglePainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawEllipse extends StatelessWidget {
  final Rect rect;

  DrawEllipse(this.rect);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: EllipsePainter(rect),
    );
  }
}

class EllipsePainter extends CustomPainter {
  final Rect rect;

  EllipsePainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
