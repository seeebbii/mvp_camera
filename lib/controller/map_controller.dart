import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapController extends GetxController {
  static MapController instance = Get.find();

  late Stream<Position> _geoLocationStream;
  late GoogleMapController controller;
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
  Rx<CameraPosition> currentLocationCameraPosition = const CameraPosition(target: LatLng(0.0, 0.0)).obs;

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

    if(locationPermission){
      userLocation.bindStream(_geoLocationStream);
    }else{
      await Geolocator.requestPermission();
    }
    initCurrentLocationCameraPosition();
  }


  Future<void> createMarkers() async {

  }


  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return LocationPermission.always == permission;
  }


  Future<void> initCurrentLocationCameraPosition() async {
    currentLocationCameraPosition.value = CameraPosition(target: LatLng(userLocation.value.latitude, userLocation.value.longitude));
  }

  Future<void> animateCamera(CameraPosition position) async {
    controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }



}
