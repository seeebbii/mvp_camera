import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:mvp_camera/app/utils/angle_calculator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';

class MyCameraController extends GetxController {
  static MyCameraController instance = Get.find();

  // DATA VARIABLES
  Rx<TextEditingController> intervalController =
      TextEditingController(text: "1").obs;
  final projectNameController = TextEditingController().obs;
  Directory projectDirectory = Directory('');

  Rx<bool> captureBeep = false.obs;
  Rx<bool> angleCalculator = true.obs;
  Rx<bool> wakeLock = false.obs;
  Rx<bool> autoDimmer = true.obs;

  // Rx<bool> devLogs = false.obs;

  var listOfImagesFromAlbum = <Medium>[].obs;

  Rx<int> intervalSeconds = 0.obs;

  // var listOfCapturedImages = <File>[].obs;
  Rx<int> totalImagesCaptured = 0.obs;

  var cameras = <CameraDescription>[].obs;
  late Rx<CameraController> controller;
  Rx<bool> isCameraInitialized = false.obs;

  Rx<bool> cameraDisposeCheck = true.obs;

  Rx<double> minAvailableZoom = 1.0.obs;
  Rx<double> maxAvailableZoom = 1.0.obs;
  Rx<double> currentZoomLevel = 1.0.obs;

  Rx<double> minAvailableExposureOffset = 0.0.obs;
  Rx<double> maxAvailableExposureOffset = 0.0.obs;
  Rx<double> currentExposureOffset = 0.0.obs;
  Rx<double> exposureOffsetStepSize = 0.0.obs;

  Rx<bool> isRearCameraSelected = false.obs;

  final resolutionPresets = ResolutionPreset.values.obs;
  Rx<ResolutionPreset> currentResolutionPreset = ResolutionPreset.ultraHigh.obs;

  // TEMPORARY VARIABLE FOR STORING ABSOLUTE ORIENTATION's ROLL PITCH AND YAW
  // FOR DISPLAYING GREEN OR RED (INDICATOR) ON CAMERA SCREEN

  Rx<AngleCalculator> tempAbsoluteOrientation =
      AngleCalculator(roll: 0, yaw: 0, pitch: 0).obs;
  Rx<String> redGreenIndicatorCurrentImage = "green".obs;

  Future<void> changeProjectDirectory(String project) async {
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      projectDirectory =
          await Directory('${dir?.path}/$project').create(recursive: true);
    }
    if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      projectDirectory = await Directory('${dir.path}/$project').create();
    }
  }

  @override
  void onInit() {
    getAvailableCameras();
    super.onInit();
  }

  initializeZoom() {
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
        .getExposureOffsetStepSize()
        .then((value) => exposureOffsetStepSize.value = value);

    controller.value
        .getMaxExposureOffset()
        .then((value) => maxAvailableExposureOffset.value = value);
    //.then((value) => maxAvailableExposureOffset.value = value);

    debugPrint("CURRENT ZOOM : $currentZoomLevel");
    debugPrint("MINIMUM ZOOM : $minAvailableZoom");
    debugPrint("MAXIMUM ZOOM : $maxAvailableZoom");
    debugPrint("MAXIMUM EXPOSURE : $maxAvailableExposureOffset");
    debugPrint("MINIMUM EXPOSURE : $minAvailableExposureOffset");
    debugPrint("EXPOSURE OFFSET STEP SIZE : $minAvailableExposureOffset");

    debugPrint("${controller.value}");
  }

  Future getAvailableCameras() async {
    if (Platform.isIOS) {
      PermissionStatus status = await checkCameraPermission();
      if (status.isDenied) {
        Permission.camera.request();
      } else if (status.isGranted) {
        cameras.value = await availableCameras();
        controller = CameraController(
          cameras[0],
          ResolutionPreset.ultraHigh,
          imageFormatGroup: ImageFormatGroup.bgra8888,
        ).obs;
        isRearCameraSelected.value = true;
        controller.value.initialize().then((value) {
          debugPrint("CAMERA INIT SUCCESS");
          controller.value.lockCaptureOrientation(DeviceOrientation.portraitUp);
          controller.value.setFlashMode(FlashMode.off);
          initializeZoom();
        });
      }
    }
    if (Platform.isAndroid) {
      cameras.value = await availableCameras();
      print("Available Cameras: $cameras");
      controller = CameraController(cameras[0], ResolutionPreset.ultraHigh,
              imageFormatGroup: ImageFormatGroup.jpeg)
          .obs;
      isRearCameraSelected.value = true;
      controller.value.initialize().then((value) {
        controller.value.lockCaptureOrientation(DeviceOrientation.portraitUp);
        debugPrint("CAMERA INIT SUCCESS");
        controller.value.setFlashMode(FlashMode.off);
        initializeZoom();
      });
    }
  }

  void changeCamera(CameraDescription cameraDescription) {
    controller =
        CameraController(cameraDescription, currentResolutionPreset.value).obs;
    isRearCameraSelected.value = true;
    controller.value.initialize().then((value) {
      controller.value.lockCaptureOrientation(DeviceOrientation.portraitUp);
      debugPrint("CAMERA INIT SUCCESS");
      controller.value.setFlashMode(FlashMode.off);
      initializeZoom();
    });
  }

  Future<PermissionStatus> checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    return status;
  }
}
