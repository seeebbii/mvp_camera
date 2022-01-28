import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

import '../model/file_data_model.dart';

class MapController extends GetxController {
  static MapController instance = Get.find();

  late Stream<Position> _geoLocationStream;
  late GoogleMapController controller;
  var imageMarkers = <Marker>{}.obs;
  late BitmapDescriptor bitmapDescriptor;
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
    _geoLocationStream = Geolocator.getPositionStream(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.best));
    listenToUserLocation();
  }

  Future<void> listenToUserLocation() async {
    bool locationPermission = await checkLocationPermission();
    debugPrint("Location permission: $locationPermission");

    if (locationPermission) {
      userLocation.bindStream(_geoLocationStream);
    } else {
      await Geolocator.requestPermission();
    }
    initCurrentLocationCameraPosition();
  }

  Future<void> createMarkers() async {
    // ITERATING THROUGH THE FILE AND GETTING [LAT LNG] FROM THEIR INSTANCE VARIABLES FOR SETTING UP MARKERS
    Set<Marker> temp = {};
    int markerId = 0;
    print(fetchFilesController.filesInCurrentProject.length);
    for (var element in fetchFilesController.filesInCurrentProject) {

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
            icon: true ? BitmapDescriptor.defaultMarker : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            markerId: MarkerId('$markerId'),
            position: element.position,
            infoWindow: InfoWindow(
                title: '${element.metaData['exif']['CreateDate']}',
                snippet: "${element.metaData['exif']['UserComment']}")),
      );
    }
    imageMarkers.value = temp;
    // print(imageMarkers);
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
          zoom: 11.00));
    }
  }

  Future<void> animateCamera(CameraPosition position) async {
    controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }
}
