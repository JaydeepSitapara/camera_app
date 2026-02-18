import 'package:camera_app/core/services/barcode_services.dart';
import 'package:camera_app/core/services/camera_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../controller/capture_controller.dart';
import '../controller/capture_state.dart';

final cameraServiceProvider = Provider((ref) => CameraService());

final barcodeServiceProvider = Provider((ref) => BarcodeService());

final captureControllerProvider =
    NotifierProvider<CaptureController, CaptureState>(CaptureController.new);
