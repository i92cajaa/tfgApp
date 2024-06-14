import 'dart:convert';

import 'package:flutter/material.dart';

class Base64ImageWidget extends StatelessWidget {
  // Aquí debes colocar tu cadena base64
  final String base64String;
  final double width;
  final double height;

  Base64ImageWidget({required this.base64String, this.width = 100, this.height = 100});

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      base64Decode(base64String),
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}