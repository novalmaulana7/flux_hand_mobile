import 'dart:ui';

import 'package:hand_detection/hand_detection.dart';

class DetectedHandModel {
  final Rect boundingBox;
  final double score;
  final List<HandLandmark> landmarks;
  final String? handedness;
  final String? gesture;
  final Size imageSize;

  const DetectedHandModel({
    required this.boundingBox,
    required this.score,
    required this.landmarks,
    required this.imageSize,
    this.handedness,
    this.gesture,
  });

  factory DetectedHandModel.fromHand(Hand hand) {
    final boundingBox = Rect.fromLTRB(
      hand.boundingBox.left.toDouble(),
      hand.boundingBox.top.toDouble(),
      hand.boundingBox.right.toDouble(),
      hand.boundingBox.bottom.toDouble(),
    );

    return DetectedHandModel(
      boundingBox: boundingBox,
      score: hand.score,
      landmarks: hand.landmarks,
      handedness: hand.handedness?.name,
      gesture: hand.gesture?.type.name,
      imageSize: Size(hand.imageWidth.toDouble(), hand.imageHeight.toDouble()),
    );
  }
}
