import 'package:camera_app/features/capture/models/captured_image.dart';

class CaptureState {
  final bool isCameraInitialized;
  final bool isSessionActive;
  final bool isProcessing;
  final List<CapturedImage> images;

  const CaptureState({
    this.isCameraInitialized = false,
    this.isSessionActive = false,
    this.isProcessing = false,
    this.images = const [],
  });

  CaptureState copyWith({
    bool? isCameraInitialized,
    bool? isSessionActive,
    bool? isProcessing,
    List<CapturedImage>? images,
  }) {
    return CaptureState(
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isProcessing: isProcessing ?? this.isProcessing,
      images: images ?? this.images,
    );
  }
}
