import 'dart:io';

import 'package:flutter/material.dart';

Widget widgetForPickedFile(File file, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  return Image.file(file, width: width, height: height, fit: fit);
}
