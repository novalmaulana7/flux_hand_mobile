import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../data/models/detected_hand_model.dart';
import '../../data/repositories/hand_detection_repository.dart';

class HandTrackerViewModel extends ChangeNotifier {
  final HandDetectionRepository repository;

  bool _isInitialized = false;
  bool _isDetecting = false;
  List<DetectedHandModel> _hands = [];
  CameraDescription? _cameraDescription;
  String? error;

  HandTrackerViewModel({required this.repository});

  bool get isInitialized => _isInitialized;
  bool get isDetecting => _isDetecting;
  bool get isBlurred => _hands.any((hand) => hand.gesture == 'victory');
  bool get isThumbOk => _hands.any((hand) => hand.gesture == 'thumbUp');
  String? get statusMessage => isThumbOk ? 'OKE' : null;
  List<DetectedHandModel> get hands => _hands;
  CameraDescription? get cameraDescription => _cameraDescription;

  Future<void> initialize(CameraDescription cameraDescription) async {
    _cameraDescription = cameraDescription;
    try {
      await repository.initialize();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> onCameraImage(CameraImage cameraImage) async {
    if (!_isInitialized || _isDetecting || _cameraDescription == null) return;

    _isDetecting = true;
    notifyListeners();

    try {
      _hands = await repository.detectHandsFromCameraImage(
        cameraImage,
        _cameraDescription!,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      _isDetecting = false;
      notifyListeners();
    }
  }

  Future<void> disposeDetector() async {
    await repository.dispose();
    _isInitialized = false;
    notifyListeners();
  }
}
