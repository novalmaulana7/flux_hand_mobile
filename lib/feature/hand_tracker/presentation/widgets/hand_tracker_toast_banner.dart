import 'package:flutter/material.dart';

class HandTrackerToastBanner extends StatelessWidget {
  final String message;

  const HandTrackerToastBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Material(
          color: const Color(0xFF1E2020).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👍', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE2E2E2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
