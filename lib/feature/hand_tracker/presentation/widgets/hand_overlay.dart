import 'package:flutter/material.dart';
import 'package:hand_detection/hand_detection.dart';

import '../../data/models/detected_hand_model.dart';

class HandOverlay extends StatelessWidget {
  final List<DetectedHandModel> hands;
  final bool mirror;

  const HandOverlay({
    super.key,
    required this.hands,
    required this.mirror,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HandOverlayPainter(
        hands: hands,
        mirror: mirror,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _HandOverlayPainter extends CustomPainter {
  final List<DetectedHandModel> hands;
  final bool mirror;

  _HandOverlayPainter({
    required this.hands,
    required this.mirror,
  });

  Offset _mapPoint(HandLandmark landmark, Size size, Size imageSize) {
    final scaledX = landmark.x * size.width / imageSize.width;
    final scaledY = landmark.y * size.height / imageSize.height;
    return Offset(mirror ? size.width - scaledX : scaledX, scaledY);
  }

  HandLandmark? _findLandmark(
    HandLandmarkType type,
    List<HandLandmark> landmarks,
  ) {
    for (final landmark in landmarks) {
      if (landmark.type == type) {
        return landmark;
      }
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (hands.isEmpty) return;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final linePaint = Paint()
      ..color = const Color(0xFF5FFBD6).withValues(alpha: 0.42)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final strongLinePaint = Paint()
      ..color = const Color(0xFF5FFBD6).withValues(alpha: 0.75)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final nodePaint = Paint()
      ..color = const Color(0xFF5FFBD6)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = const Color(0xFF5FFBD6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    for (final hand in hands) {
      final imageSize = hand.imageSize;
      final wrist = _findLandmark(HandLandmarkType.wrist, hand.landmarks);
      final indexMcp = _findLandmark(
        HandLandmarkType.indexFingerMCP,
        hand.landmarks,
      );
      final indexPip = _findLandmark(
        HandLandmarkType.indexFingerPIP,
        hand.landmarks,
      );
      final indexDip = _findLandmark(
        HandLandmarkType.indexFingerDIP,
        hand.landmarks,
      );
      final indexTip = _findLandmark(
        HandLandmarkType.indexFingerTip,
        hand.landmarks,
      );

      for (final connection in handLandmarkConnections) {
        final start = _findLandmark(connection[0], hand.landmarks);
        final end = _findLandmark(connection[1], hand.landmarks);
        if (start == null || end == null) continue;
        if (start.visibility < 0.2 || end.visibility < 0.2) continue;

        canvas.drawLine(
          _mapPoint(start, size, imageSize),
          _mapPoint(end, size, imageSize),
          connection.contains(HandLandmarkType.indexFingerTip)
              ? strongLinePaint
              : linePaint,
        );
      }

      for (final landmark in hand.landmarks) {
        if (landmark.visibility < 0.2) continue;
        final position = _mapPoint(landmark, size, imageSize);
        canvas.drawCircle(
          position,
          landmark == indexTip ? 5.5 : 3.2,
          nodePaint,
        );
      }

      final target = indexTip ?? indexDip ?? indexPip ?? indexMcp ?? wrist;
      if (target != null) {
        final center = _mapPoint(target, size, imageSize);
        canvas.drawCircle(center, 7, glowPaint);
        canvas.drawCircle(center, 16, linePaint);
        canvas.drawCircle(center, 26, linePaint);

        canvas.drawCircle(center, 3.2, nodePaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HandOverlayPainter oldDelegate) {
    return oldDelegate.hands != hands || oldDelegate.mirror != mirror;
  }
}
