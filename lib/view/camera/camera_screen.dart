import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:mvp_camera/app/router/router_generator.dart';
import 'package:mvp_camera/app/utils/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wakelock/wakelock.dart';

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

  @override
  void initState() {
    // Fetching gallery album to check if the directory exists
    // If it exists simply load all of its media to our list
    fetchGalleryImages();

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

  void fetchGalleryImages() async {
    debugPrint("GALLERY FETCHED");
    final List<Album> imageAlbums = await PhotoGallery.listAlbums(
      mediumType: MediumType.image,
    );

    // log(imageAlbums.length.toString());
    // log(myCameraController.projectNameController.value.text.toString());
    // log(imageAlbums.length.toString());
    // for (Album item in imageAlbums) {
    //   log(item.name.toString());
    // }
    if (Platform.isAndroid) {
      Album projectDirectoryAlbum = imageAlbums.firstWhere(
          (element) =>
              myCameraController.projectNameController.value.text.trim() ==
              element.name?.trim(),
          orElse: () => emptyAlbum);
      // log("val $projectDirectoryAlbum");
      if (projectDirectoryAlbum.count != 0) {
        MediaPage mediaPage = await projectDirectoryAlbum.listMedia();

        setState(() {
          myCameraController.listOfImagesFromAlbum.value = mediaPage.items;
        });

        debugPrint(
            "Length of images from album is: ${myCameraController.listOfImagesFromAlbum.length}");
      } else {
        debugPrint("Directory is currently empty");
        debugPrint(
            "Length of images from album is: ${myCameraController.listOfImagesFromAlbum.length}");
        myCameraController.listOfImagesFromAlbum.value = <Medium>[];
      }
    }
    if (Platform.isIOS) {
      Album projectDirectoryAlbum = imageAlbums.firstWhere(
          (element) =>
              myCameraController.projectNameController.value.text.trim() ==
              element.name?.trim(),
          orElse: () => emptyAlbum);
      // log("val $projectDirectoryAlbum");
      if (projectDirectoryAlbum.count != 0) {
        MediaPage mediaPage = await projectDirectoryAlbum.listMedia();

        setState(() {
          myCameraController.listOfImagesFromAlbum.value = mediaPage.items;
        });

        debugPrint(
            "Length of images from album is: ${myCameraController.listOfImagesFromAlbum.length}");
      } else {
        debugPrint("Directory is currently empty");
        debugPrint(
            "Length of images from album is: ${myCameraController.listOfImagesFromAlbum.length}");
        myCameraController.listOfImagesFromAlbum.value = <Medium>[];
      }
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
        milliseconds:
            (double.parse(myCameraController.intervalController.value.text) *
                    1000)
                .toInt());
    timer = Timer.periodic(duration, (thisTimer) async {
      if (isCapturingImages == true) {
        // fetchGalleryImages();
        setState(() {
          debugPrint("Taking Pictures");
        });
        var xFile = await myCameraController.controller.value.takePicture();
        final capturedFile = File(xFile.path);
        debugPrint(capturedFile.path);

        // final data = await readExifFromBytes(capturedFile.readAsBytesSync());
        // if (data.containsKey('GPS GPSLongitude')) {
        //   print(true);
        // } else {
        //   print(false);
        // }

        // print(data);

        // GallerySaver.saveImage(capturedFile.path,
        //         albumName: myCameraController.projectDirectory.path)
        //     .then((value) {
        //   debugPrint("Image: $value");
        // });
        // myCameraController.listOfCapturedImages.add(capturedFile);
        // debugPrint(
        //     "TOTAL IMAGES CAPTURED: ${myCameraController.listOfCapturedImages.length}");

        if (Platform.isAndroid) {
          print(capturedFile.path);

          GallerySaver.saveImage(capturedFile.path,
                  albumName: myCameraController.projectDirectory.path)
              .then((value) {
            debugPrint("Image: $value");
          });

          myCameraController.listOfCapturedImages.add(capturedFile);
          debugPrint(
              "TOTAL IMAGES CAPTURED: ${myCameraController.listOfCapturedImages.length}");
          capturedFile.create(recursive: true);
        } else if (Platform.isIOS) {
          GallerySaver.saveImage(capturedFile.path,
                  albumName:
                      myCameraController.projectNameController.value.text)
              .then((value) {
            debugPrint("Image: $value");
          });
          myCameraController.listOfCapturedImages.add(capturedFile);
          debugPrint(
              "TOTAL IMAGES CAPTURED: ${myCameraController.listOfCapturedImages.length}");
        }
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

  void saveImagesToGallery() {
    myCameraController.listOfCapturedImages.forEach((element) {
      GallerySaver.saveImage(element.path,
              albumName: myCameraController.projectDirectory.path)
          .then((value) {
        debugPrint("Image: $value");
      });
    });
    myCameraController.listOfCapturedImages.clear();
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
                                left: 0.12.sw,
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
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: 0.03.sh,
                                  right: 0.15.sw,
                                  child: InkWell(
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
                                          myCameraController
                                                  .currentExposureOffset
                                                  .toStringAsFixed(1) +
                                              'x',
                                          style: const TextStyle(
                                              color: Colors.black),
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
                                                .minAvailableExposureOffset
                                                .value,
                                            max: myCameraController
                                                .maxAvailableExposureOffset
                                                .value,
                                            activeColor: Colors.white,
                                            inactiveColor: Colors.white30,
                                            onChanged: (value) async {
                                              setState(() {});
                                              myCameraController
                                                  .currentExposureOffset
                                                  .value = value;
                                              await myCameraController
                                                  .controller.value
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
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              fontSize: 80.sp),
                                    )
                                  : const SizedBox.shrink(),
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
                                        fetchGalleryImages();
                                      },
                                      child: InkWell(
                                        onTap: (){
                                          navigationController.navigateToNamed(qaRootScreen);
                                        },
                                        child: CircleAvatar(
                                          maxRadius: 20.r,
                                          backgroundColor: primaryColor,
                                          foregroundColor: primaryColor,
                                          child: Text(
                                            "QA",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2
                                                ?.copyWith(
                                                color: Colors.white,
                                                fontSize: 12.sp),
                                          ),
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
                                                  fontSize: 12.sp),
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
                                  _baseScale = _currentScale;
                                },
                                onScaleUpdate: (details) {
                                  _currentScale = (_baseScale * details.scale)
                                      .clamp(
                                          myCameraController
                                              .minAvailableZoom.value,
                                          myCameraController
                                              .maxAvailableZoom.value)
                                      .toDouble();
                                  setState(() {
                                    myCameraController.controller.value
                                        .setZoomLevel(_currentScale);
                                  });
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
