import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';

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
  bool _wasThumbUp = false;

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
  DetectedHandModel? get primaryHand => _hands.isEmpty
      ? null
      : _hands.reduce((a, b) => a.score >= b.score ? a : b);
  CameraDescription? get cameraDescription => _cameraDescription;
  CameraController? get cameraController => _cameraController;
  double? get latestLatencyMs => _latestLatencyMs;

  Future<void> initializeSession(BuildContext context) async {
    final granted = await Permission.camera.request();
    _permissionGranted = granted.isGranted;
    notifyListeners();

    if (!_permissionGranted) {
      return;
    }

    if (context.mounted) {
      await _initializeCamera(context);
    }
  }

  Future<void> _initializeCamera(BuildContext context) async {
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

      if (context.mounted) {
        await _startStreaming(context);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> _startStreaming(BuildContext context) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (_isStreaming) return;

    try {
      await _cameraController!.startImageStream((image) {
        onCameraImage(context, image);
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

  Future<void> toggleStreaming(BuildContext context) async {
    if (_isStreaming) {
      await stopStreaming();
    } else {
      await _startStreaming(context);
      notifyListeners();
    }
  }

  Future<void> onCameraImage(
    BuildContext context,
    CameraImage cameraImage,
  ) async {
    if (!_isInitialized || _isDetecting || _cameraDescription == null) return;

    _isDetecting = true;
    notifyListeners();

    try {
      final startedAt = DateTime.now();
      final detectedHands = await repository.detectHandsFromCameraImage(
        cameraImage,
        _cameraDescription!,
      );
      _hands = _filterHands(detectedHands);
      _latestLatencyMs =
          DateTime.now().difference(startedAt).inMicroseconds / 1000;

      if (context.mounted) {
        _handleThumbToast(context);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      _isDetecting = false;
      notifyListeners();
    }
  }

  Future<void> disposeSession() async {
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

  void _handleThumbToast(BuildContext context) {
    final isThumbUp = _hands.any((hand) => hand.gesture == 'thumbUp');
    if (isThumbUp && !_wasThumbUp) {
      _wasThumbUp = true;
      toastification.show(
        context: context,
        // Use a custom primaryColor so flatColored's background (primary.shade50)
        // becomes the light green you expect. Provide a darker border via
        // `borderSide` and a dark foreground color for the text/icon.
        primaryColor: const Color(0xFF2ECC71), // custom green
        foregroundColor: const Color(0xFF1E8449),
        borderSide: const BorderSide(color: Color(0xFF1E8449), width: 1.5),
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        title: const Text('Thumbs Up Detected!'),
        icon: const Text('👍', style: TextStyle(fontSize: 20)),
        autoCloseDuration: const Duration(seconds: 3),
        showIcon: true,
      );
      return;
    }

    if (!isThumbUp) {
      _wasThumbUp = false;
    }
  }

  List<DetectedHandModel> _filterHands(List<DetectedHandModel> hands) {
    return hands.where((hand) {
      return hand.score >= 0.7 && (hand.gesture?.isNotEmpty ?? false);
    }).toList();
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
