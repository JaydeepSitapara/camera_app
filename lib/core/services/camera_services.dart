import 'dart:io';
import 'package:camera/camera.dart';
import 'package:camera_app/core/utils/snackbar_service.dart';
import 'package:path_provider/path_provider.dart';

class CameraService {
  CameraController? controller;

  Future<void> initialize() async {
    final cameras = await availableCameras();

    controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await controller!.initialize();
  }

  Future<String> captureImage() async {
    final XFile file = await controller!.takePicture();

    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await file.saveTo(path);
    SnackBarService.show('Image captured successfully.');

    return path;
  }

  void dispose() {
    controller?.dispose();
  }
}
