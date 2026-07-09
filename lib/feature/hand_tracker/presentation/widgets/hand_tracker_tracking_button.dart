import 'package:flutter/material.dart';

class HandTrackerTrackingButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const HandTrackerTrackingButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
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
}
