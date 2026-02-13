import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider? imageProviderForPickedFile(File? file) {
  return file == null ? null : FileImage(file);
}
