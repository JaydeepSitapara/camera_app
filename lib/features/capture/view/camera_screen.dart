import 'package:camera/camera.dart';
import 'package:camera_app/features/capture/provider/capture_provider.dart';
import 'package:camera_app/features/capture/view/results_screen.dart';
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
  void dispose() {
    ref.read(cameraServiceProvider).disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(captureProvider);
    final controller = ref.read(captureProvider.notifier);
    final cameraService = ref.read(cameraServiceProvider);

    /// ==========================
    /// CAMERA NOT INITIALIZED
    /// ==========================
    if (!state.isCameraInitialized) {
      if (state.errorMessage != null) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt_outlined,
                    color: Colors.white38, size: 70),
                const SizedBox(height: 20),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5CC),
                  ),
                  onPressed: () async {
                    final status = await Permission.camera.request();
                    if (status.isGranted) {
                      ref.read(captureProvider.notifier).initCamera();
                    } else {
                      await openAppSettings();
                    }
                  },
                  child: const Text("Retry",
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        );
      }

      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00E5CC),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: !state.isSessionActive, // 👈 KEY FIX
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
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              /// CAMERA PREVIEW
              Positioned.fill(
                child: cameraService.controller != null
                    ? CameraPreview(cameraService.controller!)
                    : const SizedBox.shrink(),
              ),

              /// ==========================
              /// TOP STATUS + IMAGE COUNT
              /// ==========================
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
                                    ? const Color(0xFF00E5CC)
                                    : Colors.white38,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.isSessionActive ? 'SCANNING' : 'READY',
                              style: TextStyle(
                                color: state.isSessionActive
                                    ? const Color(0xFF00E5CC)
                                    : Colors.white60,
                                fontSize: 12,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        /// IMAGE COUNT ONLY IF SESSION ACTIVE
                        if (state.isSessionActive && state.images.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5CC).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF00E5CC),
                              ),
                            ),
                            child: Text(
                              "${state.images.length}",
                              style: const TextStyle(
                                color: Color(0xFF00E5CC),
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
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00E5CC),
                    ),
                  ),
                ),

              /// ==========================
              /// BOTTOM CONTROLS
              /// ==========================
              Positioned(
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
                        Colors.black.withOpacity(0.9),
                        Colors.transparent,
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
                                      HapticFeedback.lightImpact();
                                      await controller.captureImage();
                                    },
                              child: Container(
                                width: 75,
                                height: 75,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: const Center(
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Color(0xFF00E5CC),
                                  ),
                                ),
                              ),
                            ),

                           
                            GestureDetector(
                              onTap: () async {
                                HapticFeedback.heavyImpact();

                                await controller.stopSession();

                                if (!context.mounted) return;

                                final processedImages =
                                    ref.read(captureProvider).images;

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ResultsScreen(
                                        capturedImages: processedImages),
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
                                  color: Colors.red.withOpacity(0.9),
                                ),
                                child: const Icon(
                                  Icons.stop,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      : StartControl(
                          onStart: () {
                            HapticFeedback.mediumImpact();
                            controller.startSession();
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
