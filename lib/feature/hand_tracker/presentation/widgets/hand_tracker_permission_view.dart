import 'dart:ui';

import 'package:flutter/material.dart';

class HandTrackerPermissionView extends StatelessWidget {
  final VoidCallback onGrantPermission;

  const HandTrackerPermissionView({
    super.key,
    required this.onGrantPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1C1C), Color(0xFF121414)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _glassPanel(
            borderRadius: 24,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.videocam_rounded,
                  color: Color(0xFF5FFBD6),
                  size: 36,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Camera permission is required',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE2E2E2),
                  ),
                ),
                const SizedBox(height: 20),
                _actionButton(
                  label: 'Grant permission',
                  onPressed: onGrantPermission,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: _trackingButton(label: label, onPressed: onPressed),
    );
  }

  Widget _trackingButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5FFBD6).withValues(alpha: 0.28),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: const Color(0xFF5FFBD6),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Container(
            width: 232,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF74FFE0), const Color(0xFF5FFBD6)],
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D1C32),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassPanel({
    required Widget child,
    required double borderRadius,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: child,
        ),
      ),
    );
  }
}
