import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:flutter/foundation.dart';

import '../constant/controllers.dart';

class HandleFile{
  // SINGLETON CLASS

  static final HandleFile _handleFile = HandleFile._internal();
  HandleFile._internal();
  factory HandleFile() {
    return _handleFile;
  }

  late final FlutterExif exifData;


  HandleFile.fromFile(File capturedFile){
    exifData = getExif(capturedFile.path);
  }

  Future<void> setFileLatLong(double latitude, double longitude)async {

    exifData.getRotationDegrees().then((value) => print("DEGREES ROTATION: $value"));

    // setting latitude and longitude
    print("<MY LATITUDE: ${mapController.userLocation.value.latitude}>, <MY LONGITUDE: ${mapController.userLocation.value.longitude}>");
    exifData.setLatLong(mapController.userLocation.value.latitude, mapController.userLocation.value.longitude);
    exifData.setAttribute("GPSLatitude", mapController.userLocation.value.latitude.toString());
    exifData.setAttribute("GPSLongitude", mapController.userLocation.value.longitude.toString());


    exifData.setAttribute("ImageDescription", "imageDescription");

    exifData.saveAttributes();
    print(exifData);
  }

  static Future<void> saveFile() async{

  }

  static FlutterExif getExif(String path){
    return FlutterExif.fromPath(path);
  }

  static Future<void> readExifFromBytes(File myFile)async{
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