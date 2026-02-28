import 'package:camera_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

Future<bool> showCloseSessionDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: orangeColor),
            SizedBox(width: 8),
            Text("Close Session"),
          ],
        ),
        content: const Text(
          "Are you sure you want to close this session?\n"
          "All unsaved data will be lost.",
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: redColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Close",
              style: TextStyle(color: whiteColor),
            ),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
