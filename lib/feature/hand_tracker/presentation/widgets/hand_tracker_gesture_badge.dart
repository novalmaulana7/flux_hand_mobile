import 'package:flutter/material.dart';

class HandTrackerGestureBadge extends StatelessWidget {
  final String label;

  const HandTrackerGestureBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 122),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF5FFBD6).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.edit_rounded,
              size: 15,
              color: Color(0xFF5FFBD6),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE2E2E2),
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
