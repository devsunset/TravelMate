import 'package:flutter/material.dart';

Widget widgetForPickedFile(dynamic file, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  return Container(
    width: width ?? 100,
    height: height ?? 100,
    color: Colors.grey[300],
    child: const Icon(Icons.image, size: 48),
  );
}
