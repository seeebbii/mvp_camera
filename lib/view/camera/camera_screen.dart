import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:metadata/metadata.dart' as meta;
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:mvp_camera/app/router/router_generator.dart';
import 'package:mvp_camera/app/utils/angle_calculator.dart';
import 'package:mvp_camera/app/utils/colors.dart';
import 'package:mvp_camera/app/utils/dialogs.dart';
import 'package:mvp_camera/app/utils/handle_file.dart';
import 'package:mvp_camera/app/utils/shared_pref.dart';
import 'package:mvp_camera/view/QA/qa_root_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock/wakelock.dart';

import '../../controller/map_controller.dart';
import '../../controller/sensor_controller.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  // Initializing empty gallery album
  // final emptyAlbum = Album.fromJson(
  //     const {'id': 'null', 'count': 0, 'mediumType': 'image', 'name': 'null'});

  double _currentScale = 1.0;
  double _baseScale = 1.0;
  late PermissionStatus status;
  Timer? timer;
  Timer? dimDuration;
  bool isCapturingImages = false;
  int flashIndex = 0;
  List<Icon> listOfFlashButtons = [
    Icon(
      Icons.flash_off,
      size: 20.sp,
      color: Colors.white70,
    ),
    Icon(
      Icons.flash_on,
      size: 20.sp,
      color: Colors.white70,
    ),
    Icon(
      Icons.flash_auto,
      size: 20.sp,
      color: Colors.white70,
    ),
  ];



  // SINGLETON CLASS OBJECT FOR HANDLING FILE (ADDING EXIF DATA)
  final HandleFile handleFile = HandleFile();

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    // Instantiating the camera controller

    final CameraController cameraController = CameraController(
      cameraDescription,
      myCameraController.currentResolutionPreset.value,
      // imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Replace with the new controller
    if (mounted) {

      setState(() {
        // cameraController.setFlashMode(FlashMode.off);
        // myCameraController.controller.value = cameraController;
        // myCameraController.controller.value.lockCaptureOrientation(DeviceOrientation.portraitUp);
      });
    }
    cameraController.setFlashMode(FlashMode.off);
    myCameraController.controller.value = cameraController;
    myCameraController.isCameraInitialized.value = false;
    myCameraController.isRearCameraSelected.value = false;

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) {
        setState(() {
        debugPrint("MOUNTED FROM CAMERA SCREEN");
      });
      }
    });

    // Initialize controller
    try {
      await cameraController.initialize().then((value) {
        debugPrint("CONTROLLER INITIALIZED");
        cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
      });
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        myCameraController.isCameraInitialized.value =
            myCameraController.controller.value.value.isInitialized;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (myCameraController.controller.value == null ||
        !myCameraController.controller.value.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      debugPrint("CAMERA SCREEN INACTIVE LIFE CYCLE");
      myCameraController.controller.value.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(myCameraController.controller.value.description);
    }
  }

  Future<PermissionStatus> checkLocationPermission() async {
    PermissionStatus permissionStatus = await Permission.locationWhenInUse.request();
    return permissionStatus;
  }

  void startCapturingImages() async {
    // dimming the brightness of screen
    if(myCameraController.autoDimmer.value){
      dimDuration = Timer.periodic(const Duration(minutes: 2), (timer) {
        ScreenBrightness().setScreenBrightness(0.0);
      });
    }


    Get.lazyPut(() => SensorController());
    final sensorController = Get.find<SensorController>();
    // INITIALIZING CSV FILE AND DEVICE TOTAL/FREE STORAGE
    sensorController.initCsvFile();
    fetchFilesController.initializeDeviceStorageInfo();
    setState(() {
      isCapturingImages = true;
    });
    PermissionStatus locationPermission = await checkLocationPermission();
    // INITIALIZE DURATION FOR CAPTURING IMAGES
    Duration duration = Duration(
        milliseconds:
            (double.parse(myCameraController.intervalController.value.text) *
                    1000)
                .toInt());
    timer = Timer.periodic(duration, (thisTimer) async {
      if (isCapturingImages == true) {
        // IF DEVICE IS LESS THAN 2 GB, STOP CAPTURING
        if (fetchFilesController.freeDiskSpace <= 2048) {
          Dialogs.openErrorSnackBar(context, 'Device low on storage!');
          stopCapturingImages();
          return;
        }
        // INTERNET CONNECTION STATUS
        // NOT REQUIRED

        // if(connectionController.isOnline.value == false){
        //   Dialogs.openErrorSnackBar(context, 'Device not connected to internet');
        //   stopCapturingImages();
        //   return;
        // }

        // LOCATION STATUS CHECK
        if(locationPermission != PermissionStatus.granted){
          Dialogs.openErrorSnackBar(context, 'Allow application to access location from settings');
          stopCapturingImages();
          return;
        }

        Map<String, dynamic> gyroScopeInfo = {
          "x": sensorController.gyroscopeEvent.value.z.toStringAsFixed(3),
          "y": sensorController.gyroscopeEvent.value.y.toStringAsFixed(3),
          "z": sensorController.gyroscopeEvent.value.z.toStringAsFixed(3),
        };

        Map<String, dynamic> absoluteOrientation = {
          "roll": (sensorController.absoluteOrientationEvent.value.roll * 180 /pi).toStringAsFixed(0),
          "pitch": (sensorController.absoluteOrientationEvent.value.pitch * 180 /pi).toStringAsFixed(0),
          "yaw": (sensorController.absoluteOrientationEvent.value.yaw * 180 / pi).toStringAsFixed(0),
        };

        // START OF TAKING PICTURE
        await myCameraController.controller.value.takePicture().then((xFile){

          // CREATING A FILE WITH CUSTOM FILE NAME
          File newFile = File(
              "${myCameraController.projectDirectory.path}/${DateFormat('MM:dd:yyyy').format(DateTime.now()).toString()}-${DateFormat('hh:mm:ss').format(DateTime.now()).toString()}%${jsonEncode(gyroScopeInfo)}%${jsonEncode(absoluteOrientation)}.jpeg");
          // SAVING THE CAPTURED IMAGE IN CREATED FILE
          xFile.saveTo(newFile.path).then((value){

            // SAVING CURRENT ABSOLUTE ORIENTATION IN A TEMP VARIABLE TO DETERMINE THE RED OR GREEN INDICATOR ON CAMERA SCREEN
            myCameraController.tempAbsoluteOrientation.value = AngleCalculator(roll: double.parse(absoluteOrientation['roll']), yaw: double.parse(absoluteOrientation['yaw']), pitch: double.parse(absoluteOrientation['pitch']));

            if(Platform.isIOS){
              // ADD EXIF DATA FOR IMAGES ON IOS PLATFORM
              handleFile.setFileLatLongForIos(
                  newFile,
                  mapController.userLocation.value.latitude,
                  mapController.userLocation.value.longitude);
            }
            if(Platform.isAndroid){
              // ADD EXIF DATA FOR IMAGES ON ANDROID PLATFORM
              handleFile.setFileLatLongForAndroid(
                newFile,
                mapController.userLocation.value.latitude,
                mapController.userLocation.value.longitude);
          }
            myCameraController.totalImagesCaptured.value += 1;

            double sizeOfFile = calculateByteToMb(newFile.lengthSync());
            fetchFilesController.freeDiskSpace -= sizeOfFile;
          });
        });

        AngleCalculator currentImage = AngleCalculator(roll: double.parse((sensorController.absoluteOrientationEvent.value.roll * 180 /pi).toStringAsFixed(0)),
            yaw: double.parse((sensorController.absoluteOrientationEvent.value.yaw * 180 /pi).toStringAsFixed(0)), pitch: double.parse((sensorController.absoluteOrientationEvent.value.pitch * 180 /pi).toStringAsFixed(0)));

        if(myCameraController.angleCalculator.value){
          myCameraController.redGreenIndicatorCurrentImage.value = calculateImageAngle(myCameraController.tempAbsoluteOrientation.value, currentImage);
        }

        debugPrint("PREVIOUS ABSOLUTE ORIENTATION: ${myCameraController.tempAbsoluteOrientation.value}");
        debugPrint("CURRENT ABSOLUTE ORIENTATION: $currentImage");
        debugPrint("INDICATOR: ${ myCameraController.redGreenIndicatorCurrentImage.value}");

        // SETTING BEEP TO TRUE EVERY TIME THE PICTURE IS CLICKED
        if (myCameraController.captureBeep.value) {
          FlutterBeep.beep(true);
        }

        // SAVING INFO TO CSV FILE
        sensorController.createCsvFile();

      } else {
        timer?.cancel();
      }
    });
  }

  void stopCapturingImages() async {
    Get.lazyPut(() => SensorController());
    final sensorController = Get.find<SensorController>();
    sensorController.saveCsvFile();
    fetchFilesController.initializeDeviceStorageInfo();

    setState(() {
      isCapturingImages = false;
    });
    timer?.cancel();
    dimDuration?.cancel();
    if(myCameraController.autoDimmer.value){
      ScreenBrightness().resetScreenBrightness();
    }
  }

  // TAP TO FOCS AND SHOW FOCUS CIRCLE
  bool showFocusCircle = false;
  double x = 0;
  double y = 0;

  bool focusModeAuto = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() => myCameraController.controller.value.value.isInitialized ?
      // myCameraController.controller.value.description == myCameraController.cameras[0] ?
      landscapeCameraLeft(deviceRatio)
          // : landscapeCameraRight(deviceRatio)
            : Container(
        color: Colors.black,
        height: size.height,
        width: size.width,
      ))
    );
  }

  Widget landscapeCameraLeft(double deviceRatio) {
    ResolutionPreset val = myCameraController.currentResolutionPreset.value;
    return Obx(() => Center(
          child: Transform.scale(
            scale: val == ResolutionPreset.low || val == ResolutionPreset.medium ? 1 : 1 / (myCameraController.controller.value.value.aspectRatio * deviceRatio) ,
            child: AspectRatio(
              aspectRatio:
                  1 / myCameraController.controller.value.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  myCameraController.controller.value.value.isInitialized ? myCameraController.controller.value.buildPreview() : const SizedBox.shrink(),
                  GestureDetector(
                    onTapUp: (TapUpDetails tapUpDetails) {
                      // TAP TO FOCUS
                      if (myCameraController
                          .controller.value.value.isInitialized) {
                        // CHECK IF FOCUS POINT AVAILABLE
                        if (myCameraController
                            .controller.value.value.focusPointSupported) {
                          showFocusCircle = true;
                          x = tapUpDetails.localPosition.dx;
                          y = tapUpDetails.localPosition.dy;

                          double fullWidth = MediaQuery.of(context).size.width;
                          double cameraHeight = fullWidth *
                              myCameraController
                                  .controller.value.value.aspectRatio;

                          double xp = x / fullWidth;
                          double yp = y / cameraHeight;

                          Offset point = Offset(xp, yp);
                          debugPrint("point : $point");

                          // Manually focus
                          myCameraController.controller.value.setFocusPoint(point);
                          myCameraController.controller.value.setFocusMode(FocusMode.locked);

                          // Manually set light exposure
                          myCameraController.controller.value.setExposurePoint(point);
                          myCameraController.controller.value.setExposureMode(ExposureMode.locked);

                          setState(() {
                            Future.delayed(const Duration(seconds: 2))
                                .whenComplete(() {
                              setState(() {
                                showFocusCircle = false;
                                focusModeAuto = false;
                              });
                            });
                          });
                        }
                      }
                    },
                    onLongPress: () {
                      debugPrint("Auto focus Enabled");
                      setState(() {
                        focusModeAuto = true;
                        myCameraController.controller.value
                            .setFocusMode(FocusMode.auto);
                        myCameraController.controller.value
                            .setExposureMode(ExposureMode.auto);
                      });
                    },
                  ),
                  if (showFocusCircle)
                    Positioned(
                        top: y - 20,
                        left: x - 20,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5)),
                        )),
                  Positioned(
                    top: 0.03.sh,
                    right: 0.10.sw,
                    child: RotatedBox(
                      quarterTurns: 1 -
                          myCameraController.controller.value.description
                                  .sensorOrientation ~/
                              120,
                      child: ElevatedButton(
                        onPressed: () {
                          navigationController.goBack();
                        },
                        child: Text(
                          "Back",
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(
                                  fontSize: 10.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1),
                        ),
                        style: ElevatedButton.styleFrom(
                          onPrimary: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          primary: primaryColor,
                          shape: RoundedRectangleBorder(
                              //to set border radius to button
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.1.sh,
                    right: 0.10.sw,
                    child: RotatedBox(
                      quarterTurns: 1 -
                          myCameraController.controller.value.description
                              .sensorOrientation ~/
                              120,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(15))),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.02.sw, vertical: 0.01.sh),
                          child: Text(
                            "${myCameraController.currentResolutionPreset.value.name.capitalize}",
                            style: TextStyle(
                                color: Colors.white, fontSize: 14.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.03.sh,
                    right: 0.10.sw,
                    child: RotatedBox(
                      quarterTurns: 1 -
                          myCameraController.controller.value.description
                              .sensorOrientation ~/
                              120,
                      child: Obx(()=>Row(
                        children: [
                          myCameraController.angleCalculator.value ?
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: checkIndicatorColor(myCameraController.redGreenIndicatorCurrentImage.value),
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ) : const SizedBox.shrink(),
                          SizedBox(width: 0.01.sw,),
                          // Text(myCameraController.redGreenIndicatorCurrentImage.value ?  'Stop' : "Pass", style: Theme.of(context).textTheme.headline1?.copyWith(color: Colors.white, fontSize: 17.sp),),

                        ],
                      )),
                    ),
                  ),
                  Positioned(
                      top: 0.03.sh,
                      left: 0.12.sw,
                      child: RotatedBox(
                        quarterTurns: 1 -
                            myCameraController.controller.value.description
                                    .sensorOrientation ~/
                                120,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                if (flashIndex == 0) {
                                  setState(() {
                                    myCameraController.controller.value
                                        .setFlashMode(FlashMode.always);
                                    flashIndex = 1;
                                  });
                                } else if (flashIndex == 1) {
                                  setState(() {
                                    myCameraController.controller.value
                                        .setFlashMode(FlashMode.auto);
                                    flashIndex = 2;
                                  });
                                } else {
                                  setState(() {
                                    myCameraController.controller.value
                                        .setFlashMode(FlashMode.off);
                                    flashIndex = 0;
                                  });
                                }
                              },
                              child: CircleAvatar(
                                  backgroundColor: Colors.black87,
                                  maxRadius: 15.r,
                                  child: listOfFlashButtons[flashIndex]),
                            ),
                            SizedBox(
                              width: 5.sm,
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  focusModeAuto ? "Auto" : "Locked",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14.sm),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5.sm,
                            ),
                            GestureDetector(
                              onTap: () => navigationController
                                  .navigateToNamed(settingsScreen),
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.5),
                                  child: Icon(
                                    Icons.settings,
                                    size: 20.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  Positioned(
                    bottom: 0.03.sh,
                    left: 0.10.sw,
                    child: RotatedBox(
                      quarterTurns: 1 -
                          myCameraController.controller.value.description
                                  .sensorOrientation ~/
                              120,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Obx(() => Text(
                                myCameraController.currentExposureOffset
                                        .toStringAsFixed(1) +
                                    'x',
                                style: const TextStyle(color: Colors.black),
                              )),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0.05.sh,
                      child: RotatedBox(
                        quarterTurns: 0,
                        child: Container(
                          height: 10,
                          width: 0.7.sw,
                          child: Obx(() => Slider(
                                value: myCameraController
                                    .currentExposureOffset.value,
                                min: myCameraController
                                    .minAvailableExposureOffset.value,
                                max: myCameraController
                                    .maxAvailableExposureOffset.value,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {});
                                  myCameraController
                                      .currentExposureOffset.value = value;
                                  await myCameraController.controller.value
                                      .setExposureOffset(value);
                                },
                              )),
                        ),
                      )),
                  isCapturingImages
                      ? RotatedBox(
                          quarterTurns: 1 -
                              myCameraController.controller.value.description
                                      .sensorOrientation ~/
                                  120,
                          child: Obx(()=>Text(
                            '${myCameraController.totalImagesCaptured.value}',
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 80.sp),
                          )),
                        )
                      : const SizedBox.shrink(),
                  Positioned(
                    left: 0.05.sh,
                    child: RotatedBox(
                      quarterTurns: 1 -
                          myCameraController.controller.value.description
                                  .sensorOrientation ~/
                              120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              if (isCapturingImages) {
                                // stopCapturingImages();
                                return;
                              }
                              if(Platform.isAndroid){
                                navigationController.getOff(qaRootScreen);
                              }else{
                                navigationController
                                    .navigateToNamed(qaRootScreen);
                              }
                            },
                            child: CircleAvatar(
                              maxRadius: 20.r,
                              backgroundColor: isCapturingImages
                                  ? Colors.grey
                                  : primaryColor,
                              foregroundColor: primaryColor,
                              child: Text(
                                "View",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2
                                    ?.copyWith(
                                        color: Colors.white, fontSize: 8.sp),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 0.02.sh,
                          ),
                          InkWell(
                            onTap: isCapturingImages
                                ? stopCapturingImages
                                : startCapturingImages,
                            child: CircleAvatar(
                              maxRadius: 28.r,
                              backgroundColor:
                                  isCapturingImages ? red : primaryColor,
                              foregroundColor: primaryColor,
                              child: Text(
                                isCapturingImages ? "Stop" : "Start",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2
                                    ?.copyWith(
                                        color: Colors.white, fontSize: 12.sp),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 0.02.sh,
                          ),
                          // CircleAvatar(
                          //   backgroundColor: Colors.black87,
                          //   maxRadius: 20.r,
                          //   child: IconButton(
                          //     icon: Icon(
                          //       Icons.flip_camera_android,
                          //       size: 18.sp,
                          //       color: Colors.white70,
                          //     ),
                          //     onPressed: () {
                          //
                          //       if (myCameraController
                          //               .controller.value.description ==
                          //           myCameraController.cameras[0]) {
                          //         if (myCameraController.cameras.length > 0) {
                          //           onNewCameraSelected(
                          //               myCameraController.cameras[1]);
                          //         }
                          //       } else if (myCameraController
                          //               .controller.value.description ==
                          //           myCameraController.cameras[1]) {
                          //         onNewCameraSelected(
                          //             myCameraController.cameras[0]);
                          //
                          //       }
                          //     },
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onScaleStart: (details) {
                        _baseScale = _currentScale;
                      },
                      onScaleUpdate: (details) {
                        _currentScale = (_baseScale * details.scale)
                            .clamp(myCameraController.minAvailableZoom.value,
                                myCameraController.maxAvailableZoom.value)
                            .toDouble();
                        setState(() {
                          myCameraController.controller.value
                              .setZoomLevel(_currentScale);
                        });
                      })
                ],
              ),
            ),
          ),
        ));
  }



  double calculateByteToMb(int bytes) {
    return bytes / pow(1024, 2);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if(isCapturingImages){stopCapturingImages();}

    // REMOVING THE DATA OF PREVIOUS FILE CAPTURED
    myCameraController.tempAbsoluteOrientation.value = AngleCalculator(roll: 0, yaw: 0, pitch: 0);

    if(Platform.isAndroid){
      myCameraController.controller.value.dispose().then((_){
        debugPrint("CONTROLLER IS DISPOSED");
      });
    }


    super.dispose();

  }

  @override
  void initState() {
    // Fetching gallery album to check if the directory exists
    // If it exists simply load all of its media to our list
    // fetchGalleryImages();
    Get.put(MapController());
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: []);

    // GETTING SETTINGS DATA FROM LOCAL STORAGE
    myCameraController.captureBeep.value = SharedPref().pref.getBool('beep') ?? false;
    myCameraController.angleCalculator.value = SharedPref().pref.getBool('calculate') ?? false;
    myCameraController.angleCalculator.value = SharedPref().pref.getBool('wakelock') ?? false;
    myCameraController.angleCalculator.value = SharedPref().pref.getBool('dimmer') ?? true;


    if(Platform.isAndroid){
      if(myCameraController.controller.value.value.isInitialized){
        myCameraController.getAvailableCameras().then((_) {
          Future.delayed(const Duration(milliseconds: 1000), (){
            setState(() {});
          });
        });
      }
    }

    super.initState();
  }

  // CALCULATE WHETHER THE CAPTURED IMAGE WAS GREEN OR RED
  static String calculateImageAngle(AngleCalculator previousImage, AngleCalculator currentImage) {

    try{
      String flag = 'green';
      if (currentImage.pitch.abs() - previousImage.pitch.abs() < 15 &&
          currentImage.roll.abs() - previousImage.roll.abs() < 15 &&
          currentImage.yaw.abs() - previousImage.yaw.abs() < 15){
        // print("RedBox");
        flag = "green";
      }else if(currentImage.pitch.abs() - previousImage.pitch.abs() >=15 || currentImage.pitch.abs() - previousImage.pitch.abs() <=25  &&
          currentImage.roll.abs() - previousImage.roll.abs() >=15 || currentImage.roll.abs() - previousImage.roll.abs() <=25 &&
          currentImage.yaw.abs() - previousImage.yaw.abs() >=15 || currentImage.yaw.abs() - previousImage.yaw.abs() <=25){
        // print("GreenBox");
        flag = "yellow";
      }else if(currentImage.pitch.abs() - previousImage.pitch.abs() > 25 &&
          currentImage.roll.abs() - previousImage.roll.abs() > 25 &&
          currentImage.yaw.abs() - previousImage.yaw.abs() > 25){
        flag = "red";
      }
      return flag;
    }
    catch(e){
      debugPrint("ERROR FROM CALCULATION: $e");
      return 'red';
    }
  }

  Color checkIndicatorColor(String calculationResult){
    Color currentColor = Colors.green.shade800;
    switch(calculationResult){
      case "green":
        currentColor = Colors.green.shade800;
        break;
      case "yellow":
        currentColor = Colors.yellow.shade800;
        break;
      case "red":
        currentColor = Colors.red.shade800;
        break;
    }
    return currentColor;
  }

}
