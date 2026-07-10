import 'package:camera/camera.dart';
import 'package:hand_detection/hand_detection.dart';

import '../models/detected_hand_model.dart';

class HandDetectionLocalDataSource {
  static const int _maxDetectionDim = 640;

  late final HandDetector _detector;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      await _detector.dispose();
    }
    _detector = await HandDetector.create(
      landmarkModel: HandLandmarkModel.full,
      enableGestures: true,
      enableTracking: true,
      detectorConf: 0.65,
      palmRoiScale: 2.0,
      minLandmarkScore: 0.7,
      maxDetections: 1,
      gestureMinConfidence: 0.7,
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
      maxDim: _maxDetectionDim,
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
