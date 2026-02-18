import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/captured_image.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/captured_image.dart';

class ResultsScreen extends StatelessWidget {
  final List<CapturedImage> capturedImages;

  const ResultsScreen({super.key, required this.capturedImages});

  @override
  Widget build(BuildContext context) {
    final qrCount =
        capturedImages.where((i) => i.barcodeFormat == 'QR Code').length;
    final barcodeCount = capturedImages
        .where((i) => i.barcodeFormat != null && i.barcodeFormat != 'QR Code')
        .length;
    final plainCount =
        capturedImages.where((i) => i.barcodeFormat == null).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E0E),
        elevation: 0,
        title: const Text(
          'Session Results',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Summary strip
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                _StatItem(
                  label: 'QR Codes',
                  count: qrCount,
                  color: const Color(0xFF00E5CC),
                  icon: Icons.qr_code_2_rounded,
                ),
                _Divider(),
                _StatItem(
                  label: 'Barcodes',
                  count: barcodeCount,
                  color: const Color(0xFFF59E0B),
                  icon: Icons.view_week_rounded,
                ),
                _Divider(),
                _StatItem(
                  label: 'Plain',
                  count: plainCount,
                  color: Colors.white38,
                  icon: Icons.image_rounded,
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: capturedImages.isEmpty
                ? const Center(
                    child: Text(
                      'No images captured',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: capturedImages.length,
                    itemBuilder: (context, index) {
                      return _ImageCard(
                        image: capturedImages[index],
                        onTap: () => _showFullScreen(
                          context,
                          capturedImages[index],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFullScreen(BuildContext context, CapturedImage image) {
    showDialog(
      context: context,
      builder: (_) => _FullScreenDialog(image: image),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatItem({
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: Colors.white12);
  }
}

class _ImageCard extends StatelessWidget {
  final CapturedImage image;
  final VoidCallback onTap;

  const _ImageCard({required this.image, required this.onTap});

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

class _FullScreenDialog extends StatelessWidget {
  final CapturedImage image;

  const _FullScreenDialog({required this.image});

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
