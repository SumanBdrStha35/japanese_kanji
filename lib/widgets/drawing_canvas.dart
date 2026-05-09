import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;


/// Drawing canvas widget for handwriting input
class DrawingCanvas extends StatefulWidget {
  final Function(Uint8List)? onStrokeComplete;
  final Color penColor;
  final double penWidth;

  const DrawingCanvas({
    super.key,
    this.onStrokeComplete,
    this.penColor = Colors.black,
    this.penWidth = 5,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final List<Offset?> _points = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _points.add(details.localPosition);
        });
      },
      onPanEnd: (details) {
        _points.add(null);
      },
      child: CustomPaint(
        painter: DrawingPainter(
          points: _points,
          penColor: widget.penColor,
          penWidth: widget.penWidth,
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// Custom painter for drawing strokes
class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final Color penColor;
  final double penWidth;

  DrawingPainter({
    required this.points,
    required this.penColor,
    required this.penWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = penColor
      ..strokeWidth = penWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}