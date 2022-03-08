import 'dart:convert';
import 'dart:io';
import 'package:edit_exif/edit_exif.dart' as edt;
import 'package:camera/camera.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../controller/sensor_controller.dart';
import '../constant/controllers.dart';

class HandleFile {
  // SINGLETON CLASS

  static final HandleFile _handleFile = HandleFile._internal();

  HandleFile._internal();

  factory HandleFile() {
    return _handleFile;
  }

  late FlutterExif exifData;

  void initialize(File capturedFile) {
    exifData = getExif(capturedFile.path);
  }

  Future<void> setFileLatLongForAndroid(File capturedFile, double latitude, double longitude) async {
    // Get.lazyPut(() => SensorController());
    final sensorController = Get.find<SensorController>();
    exifData = getExif(capturedFile.path);
    exifData.setLatLong(mapController.userLocation.value.latitude,
        mapController.userLocation.value.longitude);
    exifData.setAttribute("UserComment", "${sensorController.gyroscopeEvent.value}");
    exifData.saveAttributes();
  }

  Future<void> setFileLatLongForIos(File capturedFile, double latitude, double longitude) async {
    var exif = edt.FlutterExif(capturedFile.path);

    print("CURRENT USERS LOCATION: $latitude : $longitude");

    Map<String, dynamic> location = {
      "lat": latitude,
      "lng" : longitude,
    };

    exif.setGps(location);
  }

  Future<void> saveFile(File newFile, XFile fromFile) async {
    fromFile.saveTo(newFile.path);
  }

  FlutterExif getExif(String path) {
    return FlutterExif.fromPath(path);
  }

  edt.FlutterExif getExifForIos(String path){
    return edt.FlutterExif(path);
  }

  Future<void> callReadExifFromFileMethod(File myFile) async {
    final data = await readExifFromFile(myFile);
    if (data.isEmpty) {
      print("No EXIF information found");
      return;
    } else {
      for (final entry in data.entries) {
        print("${entry.key}: ${entry.value}");
      }
    }
  }
}
