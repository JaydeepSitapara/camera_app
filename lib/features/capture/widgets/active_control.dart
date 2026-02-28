import 'package:camera_app/core/utils/app_colors.dart';
import 'package:camera_app/features/capture/widgets/badge_widget.dart';
import 'package:flutter/material.dart';

class ActiveControls extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onStop;
  final VoidCallback onCapture;
  final int imagesLength;

  const ActiveControls({
    super.key,
    required this.isProcessing,
    required this.onStop,
    required this.onCapture,
    required this.imagesLength,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Stop button
          GestureDetector(
            onTap: onStop,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: whiteColor.withValues(alpha: 0.07),
                border: Border.all(color: whiteColor24, width: 1),
              ),
              alignment: Alignment.center,
              child: const Text(
                'STOP',
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          const SizedBox(width: 28),

          // Capture button
          GestureDetector(
            onTap: isProcessing ? null : onCapture,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isProcessing ? whiteColor24 : whiteColor,
                border: Border.all(color: whiteColor, width: 3),
                boxShadow: isProcessing
                    ? []
                    : [
                        BoxShadow(
                          color: whiteColor.withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: isProcessing ? whiteColor38 : blackColor,
                size: 28,
              ),
            ),
          ),

          const SizedBox(width: 28),

          // Badge
          CaptureBadge(count: imagesLength),
        ],
      ),
    );
  }
}
