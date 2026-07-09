import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../core/di.dart';
import '../viewmodels/hand_tracker_viewmodel.dart';
import '../widgets/hand_overlay.dart';

class HandTrackerPage extends StatefulWidget {
  const HandTrackerPage({super.key});

  @override
  State<HandTrackerPage> createState() => _HandTrackerPageState();
}

class _HandTrackerPageState extends State<HandTrackerPage>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _permissionGranted = false;
  bool _isStreaming = false;
  late final HandTrackerViewModel _viewModel;
  late AnimationController _blurAnimationController;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<HandTrackerViewModel>();
    _blurAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _blurAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(_blurAnimationController);
    _requestPermissionAndStartCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _viewModel.disposeDetector();
    _blurAnimationController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionAndStartCamera() async {
    final status = await _requestCameraPermission();
    if (status) {
      _permissionGranted = true;
      await _initializeCamera();
    }
    setState(() {});
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();
    await _viewModel.initialize(camera);
    await _startStreaming();

    setState(() {});
  }

  Future<void> _startStreaming() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (_isStreaming) return;

    try {
      await _cameraController!.startImageStream((image) {
        _viewModel.onCameraImage(image);
      });
      _isStreaming = true;
      setState(() {});
    } catch (_) {
      _isStreaming = false;
    }
  }

  // Future<void> _stopStreaming() async {
  //   if (_cameraController == null || !_cameraController!.value.isInitialized) {
  //     return;
  //   }
  //   if (!_isStreaming) return;

  //   try {
  //     await _cameraController!.stopImageStream();
  //   } catch (_) {
  //     // ignore failures when stopping already stopped stream
  //   }
  //   _isStreaming = false;
  //   setState(() {});
  // }

  // Future<void> _switchCamera() async {
  //   try {
  //     await _stopStreaming();
  //     // make sure viewmodel/detector is marked disposed so any pending
  //     // onCameraImage callbacks won't try to use a disposed detector
  //     await _viewModel.disposeDetector();
  //     final cameras = await availableCameras();
  //     final currentLens = _cameraController?.description.lensDirection;
  //     final newLens = currentLens == CameraLensDirection.front
  //         ? CameraLensDirection.back
  //         : CameraLensDirection.front;

  //     final camera = cameras.firstWhere(
  //       (c) => c.lensDirection == newLens,
  //       orElse: () => cameras.first,
  //     );

  //     await _cameraController?.dispose();

  //     _cameraController = CameraController(
  //       camera,
  //       ResolutionPreset.medium,
  //       enableAudio: false,
  //       imageFormatGroup: ImageFormatGroup.yuv420,
  //     );

  //     await _cameraController!.initialize();
  //     await _viewModel.initialize(camera);
  //     await _startStreaming();

  //     setState(() {});
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Error switching camera: $e')));
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HandTrackerViewModel>.value(
      value: _viewModel,
      child: Consumer<HandTrackerViewModel>(
        builder: (context, model, child) {
          if (model.isBlurred &&
              _blurAnimationController.status != AnimationStatus.forward) {
            _blurAnimationController.forward();
          } else if (!model.isBlurred &&
              _blurAnimationController.status != AnimationStatus.reverse) {
            _blurAnimationController.reverse();
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Hand Tracker'), actions: []),
            body: _permissionGranted
                ? _buildCameraView(model)
                : _buildRequestPermission(),
          );
        },
      ),
    );
  }

  Widget _buildRequestPermission() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Camera permission is required'),
          ElevatedButton(
            onPressed: _requestPermissionAndStartCamera,
            child: const Text('Grant permission'),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView(HandTrackerViewModel model) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final mirror =
        _cameraController!.description.lensDirection ==
        CameraLensDirection.front;
    final previewSize = _cameraController!.value.previewSize;
    final previewAspectRatio = previewSize != null
        ? previewSize.height / previewSize.width
        : 9 / 16;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: AspectRatio(
                aspectRatio: previewAspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_cameraController!),
                    AnimatedBuilder(
                      animation: _blurAnimation,
                      builder: (context, child) {
                        return _blurAnimation.value > 0
                            ? BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: _blurAnimation.value,
                                  sigmaY: _blurAnimation.value,
                                ),
                                child: Container(
                                  color: Colors.black.withAlpha(
                                    (_blurAnimation.value / 10 * 0.15 * 255)
                                        .round(),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                    if (model.hands.isNotEmpty)
                      HandOverlay(hands: model.hands, mirror: mirror),
                    if (model.isDetecting)
                      const Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Chip(label: Text('Detecting...')),
                        ),
                      ),
                    if (model.statusMessage != null)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Chip(
                          backgroundColor: Colors.blueAccent.withAlpha(
                            (0.9 * 255).round(),
                          ),
                          label: Text(
                            model.statusMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (model.error != null)
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.black54,
                          child: Text(
                            model.error!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
