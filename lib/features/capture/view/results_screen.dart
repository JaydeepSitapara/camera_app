import 'package:camera_app/core/utils/app_colors.dart';
import 'package:camera_app/features/capture/widgets/result_screen_widgets.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        title: const Text(
          'Session Results',
          style: TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: whiteColor),
      ),
      body: Column(
        children: [
          // Summary strip
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: darkGreyColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: whiteColor12),
            ),
            child: Row(
              children: [
                StatItem(
                  label: 'QR Codes',
                  count: qrCount,
                  color: primaryColor,
                  icon: Icons.qr_code_2_rounded,
                ),
                DividerWidget(),
                StatItem(
                  label: 'Barcodes',
                  count: barcodeCount,
                  color: amberColor,
                  icon: Icons.view_week_rounded,
                ),
                DividerWidget(),
                StatItem(
                  label: 'Plain',
                  count: plainCount,
                  color: whiteColor38,
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
                      style: TextStyle(color: whiteColor38),
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
                      return ImageCard(
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
      builder: (_) => FullScreenDialog(image: image),
    );
  }
}
