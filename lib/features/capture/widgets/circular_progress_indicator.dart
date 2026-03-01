import 'package:flutter/material.dart';

class LoaderWidget extends StatelessWidget {
  LoaderWidget({super.key, this.color});

  Color? color;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color,
    );
  }
}
