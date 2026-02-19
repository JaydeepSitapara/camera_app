import 'dart:io';

import 'package:camera_app/features/capture/models/captured_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const StatItem({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class DividerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: Colors.white12);
  }
}

class ImageCard extends StatelessWidget {
  final CapturedImage image;
  final VoidCallback onTap;

  const ImageCard({required this.image, required this.onTap});

  Color get _accentColor {
    if (image.barcodeFormat == 'QR Code') return const Color(0xFF00E5CC);
    if (image.barcodeFormat != null) return const Color(0xFFF59E0B);
    return Colors.white38;
  }

  @override
  Widget build(BuildContext context) {
    final hasCode = image.barcodeData != null;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(image.imagePath), fit: BoxFit.cover),

            // Bottom gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: hasCode
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _accentColor.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              image.barcodeFormat ?? 'CODE',
                              style: TextStyle(
                                color: _accentColor,
                                fontSize: 9,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            image.barcodeData!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : const Text(
                        'No code detected',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
            ),

            // Top-right type icon
            if (hasCode)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    image.barcodeFormat == 'QR Code'
                        ? Icons.qr_code_rounded
                        : Icons.view_week_rounded,
                    color: _accentColor,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FullScreenDialog extends StatelessWidget {
  final CapturedImage image;

  const FullScreenDialog({required this.image});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          InteractiveViewer(child: Image.file(File(image.imagePath))),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),

          // Code data at bottom
          if (image.barcodeData != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      image.barcodeFormat ?? 'Code',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            image.barcodeData!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: image.barcodeData!),
                            );
                            HapticFeedback.lightImpact();
                          },
                          icon: const Icon(
                            Icons.copy_rounded,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
