import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/models/detected_hand_model.dart';
import '../../data/repositories/hand_detection_repository.dart';

class HandTrackerViewModel extends ChangeNotifier {
  final HandDetectionRepository repository;

  bool _isInitialized = false;
  bool _isDetecting = false;
  bool _permissionGranted = false;
  bool _isStreaming = false;
  List<DetectedHandModel> _hands = [];
  CameraDescription? _cameraDescription;
  CameraController? _cameraController;
  String? error;
  double? _latestLatencyMs;
  String? _toastMessage;
  bool _wasThumbUp = false;
  Timer? _toastTimer;

  HandTrackerViewModel({required this.repository});

  bool get isInitialized => _isInitialized;
  bool get isDetecting => _isDetecting;
  bool get permissionGranted => _permissionGranted;
  bool get isStreaming => _isStreaming;
  bool get isBlurred => _hands.any((hand) => hand.gesture == 'victory');
  bool get isFist => _hands.any((hand) => hand.gesture == 'closedFist');
  bool get isThumbOk => _hands.any((hand) => hand.gesture == 'thumbUp');
  String get gestureLabel => _gestureLabel(primaryHand);
  String? get statusMessage => isThumbOk ? 'OKE' : null;
  List<DetectedHandModel> get hands => _hands;
  DetectedHandModel? get primaryHand =>
      _hands.isEmpty ? null : _hands.reduce((a, b) => a.score >= b.score ? a : b);
  CameraDescription? get cameraDescription => _cameraDescription;
  CameraController? get cameraController => _cameraController;
  double? get latestLatencyMs => _latestLatencyMs;
  String? get toastMessage => _toastMessage;

  Future<void> initializeSession() async {
    final granted = await Permission.camera.request();
    _permissionGranted = granted.isGranted;
    notifyListeners();

    if (!_permissionGranted) {
      return;
    }

    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraDescription = camera;
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      await repository.initialize();
      _isInitialized = true;
      await _startStreaming();
    } catch (e) {
      error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> _startStreaming() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (_isStreaming) return;

    try {
      await _cameraController!.startImageStream((image) {
        onCameraImage(image);
      });
      _isStreaming = true;
    } catch (e) {
      error = e.toString();
      _isStreaming = false;
    }
  }

  Future<void> stopStreaming() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (!_isStreaming) return;

    try {
      await _cameraController!.stopImageStream();
    } catch (_) {
      // Ignore camera lifecycle races.
    }

    _isStreaming = false;
    notifyListeners();
  }

  Future<void> toggleStreaming() async {
    if (_isStreaming) {
      await stopStreaming();
    } else {
      await _startStreaming();
      notifyListeners();
    }
  }

  Future<void> onCameraImage(CameraImage cameraImage) async {
    if (!_isInitialized || _isDetecting || _cameraDescription == null) return;

    _isDetecting = true;
    notifyListeners();

    try {
      final startedAt = DateTime.now();
      _hands = await repository.detectHandsFromCameraImage(
        cameraImage,
        _cameraDescription!,
      );
      _latestLatencyMs =
          DateTime.now().difference(startedAt).inMicroseconds / 1000;
      _handleThumbToast();
    } catch (e) {
      error = e.toString();
    } finally {
      _isDetecting = false;
      notifyListeners();
    }
  }

  Future<void> disposeSession() async {
    _toastTimer?.cancel();
    _toastTimer = null;

    try {
      await stopStreaming();
    } catch (_) {
      // ignore
    }

    await _cameraController?.dispose();
    _cameraController = null;

    await repository.dispose();
    _isInitialized = false;
    _permissionGranted = false;
    notifyListeners();
  }

  void _handleThumbToast() {
    final isThumbUp = _hands.any((hand) => hand.gesture == 'thumbUp');
    if (isThumbUp && !_wasThumbUp) {
      _wasThumbUp = true;
      _toastMessage = '👍 Jempol terdeteksi';
      _toastTimer?.cancel();
      _toastTimer = Timer(const Duration(milliseconds: 900), () {
        _toastMessage = null;
        notifyListeners();
      });
      return;
    }

    if (!isThumbUp) {
      _wasThumbUp = false;
    }
  }

  String _gestureLabel(DetectedHandModel? hand) {
    final gesture = hand?.gesture;
    if (gesture == null || gesture.isEmpty) {
      return '--';
    }

    if (gesture == 'thumbUp') return 'THUMB';
    if (gesture == 'victory') return 'BLUR';
    if (gesture == 'closedFist') return 'FIST';
    return gesture
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match.group(1)}_${match.group(2)}',
        )
        .toUpperCase();
  }
}
