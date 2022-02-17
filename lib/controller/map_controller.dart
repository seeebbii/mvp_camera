import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

import '../app/utils/angle_calculator.dart';
import '../model/file_data_model.dart';

class MapController extends GetxController {
  static MapController instance = Get.find();

  late Stream<Position> _geoLocationStream;
  late GoogleMapController controller;
  var imageMarkers = <Marker>{}.obs;

  Completer<GoogleMapController> googleMapController = Completer();

  // INITIALIZE DEFAULT VALUES
  Rx<Position> userLocation = Position(
    longitude: 0.0,
    latitude: 0.0,
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  ).obs;
  Rx<CameraPosition> currentLocationCameraPosition =
      const CameraPosition(target: LatLng(0.0, 0.0)).obs;

  @override
  void onInit() {
    super.onInit();
    listenToUserLocation();
  }

  Future<void> listenToUserLocation() async {
    bool locationPermission = await checkLocationPermission();
    debugPrint("Location permission: $locationPermission");

    if (locationPermission) {
      _geoLocationStream = Geolocator.getPositionStream(
          locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.bestForNavigation));
      userLocation.bindStream(_geoLocationStream);
      print("USER CURRENT LOCATION: ${userLocation.value}");
    } else {
      await Permission.locationAlways.request();
      await Permission.location.request();
    }
    initCurrentLocationCameraPosition();
  }

  static Future<Set<Marker>> getMarkersInAnotherIsolate(
      List<FileDataModel> files) async {
    // print(files);
    Set<Marker> temp = {};
    int markerId = 0;
    print(files.length);
    for (var element in files) {
      // EDITING MARKER BITMAP
      // ui.Codec codec = await ui.instantiateImageCodec(
      //     element.imageFile.readAsBytesSync(),
      //     targetWidth: 100,
      //     targetHeight: 100);
      // ui.FrameInfo fi = await codec.getNextFrame();
      // final Uint8List? markerImage =
      //     (await fi.image.toByteData(format: ui.ImageByteFormat.png))
      //         ?.buffer
      //         .asUint8List();

      markerId += 1;
      temp.add(
        Marker(
            icon: true ? BitmapDescriptor.defaultMarker : BitmapDescriptor
                .defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            markerId: MarkerId('$markerId'),
            position: element.position,
            infoWindow: InfoWindow(
                title: '${element.metaData['exif']['CreateDate']}',
                snippet: "${element.metaData['exif']['UserComment']}")),
      );
    }
    return temp;
  }


  static Future<Set<Marker>> getMarkersInAnotherIsolateForIos(
      List<FileDataModelForIos> files) async {
    // print(files);
    Set<Marker> temp = {};

    for (int i = 0; i < files.length; i++) {

      // EDITING MARKER BITMAP
      // ui.Codec codec = await ui.instantiateImageCodec(
      //     element.imageFile.readAsBytesSync(),
      //     targetWidth: 100,
      //     targetHeight: 100);
      // ui.FrameInfo fi = await codec.getNextFrame();
      // final Uint8List? markerImage =
      //     (await fi.image.toByteData(format: ui.ImageByteFormat.png))
      //         ?.buffer
      //         .asUint8List();

      bool isRed = calculateImageAngle(files, i);
      print(isRed);

      if(i != 0){
        temp.add(
          Marker(
              icon: isRed ? BitmapDescriptor.defaultMarker : BitmapDescriptor
                  .defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              markerId: MarkerId('$i'),
              position: files[i].position,
              infoWindow: InfoWindow(
                title: '${files[i].absoluteOrientation}',
                // snippet: "${element.metaData['exif']['UserComment']}"
              )
          ),
        );
      }

    }

    return temp;
  }

  Future<void> createMarkers() async {
    if (Platform.isAndroid) {
      // ITERATING THROUGH THE FILE AND GETTING [LAT LNG] FROM THEIR INSTANCE VARIABLES FOR SETTING UP MARKERS
      final listOfFiles = fetchFilesController.filesInCurrentProject.value;
      // imageMarkers.value = await compute(getMarkersInAnotherIsolate, listOfFiles);
      imageMarkers.value = await getMarkersInAnotherIsolate(listOfFiles);
      navigationController.goBack();
    } else {
      // ITERATING THROUGH THE FILE AND GETTING [LAT LNG] FROM THEIR INSTANCE VARIABLES FOR SETTING UP MARKERS
      final listOfFiles = fetchFilesController.filesInCurrentProjectForIos
          .value;
      // imageMarkers.value = await compute(getMarkersInAnotherIsolate, listOfFiles);
      imageMarkers.value = await getMarkersInAnotherIsolateForIos(listOfFiles);
      navigationController.goBack();
    }
  }

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return LocationPermission.always == permission;
  }

  Future<void> initCurrentLocationCameraPosition() async {
    currentLocationCameraPosition.value = CameraPosition(
      target: LatLng(userLocation.value.latitude, userLocation.value.longitude),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    if (!googleMapController.isCompleted) {
      googleMapController.complete(controller);
      animateCamera(CameraPosition(
          target: LatLng(
            userLocation.value.latitude,
            userLocation.value.longitude,
          ),
          zoom: 5.00));
    }
  }

  Future<void> animateCamera(CameraPosition position) async {
    controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  static bool calculateImageAngle(List<FileDataModelForIos> files, int currentIndex,) {
    // X reoresents ROLL
    // Y represents PITCH
    // Z represents YAW
    print(currentIndex);
    int j = 0;
    try{
      bool flag = false;
      // print("OUTTER LOOP: $currentIndex");

      // WHEN THE I == 0 the J will also be 0 but no calculations will b performed
      // WHEN THE I != 0  J will be I-1 i.e the image will be calculated with its previous image
      j = currentIndex == 0 ? currentIndex : currentIndex-1;
      // print("VALUE OF J: $j");

      if (files[currentIndex].angleCalculations.pitch.abs() - files[j].angleCalculations.pitch.abs() < 15 &&
          files[currentIndex].angleCalculations.roll.abs() - files[j].angleCalculations.roll.abs() < 15 &&
         files[currentIndex].angleCalculations.yaw.abs() - files[j].angleCalculations.yaw.abs() < 15){
        // print("RedBox");
        flag = true;
      }else{
        // print("GreenBox");
        flag = false;
      }
      return flag;
    }
    catch(e){
      print("ERROR FROM CALCULATION: $e");
      return true;
    }
  }

}
