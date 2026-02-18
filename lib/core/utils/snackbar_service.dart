import 'package:camera_app/main.dart';
import 'package:flutter/material.dart';

class SnackBarService {
  static void show(String message) {
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
