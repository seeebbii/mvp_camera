import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class MyCameraController extends GetxController {
  static MyCameraController instance = Get.find();

  // DATA VARIABLES
  final projectNameController = TextEditingController().obs;
  Rx<int> intervalSeconds = 0.obs;

  var listOfCapturedImages = <File>[].obs;

  var cameras = <CameraDescription>[].obs;
  late Rx<CameraController> controller;
  Rx<bool> isCameraInitialized = false.obs;

  Rx<double> minAvailableZoom = 1.0.obs;
  Rx<double> maxAvailableZoom = 1.0.obs;
  Rx<double> currentZoomLevel = 1.0.obs;

  Rx<double> minAvailableExposureOffset = 0.0.obs;
  Rx<double> maxAvailableExposureOffset = 0.0.obs;
  Rx<double> currentExposureOffset = 0.0.obs;

  Rx<bool> isRearCameraSelected = false.obs;

  @override
  void onInit() {
    getAvailableCameras();
    super.onInit();
  }

  initializeZoom(){
    controller.value
        .getMaxZoomLevel()
        .then((value) => maxAvailableZoom.value = value);

    controller.value
        .getMinZoomLevel()
        .then((value) => minAvailableZoom.value = value);

    controller.value
        .getMinExposureOffset()
        .then((value) => minAvailableExposureOffset.value = value);

    controller.value
        .getMaxExposureOffset()
        .then((value) => maxAvailableExposureOffset.value = value);

    debugPrint("CURRENT ZOOM : $currentZoomLevel");
    debugPrint("MINIMUM ZOOM : $minAvailableZoom");
    debugPrint("MAXIMUM ZOOM : $maxAvailableZoom");
    debugPrint("MAXIMUM EXPOSURE : $maxAvailableExposureOffset");
    debugPrint("MINIMUM EXPOSURE : $minAvailableExposureOffset");
  }

  getAvailableCameras() async {
    cameras.value = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.veryHigh).obs;
    isRearCameraSelected.value = true;
    controller.value.initialize().then((value) {
      debugPrint("CAMERA INIT SUCCESS");
      controller.value.setFlashMode(FlashMode.always);
      initializeZoom();
    });
  }

  Future<PermissionStatus> checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    return status;
  }
}
