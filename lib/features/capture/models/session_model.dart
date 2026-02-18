import 'dart:convert';

import 'package:camera_app/features/capture/models/captured_image.dart';


class SessionModel {
  final String sessionId;
  final List<CapturedImage> images;

  SessionModel({
    required this.sessionId,
    required this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'images': images.map((e) => e.toMap()).toList(),
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      sessionId: map['sessionId'],
      images: List<CapturedImage>.from(
        map['images'].map((x) => CapturedImage.fromMap(x)),
      ),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory SessionModel.fromJson(String source) =>
      SessionModel.fromMap(jsonDecode(source));
}
