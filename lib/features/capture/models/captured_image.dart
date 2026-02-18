class CapturedImage {
  final String imagePath;
  final String? barcodeData;
  final String? barcodeFormat;

  CapturedImage({
    required this.imagePath,
    this.barcodeData,
    this.barcodeFormat,
  });

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'barcodeData': barcodeData,
      'barcodeFormat': barcodeFormat,
    };
  }

  factory CapturedImage.fromMap(Map<String, dynamic> map) {
    return CapturedImage(
      imagePath: map['imagePath'],
      barcodeData: map['barcodeData'],
      barcodeFormat: map['barcodeFormat'],
    );
  }
}
