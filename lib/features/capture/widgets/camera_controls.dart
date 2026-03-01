import 'package:camera_app/core/utils/app_colors.dart';
import 'package:camera_app/features/capture/provider/capture_provider.dart';
import 'package:camera_app/features/capture/view/results_screen.dart';
import 'package:camera_app/features/capture/widgets/start_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureProvider);

    final controller = ref.read(captureProvider.notifier);
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 24,
          top: 24,
          left: 32,
          right: 32,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              blackColor.withValues(alpha: 0.9),
              transparentColor,
            ],
          ),
        ),
        child: state.isSessionActive
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60),

                  /// CAPTURE
                  GestureDetector(
                    onTap: state.isProcessing
                        ? null
                        : () async {
                            await controller.captureImage();
                          },
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: whiteColor,
                          width: 4,
                        ),
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: primaryColor,
                        ),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () async {
                      await controller.stopSession();

                      if (!context.mounted) return;

                      final processedImages = ref.read(captureProvider).images;

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ResultsScreen(capturedImages: processedImages),
                        ),
                      );

                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: redColor.withValues(alpha: 0.9),
                      ),
                      child: const Icon(
                        Icons.stop,
                        color: whiteColor,
                      ),
                    ),
                  ),
                ],
              )
            : StartControl(
                onStart: () {
                  controller.startSession();
                },
              ),
      ),
    );
  }
}
