import 'package:camera_app/core/services/barcode_services.dart';
import 'package:camera_app/core/services/camera_services.dart';
import 'package:camera_app/core/services/shared_pref_services.dart';
import 'package:camera_app/features/capture/models/captured_image.dart';
import 'package:camera_app/features/capture/models/session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'capture_state.dart';
import '../provider/capture_provider.dart';

class CaptureController extends Notifier<CaptureState> {
  late final CameraService _cameraService;
  late final BarcodeService _barcodeService;

  @override
  CaptureState build() {
    _cameraService = ref.read(cameraServiceProvider);
    _barcodeService = ref.read(barcodeServiceProvider);

    return const CaptureState();
  }

  Future<void> initCamera() async {
    try {
      await _cameraService.initialize();

      state = state.copyWith(
        isCameraInitialized: true,
        errorMessage: null,
      );
    } catch (e) {
      final message = e.toString();

      state = state.copyWith(
        isCameraInitialized: false,
        errorMessage: message,
      );
    }
  }

  void startSession() {
    state = state.copyWith(
      isSessionActive: true,
      images: [],
    );
  }

  Future<void> captureImage() async {
    final path = await _cameraService.captureImage();

    state = state.copyWith(
      images: [
        ...state.images,
        CapturedImage(imagePath: path),
      ],
    );
  }

  Future<void> stopSession() async {
    if (state.images.isEmpty) {
      state = state.copyWith(isSessionActive: false);
      return;
    }

    state = state.copyWith(
      isSessionActive: false,
      isProcessing: true,
    );

    final processed = await _barcodeService.processImages(state.images);

    state = state.copyWith(
      isProcessing: false,
      images: processed,
    );

    final session = SessionModel(
      sessionId: DateTime.now().toIso8601String(),
      images: state.images,
    );

    await SharedPrefServices.saveLastSession(session);
  }
}
