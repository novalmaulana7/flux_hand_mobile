import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../viewmodels/hand_tracker_viewmodel.dart';
import 'hand_overlay.dart';
import 'hand_tracker_top_bar.dart';
import 'hand_tracker_toast_banner.dart';
import 'hand_tracker_tracking_button.dart';

class HandTrackerCameraView extends StatelessWidget {
  final HandTrackerViewModel model;
  final VoidCallback onToggleStreaming;

  const HandTrackerCameraView({
    super.key,
    required this.model,
    required this.onToggleStreaming,
  });

  @override
  Widget build(BuildContext context) {
    final controller = model.cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF5FFBD6)),
      );
    }

    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF5FFBD6)),
      );
    }

    final mirror = controller.description.lensDirection == CameraLensDirection.front;

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: AspectRatio(
              aspectRatio: previewSize.height / previewSize.width,
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(controller),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeInOutCubic,
                          tween: Tween<double>(
                            begin: 0,
                            end: model.isBlurred ? 1 : 0,
                          ),
                          builder: (context, blurValue, child) {
                            return BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: blurValue * 10,
                                sigmaY: blurValue * 10,
                              ),
                              child: Container(
                                color: Colors.black.withValues(
                                  alpha: 0.03 + (blurValue * 0.08),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 1.15,
                              colors: [Colors.transparent, Color(0xAA121414)],
                              stops: [0.35, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF121414).withValues(alpha: 0.08),
                                Colors.transparent,
                                const Color(0xFF121414).withValues(alpha: 0.12),
                              ],
                              stops: const [0, 0.55, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (model.hands.isNotEmpty)
                      Positioned.fill(
                        child: HandOverlay(
                          hands: model.hands,
                          mirror: mirror,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                HandTrackerTopBar(gestureLabel: model.gestureLabel),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (model.toastMessage != null)
                          HandTrackerToastBanner(message: model.toastMessage!),
                        const Spacer(),
                        Align(
                          alignment: Alignment.center,
                          child: HandTrackerTrackingButton(
                            label: model.isStreaming
                                ? 'Stop Tracking'
                                : 'Resume Tracking',
                            onPressed: onToggleStreaming,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
