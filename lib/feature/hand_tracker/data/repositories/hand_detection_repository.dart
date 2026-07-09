import 'package:camera/camera.dart';

import '../models/detected_hand_model.dart';

abstract class HandDetectionRepository {
  Future<void> initialize();
  Future<List<DetectedHandModel>> detectHandsFromCameraImage(
    CameraImage cameraImage,
    CameraDescription description,
  );
  Future<void> dispose();
}
