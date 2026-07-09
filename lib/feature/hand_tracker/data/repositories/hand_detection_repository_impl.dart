import 'package:camera/camera.dart';

import '../datasources/hand_detection_local_data_source.dart';
import '../models/detected_hand_model.dart';
import 'hand_detection_repository.dart';

class HandDetectionRepositoryImpl implements HandDetectionRepository {
  final HandDetectionLocalDataSource source;

  HandDetectionRepositoryImpl({required this.source});

  @override
  Future<void> initialize() => source.initialize();

  @override
  Future<List<DetectedHandModel>> detectHandsFromCameraImage(
    CameraImage cameraImage,
    CameraDescription description,
  ) => source.detectFromCameraImage(cameraImage, description);

  @override
  Future<void> dispose() => source.dispose();
}
