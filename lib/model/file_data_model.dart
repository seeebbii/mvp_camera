import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:edit_exif/edit_exif.dart' as edt;
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:mvp_camera/app/utils/angle_calculator.dart';

class FileDataModel {

  File imageFile;
  FlutterExif fileData;
  Map<dynamic, dynamic> metaData;
  LatLng position;
  Map<String, dynamic> gyroInfo;
  Map<String, dynamic> absoluteOrientation;
  AngleCalculator angleCalculations;

  FileDataModel({ required this.imageFile, required this.fileData, required this.metaData, required this.position,required this.gyroInfo, required this.absoluteOrientation, required this.angleCalculations });

  // Map<String, dynamic> toJson() => {'id':id, 'name':name };
}


class FileDataModelForIos {

  File imageFile;
  edt.FlutterExif fileData;
  Map<dynamic, dynamic> metaData;
  LatLng position;
  Map<String, dynamic> gyroInfo;
  Map<String, dynamic> absoluteOrientation;
  AngleCalculator angleCalculations;

  FileDataModelForIos({ required this.imageFile, required this.fileData, required this.metaData, required this.position, required this.gyroInfo, required this.absoluteOrientation, required this.angleCalculations});
// Map<String, dynamic> toJson() => {'id':id, 'name':name };
}