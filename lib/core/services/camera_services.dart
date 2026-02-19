import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? controller;

  /// Initialize Camera Safely
  Future<void> initialize() async {
    try {
      final status = await Permission.camera.request();

      if (!status.isGranted) {
        throw CameraPermissionException(
          'Camera permission denied',
        );
      }

      if (controller != null && controller!.value.isInitialized) {
        return;
      }

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw CameraException(
          'NoCameraFound',
          'No camera available on this device',
        );
      }

      controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller!.initialize();

      await controller!.setFocusMode(FocusMode.auto);
    } catch (e) {
      await disposeCamera();
      rethrow;
    }
  }

  /// Capture Image Safely
  Future<String> captureImage() async {
    try {
      if (controller == null || !controller!.value.isInitialized) {
        throw CameraException(
          'CameraNotInitialized',
          'Camera is not initialized',
        );
      }

      final XFile file = await controller!.takePicture();

      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await file.saveTo(path);

      return path;
    } catch (e) {
      rethrow;
    }
  }

  /// Dispose camera completely
  Future<void> disposeCamera() async {
    if (controller != null) {
      await controller!.dispose();
      controller = null;
    }
  }
}

/// Custom Permission Exception
class CameraPermissionException implements Exception {
  final String message;

  CameraPermissionException(this.message);

  @override
  String toString() => message;
}
