import 'package:camera/camera.dart';
import 'package:camera_app/features/capture/provider/capture_provider.dart';
import 'package:camera_app/features/capture/view/results_screen.dart';
import 'package:camera_app/features/capture/widgets/active_control.dart';
import 'package:camera_app/features/capture/widgets/start_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureControllerProvider);
    final controller = ref.read(captureControllerProvider.notifier);
    final cameraService = ref.read(cameraServiceProvider);

    ref.listen(captureControllerProvider, (previous, next) {
      // If processing just finished
      if (previous?.isProcessing == true &&
          next.isProcessing == false &&
          next.images.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(capturedImages: next.images),
          ),
        );
      }
    });

    if (!state.isCameraInitialized) {
      controller.initCamera();
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5CC)),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Camera preview
            Positioned.fill(child: CameraPreview(cameraService.controller!)),

            // Top status indicator
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

            // Processing overlay
            if (state.isProcessing)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00E5CC)),
                ),
              ),

            // Bottom controls
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
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  ),
                ),
                child: state.isSessionActive
                    ? ActiveControls(
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
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:playground/features/capture/provider/capture_provider.dart';
//
// class CameraScreen extends ConsumerWidget {
//   const CameraScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(captureControllerProvider);
//     final controller =
//     ref.read(captureControllerProvider.notifier);
//     final cameraService = ref.read(cameraServiceProvider);
//
//     if (!state.isCameraInitialized) {
//       controller.initCamera();
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           CameraPreview(cameraService.controller!),
//
//           if (state.isProcessing)
//             const Center(child: CircularProgressIndicator()),
//
//           Positioned(
//             bottom: 50,
//             left: 0,
//             right: 0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 if (!state.isSessionActive)
//                   ElevatedButton(
//                     onPressed: controller.startSession,
//                     child: const Text("START"),
//                   )
//                 else ...[
//                   ElevatedButton(
//                     onPressed: controller.stopSession,
//                     child: const Text("STOP"),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.camera),
//                     onPressed: controller.captureImage,
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
// // import 'dart:async';
// // import 'dart:io';
// //
// // import 'package:camera/camera.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
// //
// // import 'package:path_provider/path_provider.dart';
// // import 'package:playground/features/capture/models/captured_image.dart';
// // import 'package:playground/features/capture/view/results_screen.dart';
// //
// // class CameraScreen extends StatefulWidget {
// //   const CameraScreen({super.key});
// //
// //   @override
// //   State<CameraScreen> createState() => _CameraScreenState();
// // }
// //
// // class _CameraScreenState extends State<CameraScreen>
// //     with WidgetsBindingObserver {
// //   CameraController? _controller;
// //   List<CameraDescription>? _cameras;
// //   bool _isCameraInitialized = false;
// //   bool _isCapturingSessionActive = false;
// //   bool _isProcessing = false;
// //   final List<CapturedImage> _capturedImages = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addObserver(this);
// //     _initCamera();
// //   }
// //
// //   Future<void> _initCamera() async {
// //     _cameras = await availableCameras();
// //     if (_cameras != null && _cameras!.isNotEmpty) {
// //       // Use the first back capture
// //       _controller = CameraController(
// //         _cameras![0],
// //         ResolutionPreset.high,
// //         enableAudio: false,
// //         imageFormatGroup: Platform.isAndroid
// //             ? ImageFormatGroup.nv21
// //             : ImageFormatGroup.bgra8888,
// //       );
// //
// //       try {
// //         await _controller!.initialize();
// //         if (mounted) {
// //           setState(() {
// //             _isCameraInitialized = true;
// //           });
// //         }
// //       } catch (e) {
// //         debugPrint('Camera initialization failed: $e');
// //       }
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     WidgetsBinding.instance.removeObserver(this);
// //     _controller?.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     final CameraController? cameraController = _controller;
// //
// //     // App state changed before we got the chance to initialize.
// //     if (cameraController == null || !cameraController.value.isInitialized) {
// //       return;
// //     }
// //
// //     if (state == AppLifecycleState.inactive) {
// //       cameraController.dispose();
// //     } else if (state == AppLifecycleState.resumed) {
// //       _initCamera();
// //     }
// //   }
// //
// //   Future<void> _startSession() async {
// //     setState(() {
// //       _isCapturingSessionActive = true;
// //       _capturedImages.clear();
// //     });
// //   }
// //
// //   Future<void> _stopSession() async {
// //     if (_capturedImages.isEmpty) {
// //       setState(() => _isCapturingSessionActive = false);
// //       return;
// //     }
// //
// //     setState(() {
// //       _isCapturingSessionActive = false;
// //       _isProcessing = true;
// //     });
// //
// //     final BarcodeScanner scanner = BarcodeScanner();
// //     final List<CapturedImage> processedImages = [];
// //
// //     try {
// //       for (final image in _capturedImages) {
// //         final inputImage = InputImage.fromFilePath(image.imagePath);
// //
// //         String? detectedData;
// //         String? detectedFormat;
// //
// //         try {
// //           final barcodes = await scanner.processImage(inputImage);
// //
// //           if (barcodes.isNotEmpty) {
// //             final barcode = barcodes.first;
// //             detectedData = barcode.rawValue;
// //             detectedFormat = _prettifyFormatStatic(barcode.format);
// //           }
// //         } catch (e) {
// //           debugPrint("Scan error: $e");
// //         }
// //
// //         processedImages.add(
// //           CapturedImage(
// //             imagePath: image.imagePath,
// //             barcodeData: detectedData,
// //             barcodeFormat: detectedFormat,
// //           ),
// //         );
// //       }
// //
// //       await scanner.close();
// //
// //       if (!mounted) return;
// //
// //       setState(() {
// //         _isProcessing = false;
// //       });
// //
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (_) => ResultsScreen(capturedImages: processedImages),
// //         ),
// //       );
// //     } catch (e) {
// //       await scanner.close();
// //
// //       if (!mounted) return;
// //
// //       setState(() => _isProcessing = false);
// //
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(const SnackBar(content: Text('Processing failed.')));
// //     }
// //   }
// //
// //   // Future<void> _stopSession() async {
// //   //   if (_capturedImages.isEmpty) {
// //   //     setState(() {
// //   //       _isCapturingSessionActive = false;
// //   //     });
// //   //     return;
// //   //   }
// //
// //   //   setState(() {
// //   //     _isCapturingSessionActive = false;
// //   //     _isProcessing = true;
// //   //   });
// //
// //   //   final rootToken = RootIsolateToken.instance;
// //   //   if (rootToken == null) {
// //   //     debugPrint('Cannot get RootIsolateToken');
// //   //     setState(() => _isProcessing = false);
// //   //     return;
// //   //   }
// //
// //   //   // Prepare data for isolate
// //   //   final List<String> imagePaths = _capturedImages.map((e) => e.imagePath).toList();
// //
// //   //   try {
// //   //     final List<Map<String, String?>> results = await compute(
// //   //       processImagesInBackground,
// //   //       _IsolateData(token: rootToken, imagePaths: imagePaths),
// //   //     );
// //
// //   //     final List<CapturedImage> processedImages = results.map((data) {
// //   //       return CapturedImage(
// //   //         imagePath: data['path']!,
// //   //         barcodeData: data['data'],
// //   //         barcodeFormat: data['format'],
// //   //       );
// //   //     }).toList();
// //
// //   //     if (!mounted) return;
// //
// //   //     setState(() {
// //   //       _isProcessing = false;
// //   //       _capturedImages.clear();
// //   //       _capturedImages.addAll(processedImages);
// //   //     });
// //
// //   //     Navigator.push(
// //   //       context,
// //   //       MaterialPageRoute(
// //   //         builder: (context) => ResultsScreen(capturedImages: List.from(_capturedImages)),
// //   //       ),
// //   //     );
// //   //   } catch (e) {
// //   //     debugPrint('Background processing failed: $e');
// //   //     if (mounted) {
// //   //       setState(() => _isProcessing = false);
// //   //       ScaffoldMessenger.of(context).showSnackBar(
// //   //         const SnackBar(content: Text('Processing failed. Please try again.')),
// //   //       );
// //   //     }
// //   //   }
// //   // }
// //
// //   Future<void> _captureImage() async {
// //     if (_controller == null || !_controller!.value.isInitialized) return;
// //
// //     try {
// //       // FAST CAPTURE: Do not await the result of processing before allowing next capture potentially
// //       // But we need the XFile to process. takePicture is the bottleneck.
// //       final XFile imageFile = await _controller!.takePicture();
// //
// //       // Fire and forget processing to keep UI responsive for next capture
// //       _processImage(imageFile);
// //     } catch (e) {
// //       debugPrint('Error capturing image: $e');
// //     }
// //   }
// //
// //   Future<void> _processImage(XFile imageFile) async {
// //     final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
// //     final Directory extDir = await getApplicationDocumentsDirectory();
// //     final String dirPath = '${extDir.path}/captured_images';
// //     await Directory(dirPath).create(recursive: true);
// //     final String filePath = '$dirPath/$timestamp.jpg';
// //
// //     // Move file to permanent location
// //     await File(imageFile.path).copy(filePath);
// //
// //     // Initial capture just saves file
// //     final capturedImage = CapturedImage(imagePath: filePath);
// //
// //     if (mounted) {
// //       setState(() {
// //         _capturedImages.add(capturedImage);
// //       });
// //     }
// //   }
// //
// //   // No longer needed as instance method, moved to static helper for consistency if needed,
// //   // but better to just have the isolate handle logic self-contained.
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (!_isCameraInitialized) {
// //       return const Scaffold(
// //         backgroundColor: Colors.black,
// //         body: Center(child: CircularProgressIndicator(color: Colors.purple)),
// //       );
// //     }
// //
// //     return Scaffold(
// //       body: Stack(
// //         fit: StackFit.expand,
// //         children: [
// //           // Camera Preview
// //           CameraPreview(_controller!),
// //
// //           // Overlay UI
// //           if (_isProcessing)
// //             Container(
// //               color: Colors.black54,
// //               child: const Center(
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     CircularProgressIndicator(color: Colors.purple),
// //                     SizedBox(height: 16),
// //                     Text(
// //                       'Processing Images...',
// //                       style: TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //
// //           SafeArea(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 // Top Bar
// //                 Padding(
// //                   padding: const EdgeInsets.all(16.0),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       _buildGlassBadge(
// //                         icon: Icons.photo_library,
// //                         text: '${_capturedImages.length} Captured',
// //                       ),
// //                       if (_isCapturingSessionActive)
// //                         _buildGlassBadge(
// //                           icon: Icons.circle,
// //                           text: 'LIVE',
// //                           color: Colors.redAccent,
// //                           pulsing: true,
// //                         ),
// //                     ],
// //                   ),
// //                 ),
// //
// //                 // Bottom Controls
// //                 Container(
// //                   padding: const EdgeInsets.only(bottom: 30, top: 20),
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       begin: Alignment.bottomCenter,
// //                       end: Alignment.topCenter,
// //                       colors: [
// //                         Colors.black.withValues(alpha: 0.8),
// //                         Colors.transparent,
// //                       ],
// //                     ),
// //                   ),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                     children: [
// //                       if (!_isCapturingSessionActive) ...[
// //                         _buildActionButton(
// //                           label: 'START SESSION',
// //                           icon: Icons.play_arrow_rounded,
// //                           color: const Color(0xFF7C4DFF),
// //                           onTap: _startSession,
// //                         ),
// //                       ] else ...[
// //                         _buildActionButton(
// //                           label: 'STOP',
// //                           icon: Icons.stop_rounded,
// //                           color: Colors.redAccent,
// //                           isSmall: true,
// //                           onTap: _stopSession,
// //                         ),
// //
// //                         // Shutter Button
// //                         GestureDetector(
// //                           onTap: _captureImage,
// //                           child: Container(
// //                             width: 80,
// //                             height: 80,
// //                             decoration: BoxDecoration(
// //                               shape: BoxShape.circle,
// //                               border: Border.all(color: Colors.white, width: 4),
// //                               color: Colors.white24,
// //                             ),
// //                             child: Container(
// //                               margin: const EdgeInsets.all(4),
// //                               decoration: const BoxDecoration(
// //                                 shape: BoxShape.circle,
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //
// //                         // Spacer to balance layout
// //                         const SizedBox(width: 60),
// //                       ],
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildGlassBadge({
// //     required IconData icon,
// //     required String text,
// //     Color color = Colors.white,
// //     bool pulsing = false,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //       decoration: BoxDecoration(
// //         color: Colors.black45,
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: Colors.white12),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(icon, color: color, size: 16),
// //           const SizedBox(width: 8),
// //           Text(
// //             text,
// //             style: const TextStyle(
// //               color: Colors.white,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildActionButton({
// //     required String label,
// //     required IconData icon,
// //     required Color color,
// //     required VoidCallback onTap,
// //     bool isSmall = false,
// //   }) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: EdgeInsets.symmetric(
// //           horizontal: isSmall ? 20 : 32,
// //           vertical: 16,
// //         ),
// //         decoration: BoxDecoration(
// //           color: color,
// //           borderRadius: BorderRadius.circular(30),
// //           boxShadow: [
// //             BoxShadow(
// //               color: color.withValues(alpha: 0.4),
// //               blurRadius: 10,
// //               offset: const Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Icon(icon, color: Colors.white),
// //             if (!isSmall) ...[
// //               const SizedBox(width: 12),
// //               Text(
// //                 label,
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: 16,
// //                   letterSpacing: 1.2,
// //                 ),
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class _IsolateData {
// //   final RootIsolateToken token;
// //   final List<String> imagePaths;
// //
// //   _IsolateData({required this.token, required this.imagePaths});
// // }
// //
// // Future<List<Map<String, String?>>> processImagesInBackground(
// //   _IsolateData data,
// // ) async {
// //   // Register the background isolate with the root isolate
// //   BackgroundIsolateBinaryMessenger.ensureInitialized(data.token);
// //
// //   final BarcodeScanner scanner = BarcodeScanner();
// //   final List<Map<String, String?>> results = [];
// //
// //   for (final String path in data.imagePaths) {
// //     final inputImage = InputImage.fromFilePath(path);
// //     String? detectedData;
// //     String? detectedFormat;
// //
// //     try {
// //       final List<Barcode> barcodes = await scanner.processImage(inputImage);
// //
// //       if (barcodes.isNotEmpty) {
// //         final barcode = barcodes.first;
// //         detectedData = barcode.rawValue;
// //         detectedFormat = _prettifyFormatStatic(barcode.format);
// //       }
// //     } catch (e) {
// //       debugPrint('Error scanning image in background: $e');
// //     }
// //
// //     results.add({'path': path, 'data': detectedData, 'format': detectedFormat});
// //   }
// //
// //   scanner.close();
// //   return results;
// // }
// //
// // String _prettifyFormatStatic(BarcodeFormat format) {
// //   switch (format) {
// //     case BarcodeFormat.qrCode:
// //       return 'QR Code';
// //     case BarcodeFormat.ean13:
// //     case BarcodeFormat.ean8:
// //       return 'Barcode';
// //     default:
// //       return format.name;
// //   }
// // }
