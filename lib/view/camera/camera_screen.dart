import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:mvp_camera/app/router/router_generator.dart';
import 'package:mvp_camera/app/utils/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late PermissionStatus status;
  Timer? timer;

  bool isCapturingImages = false;

  int flashIndex = 0;
  List<Icon> listOfFlashButtons = [
    Icon(
      Icons.flash_on,
      size: 12.sp,
      color: Colors.white70,
    ),
    Icon(
      Icons.flash_off,
      size: 12.sp,
      color: Colors.white70,
    ),
    Icon(
      Icons.flash_auto,
      size: 12.sp,
      color: Colors.white70,
    ),
  ];

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: []);
    Wakelock.toggle(enable: true);
    super.initState();
  }

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
      myCameraController.controller.value.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(myCameraController.controller.value.description);
    }
  }

  void startCapturingImages() {
    setState(() {
      isCapturingImages = true;
    });
    // INITIALIZE DURATION FOR CAPTURING IMAGES
    Duration duration = Duration(
        seconds: int.parse(myCameraController.intervalController.value.text));
    timer = Timer.periodic(duration, (thisTimer) async {
      if (isCapturingImages == true) {
        setState(() {
          debugPrint("Taking Pictures");
        });
        var xFile = await myCameraController.controller.value.takePicture();
        myCameraController.listOfCapturedImages.add(File(xFile.path));
        print(
            "TOTAL IMAGES CAPTURED: ${myCameraController.listOfCapturedImages.length}");
      } else {
        timer?.cancel();
      }
    });
  }

  void stopCapturingImages() {
    setState(() {
      isCapturingImages = false;
    });
    timer?.cancel();
  }

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
                return Obx(() => Center(
                      child: Transform.scale(
                        scale: 1 /
                            (myCameraController
                                    .controller.value.value.aspectRatio *
                                deviceRatio),
                        child: AspectRatio(
                          aspectRatio: 1 /
                              myCameraController
                                  .controller.value.value.aspectRatio,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              myCameraController.controller.value
                                  .buildPreview(),
                              Positioned(
                                  top: 0.03.sh,
                                  left: 0.18.sw,
                                  child: InkWell(
                                      onTap: () {
                                        navigationController.goBack();
                                      },
                                      child: const Icon(
                                        Icons.chevron_left,
                                        color: Colors.white70,
                                      ))),
                              Positioned(
                                  top: 0.03.sh,
                                  right: 0.2.sw,
                                  child: InkWell(
                                    onTap: () {
                                      if (flashIndex == 0) {
                                        setState(() {
                                          myCameraController.controller.value
                                              .setFlashMode(FlashMode.off);
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
                                              .setFlashMode(FlashMode.always);
                                          flashIndex = 0;
                                        });
                                      }
                                    },
                                    child: CircleAvatar(
                                        backgroundColor: Colors.black87,
                                        maxRadius: 13.r,
                                        child: listOfFlashButtons[flashIndex]),
                                  )),
                              Positioned(
                                bottom: 0.05.sh,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        navigationController
                                            .navigateToNamed(inAppGallery);
                                        debugPrint("Gallery tapped");
                                      },
                                      child: Obx(() => Container(
                                            height: 18.sp,
                                            width: 18.sp,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade400,
                                              borderRadius:
                                                  BorderRadius.circular(3.r),
                                              border: Border.all(
                                                  color: Colors.grey.shade800
                                                      .withOpacity(0.4)),
                                              image: myCameraController
                                                      .listOfCapturedImages
                                                      .isNotEmpty
                                                  ? DecorationImage(
                                                      image: FileImage(
                                                          myCameraController
                                                              .listOfCapturedImages
                                                              .last),
                                                      fit: BoxFit.cover)
                                                  : null,
                                            ),
                                          )),
                                    ),
                                    SizedBox(
                                      width: 0.02.sh,
                                    ),
                                    InkWell(
                                      onTap: isCapturingImages
                                          ? stopCapturingImages
                                          : startCapturingImages,
                                      child: CircleAvatar(
                                        maxRadius: 20.r,
                                        backgroundColor: isCapturingImages
                                            ? red
                                            : primaryColor,
                                        foregroundColor: primaryColor,
                                        child: Text(
                                          isCapturingImages ? "Stop" : "Start",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2
                                              ?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 10.sp),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 0.02.sh,
                                    ),
                                    CircleAvatar(
                                      backgroundColor: Colors.black87,
                                      maxRadius: 13.r,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.flip_camera_android,
                                          size: 12.sp,
                                          color: Colors.white70,
                                        ),
                                        onPressed: () {
                                          if (myCameraController.controller
                                                  .value.description ==
                                              myCameraController.cameras[0]) {
                                            if (myCameraController
                                                    .cameras.length >
                                                0) {
                                              onNewCameraSelected(
                                                  myCameraController
                                                      .cameras[1]);
                                            }
                                          } else if (myCameraController
                                                  .controller
                                                  .value
                                                  .description ==
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
                                  print(details);
                                },
                                onScaleUpdate: (details) {
                                  setState(() {
                                    myCameraController.controller.value
                                        .setZoomLevel(details.scale);
                                  });
                                  print(details);
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ));
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

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }
}
