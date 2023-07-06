import 'dart:typed_data';

import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final double radius;
  final Uint8List imageBytes;
  final VoidCallback onPressed;

  const Avatar({
    Key key,
    @required this.radius,
    @required this.imageBytes,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        child: imageBytes == null
            ? Icon(
          Icons.camera_alt,
          size: radius * 0.6,
        )
            : ClipOval(
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
          ),
        ),
      ),
    );
  }
}