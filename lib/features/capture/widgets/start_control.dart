import 'package:flutter/material.dart';

class StartControl extends StatelessWidget {
  final VoidCallback onStart;
  const StartControl({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onStart,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5CC),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'START SESSION',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}