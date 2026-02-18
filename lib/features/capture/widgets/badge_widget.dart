import 'package:flutter/material.dart';

class CaptureBadge extends StatelessWidget {
  final int count;

  const CaptureBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.07),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5CC).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: Color(0xFF00E5CC),
              fontWeight: FontWeight.w800,
              fontSize: 18,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count == 1 ? 'PHOTO' : 'PHOTOS',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w600,
              fontSize: 6,
              letterSpacing: 1.5,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}