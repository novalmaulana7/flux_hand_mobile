import 'package:flutter/material.dart';
import 'package:hand_detection/hand_detection.dart';
import '../../data/models/detected_hand_model.dart';

class HandOverlay extends StatelessWidget {
  final List<DetectedHandModel> hands;
  final bool mirror;

  const HandOverlay({super.key, required this.hands, required this.mirror});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HandOverlayPainter(hands, mirror),
      child: const SizedBox.expand(),
    );
  }
}

class _HandOverlayPainter extends CustomPainter {
  final List<DetectedHandModel> hands;
  final bool mirror;

  _HandOverlayPainter(this.hands, this.mirror);

  Offset _mapPoint(HandLandmark landmark, Size size, Size imageSize) {
    final double x = landmark.x;
    final double y = landmark.y;
    final double scaledX = x * size.width / imageSize.width;
    final double scaledY = y * size.height / imageSize.height;
    return Offset(mirror ? size.width - scaledX : scaledX, scaledY);
  }

  Rect _mapRect(Rect rect, Size size, Size imageSize) {
    final left = rect.left * size.width / imageSize.width;
    final top = rect.top * size.height / imageSize.height;
    final right = rect.right * size.width / imageSize.width;
    final bottom = rect.bottom * size.height / imageSize.height;

    if (mirror) {
      return Rect.fromLTRB(size.width - right, top, size.width - left, bottom);
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  HandLandmark? _findLandmark(
    HandLandmarkType type,
    List<HandLandmark> landmarks,
  ) {
    for (final landmark in landmarks) {
      if (landmark.type == type) return landmark;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (hands.isEmpty) return;

    final boxPaint = Paint()
      ..color = Colors.greenAccent.withAlpha((0.9 * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final landmarkPaint = Paint()
      ..color = Colors.pinkAccent
      ..style = PaintingStyle.fill;

    final skeletonPaint = Paint()
      ..color = Colors.lightGreenAccent.withAlpha((0.9 * 255).round())
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    for (final hand in hands) {
      final imageSize = hand.imageSize;
      final rect = _mapRect(hand.boundingBox, size, imageSize);
      canvas.drawRect(rect, boxPaint);

      for (final connection in handLandmarkConnections) {
        final start = _findLandmark(connection[0], hand.landmarks);
        final end = _findLandmark(connection[1], hand.landmarks);
        if (start != null && end != null) {
          if (start.visibility > 0.3 && end.visibility > 0.3) {
            canvas.drawLine(
              _mapPoint(start, size, imageSize),
              _mapPoint(end, size, imageSize),
              skeletonPaint,
            );
          }
        }
      }

      for (final landmark in hand.landmarks) {
        final position = _mapPoint(landmark, size, imageSize);
        canvas.drawCircle(position, 4, landmarkPaint);
      }

      final label = <String>[];
      if (hand.handedness != null) {
        label.add(hand.handedness!);
      }
      if (hand.gesture != null) {
        label.add(hand.gesture!);
      }
      label.add('score ${hand.score.toStringAsFixed(2)}');

      textPainter.text = TextSpan(
        text: label.join(' • '),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left, rect.top - textPainter.height - 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HandOverlayPainter oldDelegate) {
    return oldDelegate.hands != hands || oldDelegate.mirror != mirror;
  }
}
