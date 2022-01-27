import 'dart:io';
import '../app/utils/handle_file.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';

class FileDataModel {

  File imageFile;
  FlutterExif fileData;

  FileDataModel({ required this.imageFile, required this.fileData });

  // Map<String, dynamic> toJson() => {'id':id, 'name':name };
}