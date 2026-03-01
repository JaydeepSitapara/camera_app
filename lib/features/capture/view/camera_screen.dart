import 'package:camera/camera.dart';
import 'package:camera_app/core/utils/app_colors.dart';
import 'package:camera_app/features/capture/provider/capture_provider.dart';
import 'package:camera_app/features/capture/view/results_screen.dart';
import 'package:camera_app/features/capture/widgets/camera_controls.dart';
import 'package:camera_app/features/capture/widgets/circular_progress_indicator.dart';
import 'package:camera_app/features/capture/widgets/session_close_confirm_dialog.dart';
import 'package:camera_app/features/capture/widgets/start_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(captureProvider.notifier).initCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(captureProvider);
    final controller = ref.read(captureProvider.notifier);
    final cameraService = ref.read(cameraServiceProvider);

    ///handle error state
    if (!state.isCameraInitialized) {
      if (state.errorMessage != null) {
        return Scaffold(
          backgroundColor: blackColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt_outlined,
                    color: whiteColor38, size: 70),
                const SizedBox(height: 20),
                Text(
                  state.errorMessage ?? '',
                  style: const TextStyle(color: whiteColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  onPressed: () async {
                    final status = await Permission.camera.request();
                    if (status.isGranted) {
                      ref.read(captureProvider.notifier).initCamera();
                    } else {
                      await openAppSettings();
                    }
                  },
                  child:
                      const Text("Retry", style: TextStyle(color: blackColor)),
                ),
              ],
            ),
          ),
        );
      }

      ///handle loading state
      return Scaffold(
        backgroundColor: blackColor,
        body: Center(
          child: LoaderWidget(
            color: primaryColor,
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: !state.isSessionActive,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          /// Only show dialog if session is active
          if (state.isSessionActive) {
            final shouldClose = await showCloseSessionDialog(context);

            if (!shouldClose) return;

            await controller.stopSession();

            if (!context.mounted) return;

            final processedImages = ref.read(captureProvider).images;

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResultsScreen(capturedImages: processedImages),
              ),
            );

            if (context.mounted) Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          backgroundColor: blackColor,
          body: Stack(
            children: [
              /// CAMERA PREVIEW
              Positioned.fill(
                child: cameraService.controller != null
                    ? CameraPreview(cameraService.controller!)
                    : const SizedBox.shrink(),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// STATUS
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: state.isSessionActive
                                    ? primaryColor
                                    : whiteColor38,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.isSessionActive ? 'SCANNING' : 'READY',
                              style: TextStyle(
                                color: state.isSessionActive
                                    ? primaryColor
                                    : whiteColor60,
                                fontSize: 12,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        if (state.isSessionActive && state.images.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: primaryColor,
                              ),
                            ),
                            child: Text(
                              "${state.images.length}",
                              style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              /// PROCESSING OVERLAY
              if (state.isProcessing)
                Container(
                  color: blackColor45,
                  child: Center(
                    child: LoaderWidget(
                      color: primaryColor,
                    ),
                  ),
                ),

              CameraControls(),
            ],
          ),
        ),
      ),
    );
  }
}
