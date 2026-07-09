import 'package:camera/camera.dart';
import 'package:hand_detection/hand_detection.dart';

import '../models/detected_hand_model.dart';

class HandDetectionLocalDataSource {
  late final HandDetector _detector;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      await _detector.dispose();
    }
    _detector = await HandDetector.create(
      enableGestures: true,
      enableTracking: true,
      detectorConf: 0.4,
      minLandmarkScore: 0.5,
      maxDetections: 2,
      gestureMinConfidence: 0.6,
    );
    _isInitialized = true;
  }

  Future<List<DetectedHandModel>> detectFromCameraImage(
    CameraImage cameraImage,
    CameraDescription description,
  ) async {
    final rotation = _cameraRotation(description.sensorOrientation);
    final hands = await _detector.detectFromCameraImage(
      cameraImage,
      rotation: rotation,
      maxDim: 320,
    );

    return hands.map(DetectedHandModel.fromHand).toList();
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _detector.dispose();
      _isInitialized = false;
    }
  }

  CameraFrameRotation? _cameraRotation(int sensorOrientation) {
    return switch (sensorOrientation) {
      90 => CameraFrameRotation.cw90,
      180 => CameraFrameRotation.cw180,
      270 => CameraFrameRotation.cw270,
      _ => null,
    };
  }
}
