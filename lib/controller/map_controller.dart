import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

import '../app/constant/image_paths.dart';
import '../app/utils/angle_calculator.dart';
import '../model/file_data_model.dart';

class MapController extends GetxController {
  static MapController instance = Get.find();


  late GoogleMapController controller;
  var imageMarkers = <Marker>{}.obs;

  late Stream<Position> _geoLocationStream;

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

  static Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        ?.buffer
        .asUint8List();
  }

  static Future<Uint8List?> getBytesFromAssetInAnotherIsolate(AssetBundle rootBundle, String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        ?.buffer
        .asUint8List();
  }

  @override
  void onInit() {
    super.onInit();
    listenToUserLocation();
  }

  Future<void> listenToUserLocation() async {
    await checkLocationPermission().then((permissionStatus) {
      if (permissionStatus == PermissionStatus.granted) {
        debugPrint("Location permission: $permissionStatus");

        Geolocator.isLocationServiceEnabled().then((geoPermission) async {
          if(geoPermission){
            _geoLocationStream = Geolocator.getPositionStream(
                locationSettings: const LocationSettings(
                    accuracy: LocationAccuracy.bestForNavigation));
            userLocation.bindStream(_geoLocationStream);
            userLocation.value = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
            print(userLocation);
          }
        });

      }else{
        listenToUserLocation();
      }
      initCurrentLocationCameraPosition();
    });

  }

  static Future<Set<Marker>> getMarkersInAnotherIsolate(Map<String, dynamic> params) async {
    // print(files);
    Set<Marker> temp = {};

    List<FileDataModel> files = params['files'] as List<FileDataModel>;

    // EDITING MARKER BITMAP


    final Uint8List? redBox = params['redBox'] as Uint8List;
    final Uint8List? greenBox = params['greenBox'] as Uint8List;
    final Uint8List? yellowBox = params['yellowBox'] as Uint8List;

    for (int i = 0; i < files.length; i++) {
      String calcColor = calculateImageAngle(files, i);
      Uint8List? decidedColor;
      switch (calcColor) {
        case "green":
          decidedColor = greenBox;
          break;
        case "yellow":
          decidedColor = yellowBox;
          break;
        case "red":
          decidedColor = redBox;
          break;
      }

      if (i != 0) {
        temp.add(
          Marker(
            // icon: isRed ? BitmapDescriptor.fromBytes(redBox!) : BitmapDescriptor.fromBytes(greenBox!),
              icon: BitmapDescriptor.fromBytes(decidedColor!),
              markerId: MarkerId('$i'),
              position: files[i].position,
              infoWindow: InfoWindow(
                title: '${files[i].absoluteOrientation}',
                // snippet: "${element.metaData['exif']['UserComment']}"
              )),
        );
      }
    }

    return temp;
  }

  static Future<Set<Marker>> getMarkersInAnotherIsolateForIos(
      List<FileDataModelForIos> files) async {
    // print(files);
    Set<Marker> temp = {};

    // EDITING MARKER BITMAP
    final Uint8List? redBox = await getBytesFromAsset(ImagePaths.redBox, 35);
    final Uint8List? greenBox =
        await getBytesFromAsset(ImagePaths.greenBox, 35);
    final Uint8List? yellowBox =
        await getBytesFromAsset(ImagePaths.yellowBox, 35);

    for (int i = 0; i < files.length; i++) {
      String calcColor = calculateImageAngleForIos(files, i);
      Uint8List? decidedColor;
      switch (calcColor) {
        case "green":
          decidedColor = greenBox;
          break;
        case "yellow":
          decidedColor = yellowBox;
          break;
        case "red":
          decidedColor = redBox;
          break;
      }

      if (i != 0) {
        temp.add(
          Marker(
              // icon: isRed ? BitmapDescriptor.fromBytes(redBox!) : BitmapDescriptor.fromBytes(greenBox!),
              icon: BitmapDescriptor.fromBytes(decidedColor!),
              markerId: MarkerId('$i'),
              position: files[i].position,
              infoWindow: InfoWindow(
                title: '${files[i].absoluteOrientation}',
                // snippet: "${element.metaData['exif']['UserComment']}"
              )),
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

      final Uint8List? redBox = await getBytesFromAsset(ImagePaths.redBox, 35);
      final Uint8List? greenBox =
      await getBytesFromAsset( ImagePaths.greenBox, 35);
      final Uint8List? yellowBox =
      await getBytesFromAsset(ImagePaths.yellowBox, 35);

      Map<String, dynamic> params = {
        "files" : listOfFiles,
        'redBox' : redBox,
        'greenBox' : greenBox,
        'yellowBox' : yellowBox,
      };

      imageMarkers.value = await compute(getMarkersInAnotherIsolate, params);
      navigationController.goBack();
    } else {
      // ITERATING THROUGH THE FILE AND GETTING [LAT LNG] FROM THEIR INSTANCE VARIABLES FOR SETTING UP MARKERS
      final listOfFiles =
          fetchFilesController.filesInCurrentProjectForIos.value;
      // imageMarkers.value = await compute(getMarkersInAnotherIsolate, listOfFiles);
      imageMarkers.value = await getMarkersInAnotherIsolateForIos(listOfFiles);
      navigationController.goBack();
    }
  }

  Future<PermissionStatus> checkLocationPermission() async {
    // LocationPermission permission = await Geolocator.checkPermission();
    PermissionStatus permissionStatus =
        await Permission.location.request();
    // print("Location permission: $permission");
    return permissionStatus;
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

  static String calculateImageAngleForIos(
    List<FileDataModelForIos> files,
    int currentIndex,
  ) {
    // X reoresents ROLL
    // Y represents PITCH
    // Z represents YAW
    print(currentIndex);
    int j = 0;
    try {
      String flag = "green";
      // print("OUTTER LOOP: $currentIndex");

      // WHEN THE I == 0 the J will also be 0 but no calculations will b performed
      // WHEN THE I != 0  J will be I-1 i.e the image will be calculated with its previous image
      j = currentIndex == 0 ? currentIndex : currentIndex - 1;
      // print("VALUE OF J: $j");

      // TODO :: NEW CALCULATION
      if (files[currentIndex].angleCalculations.pitch.abs() -
                  files[j].angleCalculations.pitch.abs() <
              15 &&
          files[currentIndex].angleCalculations.roll.abs() -
                  files[j].angleCalculations.roll.abs() <
              15 &&
          files[currentIndex].angleCalculations.yaw.abs() -
                  files[j].angleCalculations.yaw.abs() <
              15) {
        // print("RedBox");
        flag = "green";
      } else if (files[currentIndex].angleCalculations.pitch.abs() -
                  files[j].angleCalculations.pitch.abs() >=
              15 ||
          files[currentIndex].angleCalculations.pitch.abs() -
                      files[j].angleCalculations.pitch.abs() <=
                  25 &&
              files[currentIndex].angleCalculations.roll.abs() -
                      files[j].angleCalculations.roll.abs() >=
                  15 ||
          files[currentIndex].angleCalculations.roll.abs() -
                      files[j].angleCalculations.roll.abs() <=
                  25 &&
              files[currentIndex].angleCalculations.yaw.abs() -
                      files[j].angleCalculations.yaw.abs() >=
                  15 ||
          files[currentIndex].angleCalculations.yaw.abs() -
                  files[j].angleCalculations.yaw.abs() <=
              25) {
        // print("GreenBox");
        flag = "yellow";
      } else if (files[currentIndex].angleCalculations.pitch.abs() -
                  files[j].angleCalculations.pitch.abs() >
              25 &&
          files[currentIndex].angleCalculations.roll.abs() -
                  files[j].angleCalculations.roll.abs() >
              25 &&
          files[currentIndex].angleCalculations.yaw.abs() -
                  files[j].angleCalculations.yaw.abs() >
              25) {
        flag = "red";
      }
      return flag;
    } catch (e) {
      print("ERROR FROM CALCULATION: $e");
      return "green";
    }
  }


  static String calculateImageAngle(
      List<FileDataModel> files,
      int currentIndex,
      ) {
    // X represents ROLL
    // Y represents PITCH
    // Z represents YAW
    debugPrint(currentIndex.toString());
    int j = 0;
    try {
      String flag = "green";
      // print("OUTTER LOOP: $currentIndex");

      // WHEN THE I == 0 the J will also be 0 but no calculations will b performed
      // WHEN THE I != 0  J will be I-1 i.e the image will be calculated with its previous image
      j = currentIndex == 0 ? currentIndex : currentIndex - 1;
      // print("VALUE OF J: $j");

      // TODO :: NEW CALCULATION
      if (files[currentIndex].angleCalculations.pitch.abs() -
          files[j].angleCalculations.pitch.abs() <
          15 &&
          files[currentIndex].angleCalculations.roll.abs() -
              files[j].angleCalculations.roll.abs() <
              15 &&
          files[currentIndex].angleCalculations.yaw.abs() -
              files[j].angleCalculations.yaw.abs() <
              15) {
        // print("RedBox");
        flag = "green";
      } else if (files[currentIndex].angleCalculations.pitch.abs() -
          files[j].angleCalculations.pitch.abs() >=
          15 ||
          files[currentIndex].angleCalculations.pitch.abs() -
              files[j].angleCalculations.pitch.abs() <=
              25 &&
              files[currentIndex].angleCalculations.roll.abs() -
                  files[j].angleCalculations.roll.abs() >=
                  15 ||
          files[currentIndex].angleCalculations.roll.abs() -
              files[j].angleCalculations.roll.abs() <=
              25 &&
              files[currentIndex].angleCalculations.yaw.abs() -
                  files[j].angleCalculations.yaw.abs() >=
                  15 ||
          files[currentIndex].angleCalculations.yaw.abs() -
              files[j].angleCalculations.yaw.abs() <=
              25) {
        // print("GreenBox");
        flag = "yellow";
      } else if (files[currentIndex].angleCalculations.pitch.abs() -
          files[j].angleCalculations.pitch.abs() >
          25 &&
          files[currentIndex].angleCalculations.roll.abs() -
              files[j].angleCalculations.roll.abs() >
              25 &&
          files[currentIndex].angleCalculations.yaw.abs() -
              files[j].angleCalculations.yaw.abs() >
              25) {
        flag = "red";
      }
      return flag;
    } catch (e) {
      print("ERROR FROM CALCULATION: $e");
      return "green";
    }
  }

}
