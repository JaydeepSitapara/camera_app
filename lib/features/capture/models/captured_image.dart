class CapturedImage {
  final String imagePath;
  final String? barcodeData;
  final String? barcodeFormat;

  CapturedImage({
    required this.imagePath,
    this.barcodeData,
    this.barcodeFormat,
  });
}
