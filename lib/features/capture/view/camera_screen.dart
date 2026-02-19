import 'package:camera/camera.dart';
import 'package:camera_app/features/capture/provider/capture_provider.dart';
import 'package:camera_app/features/capture/view/results_screen.dart';
import 'package:camera_app/features/capture/widgets/active_control.dart';
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

    /// Initialize camera once screen loads
    Future.microtask(() {
      ref.read(captureControllerProvider.notifier).initCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Listen only once here (important – not inside conditional)
    ref.listen(captureControllerProvider, (previous, next) {
      if (previous?.isProcessing == true &&
          next.isProcessing == false &&
          next.images.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              capturedImages: next.images,
            ),
          ),
        );
      }
    });

    final state = ref.watch(captureControllerProvider);
    final controller = ref.read(captureControllerProvider.notifier);
    final cameraService = ref.read(cameraServiceProvider);

    /// ===== CAMERA NOT INITIALIZED =====
    if (!state.isCameraInitialized) {
      /// ===== ERROR STATE =====
      if (state.errorMessage != null) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white38,
                    size: 70,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // /// If permanently denied → Open Settings
                  // if (state.isPermissionPermanentlyDenied)
                  //   ElevatedButton(
                  //     onPressed: () async {
                  //       await openAppSettings();
                  //     },
                  //     child: const Text("Open Settings"),
                  //   )
                  // else
                  ElevatedButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        backgroundColor:
                            WidgetStatePropertyAll(Color(0xFF00E5CC))),
                    onPressed: () async {
                      final status = await Permission.camera.status;

                      if (status.isPermanentlyDenied) {
                        await openAppSettings();
                        return;
                      }

                      final result = await Permission.camera.request();

                      if (result.isGranted) {
                        ref
                            .read(captureControllerProvider.notifier)
                            .initCamera();
                      } else if (result.isPermanentlyDenied) {
                        await openAppSettings();
                      }
                    },
                    child: const Text(
                      "Retry",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      /// ===== LOADING STATE =====
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00E5CC),
          ),
        ),
      );
    }

    /// ===== CAMERA READY =====
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            /// Camera Preview
            Positioned.fill(
              child: CameraPreview(cameraService.controller!),
            ),

            /// Top Status Indicator
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
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
                ),
              ),
            ),

            /// Processing Overlay
            if (state.isProcessing)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00E5CC),
                  ),
                ),
              ),

            /// Bottom Controls
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
                    ? ActiveControls(
                        imagesLength: state.images.length,
                        isProcessing: state.isProcessing,
                        onStop: () {
                          HapticFeedback.heavyImpact();
                          controller.stopSession();
                        },
                        onCapture: () {
                          HapticFeedback.lightImpact();
                          controller.captureImage();
                        },
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
    );
  }
}

// import 'package:camera/camera.dart';
// import 'package:camera_app/features/capture/provider/capture_provider.dart';
// import 'package:camera_app/features/capture/view/results_screen.dart';
// import 'package:camera_app/features/capture/widgets/active_control.dart';
// import 'package:camera_app/features/capture/widgets/badge_widget.dart';
// import 'package:camera_app/features/capture/widgets/start_control.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// class CameraScreen extends ConsumerStatefulWidget {
//   const CameraScreen({super.key});
//
//   @override
//   ConsumerState<CameraScreen> createState() => _CameraScreenState();
// }
//
// class _CameraScreenState extends ConsumerState<CameraScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       ref.read(captureControllerProvider.notifier).initCamera();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(captureControllerProvider);
//     final controller = ref.read(captureControllerProvider.notifier);
//     final cameraService = ref.read(cameraServiceProvider);
//
//     ref.listen(captureControllerProvider, (previous, next) {
//       // If processing just finished
//       if (previous?.isProcessing == true &&
//           next.isProcessing == false &&
//           next.images.isNotEmpty) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ResultsScreen(capturedImages: next.images),
//           ),
//         );
//       }
//     });
//
//     if (!state.isCameraInitialized) {
//       // controller.initCamera();
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(
//           child: CircularProgressIndicator(color: Color(0xFF00E5CC)),
//         ),
//       );
//     }
//
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Stack(
//           children: [
//             // Camera preview
//             Positioned.fill(child: CameraPreview(cameraService.controller!)),
//
//             // Top status indicator
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: state.isSessionActive
//                               ? const Color(0xFF00E5CC)
//                               : Colors.white38,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         state.isSessionActive ? 'SCANNING' : 'READY',
//                         style: TextStyle(
//                           color: state.isSessionActive
//                               ? const Color(0xFF00E5CC)
//                               : Colors.white60,
//                           fontSize: 12,
//                           letterSpacing: 2,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // Processing overlay
//             if (state.isProcessing)
//               Container(
//                 color: Colors.black45,
//                 child: const Center(
//                   child: CircularProgressIndicator(color: Color(0xFF00E5CC)),
//                 ),
//               ),
//
//             // Bottom controls
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).padding.bottom + 24,
//                   top: 24,
//                   left: 32,
//                   right: 32,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                     colors: [Colors.black.withOpacity(0.9), Colors.transparent],
//                   ),
//                 ),
//                 child: state.isSessionActive
//                     ? Expanded(
//                         child: Row(
//                           children: [
//                             // Stop button
//                             ActiveControls(
//                               imagesLength: state.images.length ?? 0,
//                               isProcessing: state.isProcessing,
//                               onStop: () {
//                                 HapticFeedback.heavyImpact();
//                                 controller.stopSession();
//                               },
//                               onCapture: () {
//                                 HapticFeedback.lightImpact();
//                                 controller.captureImage();
//                               },
//                             ),
//
//                             // placeholder to keep layout balanced
//                           ],
//                         ),
//                       )
//                     : StartControl(
//                         onStart: () {
//                           HapticFeedback.mediumImpact();
//                           controller.startSession();
//                         },
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
