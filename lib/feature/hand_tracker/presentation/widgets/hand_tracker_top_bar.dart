import 'package:flutter/material.dart';

import 'hand_tracker_gesture_badge.dart';

class HandTrackerTopBar extends StatelessWidget {
  final String gestureLabel;

  const HandTrackerTopBar({super.key, required this.gestureLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF121414).withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Image(
            image: AssetImage('assets/images/flux_hand_logo_dark.png'),
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 5),
          const Text(
            'Flux Hand',
            style: TextStyle(
              fontSize: 24,
              height: 1,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5FFBD6),
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          HandTrackerGestureBadge(label: gestureLabel),
        ],
      ),
    );
  }
}
