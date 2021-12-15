import 'dart:async';
import 'dart:convert';
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
    Album projectDirectoryAlbum = imageAlbums.firstWhere(
        (element) =>
            myCameraController.projectNameController.value.text.trim() ==
            element.name,
        orElse: () => emptyAlbum);
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
        fetchGalleryImages();
        setState(() {
          debugPrint("Taking Pictures");
        });
        var xFile = await myCameraController.controller.value.takePicture();
        final capturedFile = File(xFile.path);
        debugPrint(capturedFile.path);
        final data = await readExifFromBytes(capturedFile.readAsBytesSync());
        if (data.containsKey('GPS GPSLongitude')) {
          print(true);
        } else {
          print(false);
        }

        // print(data);

        GallerySaver.saveImage(capturedFile.path,
                albumName: myCameraController.projectDirectory.path)
            .then((value) {
          debugPrint("Image: $value");
        });
        myCameraController.listOfCapturedImages.add(capturedFile);
        debugPrint(
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
                                  left: 0.12.sw,
                                  child: InkWell(
                                      onTap: () {
                                        navigationController.goBack();
                                      },
                                      child: Icon(
                                        Icons.chevron_left,
                                        color: Colors.white70,
                                        size: 22.sp,
                                      ))),
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
                                      child: Obx(() => Container(
                                            height: 20.sp,
                                            width: 20.sp,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade400,
                                              borderRadius:
                                                  BorderRadius.circular(3.r),
                                              border: Border.all(
                                                  color: Colors.grey.shade800
                                                      .withOpacity(0.4)),
                                              image: myCameraController
                                                      .listOfImagesFromAlbum
                                                      .isNotEmpty
                                                  ? DecorationImage(
                                                      image: PhotoProvider(
                                                          mediumId:
                                                              myCameraController
                                                                  .listOfImagesFromAlbum
                                                                  .last
                                                                  .id),
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
                                  _currentScale = (_baseScale * details.scale).clamp(myCameraController.minAvailableZoom.value, myCameraController.maxAvailableZoom.value).toDouble();
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
