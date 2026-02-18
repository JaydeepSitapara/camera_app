import 'package:camera_app/features/capture/models/captured_image.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeService {
  final BarcodeScanner _scanner = BarcodeScanner();

  String _prettifyFormat(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return 'QR Code';
      case BarcodeFormat.ean13:
      case BarcodeFormat.ean8:
        return 'Barcode';
      default:
        return format.name;
    }
  }

  Future<List<CapturedImage>> processImages(List<CapturedImage> images) async {
    final List<CapturedImage> processed = [];

    for (final image in images) {
      final input = InputImage.fromFilePath(image.imagePath);
      final barcodes = await _scanner.processImage(input);

      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        processed.add(
          CapturedImage(
            imagePath: image.imagePath,
            barcodeData: barcode.rawValue,
            barcodeFormat: _prettifyFormat(barcode.format),
          ),
        );
      } else {
        processed.add(image);
      }
    }

    return processed;
  }

  Future<void> dispose() async {
    await _scanner.close();
  }
}
