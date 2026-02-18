import 'package:flutter/material.dart';

class ActiveControls extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onStop;
  final VoidCallback onCapture;

  const ActiveControls({
    required this.isProcessing,
    required this.onStop,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(
          onPressed: onStop,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          ),
          child: const Text('STOP'),
        ),
        GestureDetector(
          onTap: isProcessing ? null : onCapture,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              color: isProcessing ? Colors.white24 : Colors.white,
            ),
            child: Icon(
              Icons.camera_alt_rounded,
              color: isProcessing ? Colors.white38 : Colors.black,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 80), // symmetry spacer
      ],
    );
  }
}
