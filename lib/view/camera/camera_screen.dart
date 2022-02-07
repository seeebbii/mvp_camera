import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:metadata/metadata.dart' as meta;
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:mvp_camera/app/router/router_generator.dart';
import 'package:mvp_camera/app/utils/colors.dart';
import 'package:mvp_camera/app/utils/dialogs.dart';
import 'package:mvp_camera/app/utils/handle_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wakelock/wakelock.dart';

import '../../controller/sensor_controller.dart';

double calculateByteToMb(int bytes) {
  return bytes / pow(1024, 2);
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  // Initializing empty gallery album
  final emptyAlbum = Album.fromJson(
      const {'id': 'null', 'count': 0, 'mediumType': 'image', 'name': 'null'});
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  late PermissionStatus status;
  Timer? timer;

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

  // SINGLETON CLASS OBJECT
  final HandleFile handleFile = HandleFile();

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    // Instantiating the camera controller

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.veryHigh,
      // imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Replace with the new controller
    if (mounted) {
      setState(() {
        myCameraController.controller.value = cameraController;
      });
    }
    myCameraController.isCameraInitialized.value = false;

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize().then((value) {
        debugPrint("CONTROLLER INITIALIZED");
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
      print("CAMERA SCREEN INACTIVE LIFE CYCLE");
      myCameraController.controller.value.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(myCameraController.controller.value.description);
    }
  }

  void startCapturingImages() {
    Get.lazyPut(() => SensorController());
    final sensorController = Get.find<SensorController>();
    // INITIALIZING CSV FILE AND DEVICE TOTAL/FREE STORAGE
    sensorController.initCsvFile();
    fetchFilesController.initializeDeviceStorageInfo();
    setState(() {
      isCapturingImages = true;
    });
    // INITIALIZE DURATION FOR CAPTURING IMAGES
    Duration duration = Duration(
        milliseconds:
            (double.parse(myCameraController.intervalController.value.text) *
                    1000)
                .toInt());
    timer = Timer.periodic(duration, (thisTimer) async {
      if (isCapturingImages == true) {
        // SAVING INFO TO CSV FILE
        sensorController.createCsvFile();

        // IF DEVICE IS LESS THAN 2 GB, STOP CAPTURING
        if (fetchFilesController.freeDiskSpace <= 2048) {
          Dialogs.openErrorSnackBar(context, 'Device low on storage!');
          stopCapturingImages();
          return;
        }

        // SETTING BEEP TO TRUE EVERY TIME THE PICTURE IS CLICKED
        if (myCameraController.captureBeep.value) {
          FlutterBeep.beep(true);
        }
        var xFile = await myCameraController.controller.value.takePicture();
        File newFile = File(
            "${myCameraController.projectDirectory.path}/${DateTime.now().toUtc().toIso8601String()}.jpeg");

        // handleFile.saveFile(newFile, xFile);
        xFile.saveTo(newFile.path);

        // handleFile.initialize(newFile);
        print(newFile.path);

        handleFile.setFileLatLong(
            newFile,
            mapController.userLocation.value.latitude,
            mapController.userLocation.value.longitude);

        myCameraController.listOfCapturedImages.add(newFile);

        double sizeOfFile = calculateByteToMb(newFile.lengthSync());
        fetchFilesController.freeDiskSpace -= sizeOfFile;
        print(
            "AVAILABLE FREE DISK SPACE: ${fetchFilesController.freeDiskSpace}");

        if (Platform.isAndroid) {

          debugPrint(
              "TOTAL IMAGES CAPTURED: ${myCameraController.listOfCapturedImages.length}");
        } else if (Platform.isIOS) {
          GallerySaver.saveImage(newFile.path,
                  albumName:
                      myCameraController.projectNameController.value.text)
              .then((value) {
            debugPrint("Image: $value");
          });
          debugPrint(
              "TOTAL IMAGES CAPTURED: ${myCameraController.listOfCapturedImages.length}");
        }
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
      body: FutureBuilder(
        future: myCameraController.checkCameraPermission(),
        builder: (ctx, AsyncSnapshot<PermissionStatus> snap) {
          if (snap.hasData) {
            if (snap.data!.isGranted) {
              if (myCameraController.controller.value.value.isInitialized) {
                return landscapeCameraLeft(deviceRatio);
                // return OrientationBuilder(builder: (ctx, orientation){
                //   if(orientation == DeviceOrientation.landscapeLeft){
                //     return landscapeCameraLeft(deviceRatio);
                //   }if(orientation == DeviceOrientation.landscapeRight){
                //     return landscapeCameraRight(deviceRatio);
                //   }else{
                //     return portraitCameraUp(deviceRatio);
                //   }
                // });
              } else {
                return Container(
                  height: size.height,
                  width: size.width,
                  color: Colors.black,
                );
              }
            } else {
              return const Center(
                  child: Text(
                      "Please allow required permissions and restart our app"));
            }
          } else {
            return const Center(child: Text("Cannot Initialize Camera"));
          }
        },
      ),
    );
  }

  Widget landscapeCameraLeft(double deviceRatio) {
    return Obx(() => Center(
          child: Transform.scale(
            scale: 1 /
                (myCameraController.controller.value.value.aspectRatio *
                    deviceRatio),
            child: AspectRatio(
              aspectRatio:
                  1 / myCameraController.controller.value.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  myCameraController.controller.value.buildPreview(),
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
                          print("point : $point");

                          // Manually focus
                          myCameraController.controller.value
                              .setFocusPoint(point);
                          myCameraController.controller.value
                              .setFocusMode(FocusMode.locked);
                          myCameraController.controller.value
                              .setExposureMode(ExposureMode.locked);
                          // Manually set light exposure
                          myCameraController.controller.value
                              .setExposurePoint(point);
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
                      print("Auto focus Enabled");
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
                    right: 0.15.sw,
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
                          child: Text(
                            '${myCameraController.listOfCapturedImages.length}',
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 80.sp),
                          ),
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
                              navigationController
                                  .navigateToNamed(qaRootScreen);
                            },
                            child: CircleAvatar(
                              maxRadius: 20.r,
                              backgroundColor: isCapturingImages
                                  ? Colors.grey
                                  : primaryColor,
                              foregroundColor: primaryColor,
                              child: Text(
                                "QA",
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
                          CircleAvatar(
                            backgroundColor: Colors.black87,
                            maxRadius: 20.r,
                            child: IconButton(
                              icon: Icon(
                                Icons.flip_camera_android,
                                size: 18.sp,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                if (myCameraController
                                        .controller.value.description ==
                                    myCameraController.cameras[0]) {
                                  if (myCameraController.cameras.length > 0) {
                                    onNewCameraSelected(
                                        myCameraController.cameras[1]);
                                  }
                                } else if (myCameraController
                                        .controller.value.description ==
                                    myCameraController.cameras[1]) {
                                  onNewCameraSelected(
                                      myCameraController.cameras[0]);
                                }
                              },
                            ),
                          )
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

  Widget landscapeCameraRight(double deviceRatio) {
    return Obx(() => Center(
          child: Transform.scale(
            scale: 1 /
                (myCameraController.controller.value.value.aspectRatio *
                    deviceRatio),
            child: AspectRatio(
              aspectRatio:
                  1 / myCameraController.controller.value.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  myCameraController.controller.value.buildPreview(),
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
                          print("point : $point");

                          // Manually focus
                          myCameraController.controller.value
                              .setFocusPoint(point);
                          myCameraController.controller.value
                              .setFocusMode(FocusMode.locked);
                          myCameraController.controller.value
                              .setExposureMode(ExposureMode.locked);
                          // Manually set light exposure
                          myCameraController.controller.value
                              .setExposurePoint(point);
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
                      print("Auto focus Enabled");
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
                    right: 0.15.sw,
                    child: RotatedBox(
                      quarterTurns: 1 -
                          myCameraController.controller.value.description
                                  .sensorOrientation ~/
                              45,
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
                      top: 0.03.sh,
                      left: 0.12.sw,
                      child: RotatedBox(
                        quarterTurns: 1 -
                            myCameraController.controller.value.description
                                    .sensorOrientation ~/
                                45,
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
                              45,
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
                                  45,
                          child: Text(
                            '${myCameraController.listOfCapturedImages.length}',
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 80.sp),
                          ),
                        )
                      : const SizedBox.shrink(),
                  Positioned(
                    left: 0.05.sh,
                    child: RotatedBox(
                      quarterTurns: 1 -
                          myCameraController.controller.value.description
                                  .sensorOrientation ~/
                              45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              if (isCapturingImages) {
                                // stopCapturingImages();
                                return;
                              }
                              navigationController
                                  .navigateToNamed(qaRootScreen);
                            },
                            child: CircleAvatar(
                              maxRadius: 20.r,
                              backgroundColor: isCapturingImages
                                  ? Colors.grey
                                  : primaryColor,
                              foregroundColor: primaryColor,
                              child: Text(
                                "QA",
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
                          CircleAvatar(
                            backgroundColor: Colors.black87,
                            maxRadius: 20.r,
                            child: IconButton(
                              icon: Icon(
                                Icons.flip_camera_android,
                                size: 18.sp,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                if (myCameraController
                                        .controller.value.description ==
                                    myCameraController.cameras[0]) {
                                  if (myCameraController.cameras.length > 0) {
                                    onNewCameraSelected(
                                        myCameraController.cameras[1]);
                                  }
                                } else if (myCameraController
                                        .controller.value.description ==
                                    myCameraController.cameras[1]) {
                                  onNewCameraSelected(
                                      myCameraController.cameras[0]);
                                }
                              },
                            ),
                          )
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

  Widget portraitCameraUp(double deviceRatio) {
    return Obx(() => Center(
          child: Transform.scale(
            scale: 1 /
                (myCameraController.controller.value.value.aspectRatio *
                    deviceRatio),
            child: AspectRatio(
              aspectRatio:
                  1 / myCameraController.controller.value.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  myCameraController.controller.value.buildPreview(),
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
                          print("point : $point");

                          // Manually focus
                          myCameraController.controller.value
                              .setFocusPoint(point);
                          myCameraController.controller.value
                              .setFocusMode(FocusMode.locked);
                          // Manually set light exposure
                          myCameraController.controller.value
                              .setExposurePoint(point);
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
                      print("Auto focus Enabled");
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
                    left: 0.12.sw,
                    child: ElevatedButton(
                      onPressed: () {
                        navigationController.goBack();
                      },
                      child: Text(
                        "Back",
                        style: Theme.of(context).textTheme.headline1?.copyWith(
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
                  Positioned(
                      top: 0.03.sh,
                      right: 0.15.sw,
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
                        ],
                      )),
                  Positioned(
                    top: 0.18.sh,
                    right: 0.12.sw,
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
                  Positioned(
                      top: 0.2.sh,
                      right: 0.15.sw,
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Container(
                          height: 10,
                          width: 1.sw,
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
                      ? Text(
                          '${myCameraController.listOfCapturedImages.length}',
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 80.sp),
                        )
                      : const SizedBox.shrink(),
                  Positioned(
                    bottom: 0.05.sh,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            if (isCapturingImages) {
                              // stopCapturingImages();
                              return;
                            }
                            navigationController.navigateToNamed(qaRootScreen);
                          },
                          child: CircleAvatar(
                            maxRadius: 20.r,
                            backgroundColor:
                                isCapturingImages ? Colors.grey : primaryColor,
                            foregroundColor: primaryColor,
                            child: Text(
                              "QA",
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
                        CircleAvatar(
                          backgroundColor: Colors.black87,
                          maxRadius: 20.r,
                          child: IconButton(
                            icon: Icon(
                              Icons.flip_camera_android,
                              size: 18.sp,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              if (myCameraController
                                      .controller.value.description ==
                                  myCameraController.cameras[0]) {
                                if (myCameraController.cameras.length > 0) {
                                  onNewCameraSelected(
                                      myCameraController.cameras[1]);
                                }
                              } else if (myCameraController
                                      .controller.value.description ==
                                  myCameraController.cameras[1]) {
                                onNewCameraSelected(
                                    myCameraController.cameras[0]);
                              }
                            },
                          ),
                        )
                      ],
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

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  void initState() {
    // Fetching gallery album to check if the directory exists
    // If it exists simply load all of its media to our list
    // fetchGalleryImages();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: []);

    super.initState();
  }
}

Future<void> save(List<File> list) async {
  for (var element in list) {
    GallerySaver.saveImage(
      element.path,
    ).then((value) {
      debugPrint("Image: $value");
    });
  }
}
