import 'package:flutter/material.dart';
// TODO : CAMERA SCREEN GALLERY FUNCTION

// Widget galleryFunction(){
//   return Obx(() => Container(
//     height: 20.sp,
//     width: 20.sp,
//     decoration: BoxDecoration(
//       color: Colors.grey.shade400,
//       borderRadius:
//       BorderRadius.circular(3.r),
//       border: Border.all(
//           color: Colors.grey.shade800
//               .withOpacity(0.4)),
//       image: (Platform.isAndroid)
//           ? myCameraController
//           .listOfImagesFromAlbum
//           .isNotEmpty
//           ? DecorationImage(
//           image: PhotoProvider(
//               mediumId:
//               myCameraController
//                   .listOfImagesFromAlbum
//                   .last
//                   .id),
//           fit: BoxFit.cover)
//           : null
//           : myCameraController
//           .listOfCapturedImages
//           .isNotEmpty
//           ? DecorationImage(
//           image: FileImage(
//               myCameraController
//                   .listOfCapturedImages
//                   .first),
//           fit: BoxFit.cover)
//           : null,
//     ),
//   ));
// }

// TODO
// FIND THE CSV FILE BUG
// IMPLEMENT THE LOGIC TO FIND THE ANGLE BY CALCULATING GYRO AND ACCELEROMETER COORDINATES

// void fetchGalleryImages() async {
//   debugPrint("GALLERY FETCHED");
//   final List<Album> imageAlbums = await PhotoGallery.listAlbums(
//     mediumType: MediumType.image,
//   );
//
//   // log(imageAlbums.length.toString());
//   // log(myCameraController.projectNameController.value.text.toString());
//   // log(imageAlbums.length.toString());
//   // for (Album item in imageAlbums) {
//   //   log(item.name.toString());
//   // }
//   if (Platform.isAndroid) {
//     Album projectDirectoryAlbum = imageAlbums.firstWhere(
//             (element) =>
//         myCameraController.projectNameController.value.text.trim() ==
//             element.name?.trim(),
//         orElse: () => emptyAlbum);
//     // log("val $projectDirectoryAlbum");
//     if (projectDirectoryAlbum.count != 0) {
//       MediaPage mediaPage = await projectDirectoryAlbum.listMedia();
//
//       setState(() {
//         myCameraController.listOfImagesFromAlbum.value = mediaPage.items;
//       });
//
//       debugPrint(
//           "Length of images from album is: ${myCameraController
//               .listOfImagesFromAlbum.length}");
//     } else {
//       debugPrint("Directory is currently empty");
//       debugPrint(
//           "Length of images from album is: ${myCameraController
//               .listOfImagesFromAlbum.length}");
//       myCameraController.listOfImagesFromAlbum.value = <Medium>[];
//     }
//   }
//   if (Platform.isIOS) {
//     Album projectDirectoryAlbum = imageAlbums.firstWhere(
//             (element) =>
//         myCameraController.projectNameController.value.text.trim() ==
//             element.name?.trim(),
//         orElse: () => emptyAlbum);
//     // log("val $projectDirectoryAlbum");
//     if (projectDirectoryAlbum.count != 0) {
//       MediaPage mediaPage = await projectDirectoryAlbum.listMedia();
//
//       setState(() {
//         myCameraController.listOfImagesFromAlbum.value = mediaPage.items;
//       });
//
//       debugPrint(
//           "Length of images from album is: ${myCameraController
//               .listOfImagesFromAlbum.length}");
//     } else {
//       debugPrint("Directory is currently empty");
//       debugPrint(
//           "Length of images from album is: ${myCameraController
//               .listOfImagesFromAlbum.length}");
//       myCameraController.listOfImagesFromAlbum.value = <Medium>[];
//     }
//   }
// }






// TODO :: CAMERA PORTRAIT
// Widget portraitCameraUp(double deviceRatio) {
//   return Obx(() => Center(
//         child: Transform.scale(
//           scale: 1 /
//               (myCameraController.controller.value.value.aspectRatio *
//                   deviceRatio),
//           child: AspectRatio(
//             aspectRatio:
//                 1 / myCameraController.controller.value.value.aspectRatio,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 myCameraController.controller.value.buildPreview(),
//                 GestureDetector(
//                   onTapUp: (TapUpDetails tapUpDetails) {
//                     // TAP TO FOCUS
//                     if (myCameraController
//                         .controller.value.value.isInitialized) {
//                       // CHECK IF FOCUS POINT AVAILABLE
//                       if (myCameraController
//                           .controller.value.value.focusPointSupported) {
//                         showFocusCircle = true;
//                         x = tapUpDetails.localPosition.dx;
//                         y = tapUpDetails.localPosition.dy;
//
//                         double fullWidth = MediaQuery.of(context).size.width;
//                         double cameraHeight = fullWidth *
//                             myCameraController
//                                 .controller.value.value.aspectRatio;
//
//                         double xp = x / fullWidth;
//                         double yp = y / cameraHeight;
//
//                         Offset point = Offset(xp, yp);
//                         print("point : $point");
//
//                         // Manually focus
//                         myCameraController.controller.value
//                             .setFocusPoint(point);
//                         myCameraController.controller.value
//                             .setFocusMode(FocusMode.locked);
//                         // Manually set light exposure
//                         myCameraController.controller.value
//                             .setExposurePoint(point);
//                         setState(() {
//                           Future.delayed(const Duration(seconds: 2))
//                               .whenComplete(() {
//                             setState(() {
//                               showFocusCircle = false;
//                               focusModeAuto = false;
//                             });
//                           });
//                         });
//                       }
//                     }
//                   },
//                   onLongPress: () {
//                     print("Auto focus Enabled");
//                     setState(() {
//                       focusModeAuto = true;
//                       myCameraController.controller.value
//                           .setFocusMode(FocusMode.auto);
//                       myCameraController.controller.value
//                           .setExposureMode(ExposureMode.auto);
//                     });
//                   },
//                 ),
//                 if (showFocusCircle)
//                   Positioned(
//                       top: y - 20,
//                       left: x - 20,
//                       child: Container(
//                         height: 40,
//                         width: 40,
//                         decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border:
//                                 Border.all(color: Colors.white, width: 1.5)),
//                       )),
//                 Positioned(
//                   top: 0.03.sh,
//                   left: 0.12.sw,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       navigationController.goBack();
//                     },
//                     child: Text(
//                       "Back",
//                       style: Theme.of(context).textTheme.headline1?.copyWith(
//                           fontSize: 10.sp,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       onPrimary: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 10),
//                       primary: primaryColor,
//                       shape: RoundedRectangleBorder(
//                           //to set border radius to button
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                     top: 0.03.sh,
//                     right: 0.15.sw,
//                     child: Row(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             if (flashIndex == 0) {
//                               setState(() {
//                                 myCameraController.controller.value
//                                     .setFlashMode(FlashMode.always);
//                                 flashIndex = 1;
//                               });
//                             } else if (flashIndex == 1) {
//                               setState(() {
//                                 myCameraController.controller.value
//                                     .setFlashMode(FlashMode.auto);
//                                 flashIndex = 2;
//                               });
//                             } else {
//                               setState(() {
//                                 myCameraController.controller.value
//                                     .setFlashMode(FlashMode.off);
//                                 flashIndex = 0;
//                               });
//                             }
//                           },
//                           child: CircleAvatar(
//                               backgroundColor: Colors.black87,
//                               maxRadius: 15.r,
//                               child: listOfFlashButtons[flashIndex]),
//                         ),
//                         SizedBox(
//                           width: 5.sm,
//                         ),
//                         Container(
//                           decoration: const BoxDecoration(
//                               color: Colors.black,
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(15))),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               focusModeAuto ? "Auto" : "Locked",
//                               style: TextStyle(
//                                   color: Colors.white, fontSize: 14.sm),
//                             ),
//                           ),
//                         ),
//                       ],
//                     )),
//                 Positioned(
//                   top: 0.18.sh,
//                   right: 0.12.sw,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Obx(() => Text(
//                             myCameraController.currentExposureOffset
//                                     .toStringAsFixed(1) +
//                                 'x',
//                             style: const TextStyle(color: Colors.black),
//                           )),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                     top: 0.2.sh,
//                     right: 0.15.sw,
//                     child: RotatedBox(
//                       quarterTurns: 3,
//                       child: Container(
//                         height: 10,
//                         width: 1.sw,
//                         child: Obx(() => Slider(
//                               value: myCameraController
//                                   .currentExposureOffset.value,
//                               min: myCameraController
//                                   .minAvailableExposureOffset.value,
//                               max: myCameraController
//                                   .maxAvailableExposureOffset.value,
//                               activeColor: Colors.white,
//                               inactiveColor: Colors.white30,
//                               onChanged: (value) async {
//                                 setState(() {});
//                                 myCameraController
//                                     .currentExposureOffset.value = value;
//                                 await myCameraController.controller.value
//                                     .setExposureOffset(value);
//                               },
//                             )),
//                       ),
//                     )),
//                 isCapturingImages
//                     ? Text(
//                         '${myCameraController.totalImagesCaptured.value}',
//                         style: Theme.of(context)
//                             .textTheme
//                             .headline1
//                             ?.copyWith(
//                                 color: Colors.white.withOpacity(0.5),
//                                 fontSize: 80.sp),
//                       )
//                     : const SizedBox.shrink(),
//                 Positioned(
//                   bottom: 0.05.sh,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           if (isCapturingImages) {
//                             // stopCapturingImages();
//                             return;
//                           }
//                           navigationController.navigateToNamed(qaRootScreen);
//                         },
//                         child: CircleAvatar(
//                           maxRadius: 20.r,
//                           backgroundColor:
//                               isCapturingImages ? Colors.grey : primaryColor,
//                           foregroundColor: primaryColor,
//                           child: Text(
//                             "Export",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headline2
//                                 ?.copyWith(
//                                     color: Colors.white, fontSize: 8.sp),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 0.02.sh,
//                       ),
//                       InkWell(
//                         onTap: isCapturingImages
//                             ? stopCapturingImages
//                             : startCapturingImages,
//                         child: CircleAvatar(
//                           maxRadius: 28.r,
//                           backgroundColor:
//                               isCapturingImages ? red : primaryColor,
//                           foregroundColor: primaryColor,
//                           child: Text(
//                             isCapturingImages ? "Stop" : "Start",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headline2
//                                 ?.copyWith(
//                                     color: Colors.white, fontSize: 12.sp),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 0.02.sh,
//                       ),
//                       CircleAvatar(
//                         backgroundColor: Colors.black87,
//                         maxRadius: 20.r,
//                         child: IconButton(
//                           icon: Icon(
//                             Icons.flip_camera_android,
//                             size: 18.sp,
//                             color: Colors.white70,
//                           ),
//                           onPressed: () {
//                             if (myCameraController
//                                     .controller.value.description ==
//                                 myCameraController.cameras[0]) {
//                               if (myCameraController.cameras.length > 0) {
//                                 onNewCameraSelected(
//                                     myCameraController.cameras[1]);
//                               }
//                             } else if (myCameraController
//                                     .controller.value.description ==
//                                 myCameraController.cameras[1]) {
//                               onNewCameraSelected(
//                                   myCameraController.cameras[0]);
//                             }
//                           },
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//                 GestureDetector(
//                     behavior: HitTestBehavior.translucent,
//                     onScaleStart: (details) {
//                       _baseScale = _currentScale;
//                     },
//                     onScaleUpdate: (details) {
//                       _currentScale = (_baseScale * details.scale)
//                           .clamp(myCameraController.minAvailableZoom.value,
//                               myCameraController.maxAvailableZoom.value)
//                           .toDouble();
//                       setState(() {
//                         myCameraController.controller.value
//                             .setZoomLevel(_currentScale);
//                       });
//                     })
//               ],
//             ),
//           ),
//         ),
//       ));


















// TODO :: FRONT CAMERA
// Widget landscapeCameraRight(double deviceRatio) {
//   return Obx(() => Center(
//     child: Transform.scale(
//       scale: 1 /
//           (myCameraController.controller.value.value.aspectRatio *
//               deviceRatio),
//       child: AspectRatio(
//         aspectRatio:
//         1 / myCameraController.controller.value.value.aspectRatio,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             myCameraController.controller.value.value.isInitialized ?  myCameraController.controller.value.buildPreview() : const SizedBox.shrink(),
//             GestureDetector(
//               onTapUp: (TapUpDetails tapUpDetails) {
//                 // TAP TO FOCUS
//                 if (myCameraController
//                     .controller.value.value.isInitialized) {
//                   // CHECK IF FOCUS POINT AVAILABLE
//                   if (myCameraController
//                       .controller.value.value.focusPointSupported) {
//                     showFocusCircle = true;
//                     x = tapUpDetails.localPosition.dx;
//                     y = tapUpDetails.localPosition.dy;
//
//                     double fullWidth = MediaQuery.of(context).size.width;
//                     double cameraHeight = fullWidth *
//                         myCameraController
//                             .controller.value.value.aspectRatio;
//
//                     double xp = x / fullWidth;
//                     double yp = y / cameraHeight;
//
//                     Offset point = Offset(xp, yp);
//                     debugPrint("point : $point");
//
//                     // Manually focus
//                     myCameraController.controller.value
//                         .setFocusPoint(point);
//                     myCameraController.controller.value
//                         .setFocusMode(FocusMode.locked);
//                     myCameraController.controller.value
//                         .setExposureMode(ExposureMode.locked);
//                     // Manually set light exposure
//                     myCameraController.controller.value
//                         .setExposurePoint(point);
//                     setState(() {
//                       Future.delayed(const Duration(seconds: 2))
//                           .whenComplete(() {
//                         setState(() {
//                           showFocusCircle = false;
//                           focusModeAuto = false;
//                         });
//                       });
//                     });
//                   }
//                 }
//               },
//               onLongPress: () {
//                 debugPrint("Auto focus Enabled");
//                 setState(() {
//                   focusModeAuto = true;
//                   myCameraController.controller.value
//                       .setFocusMode(FocusMode.auto);
//                   myCameraController.controller.value
//                       .setExposureMode(ExposureMode.auto);
//                 });
//               },
//             ),
//             if (showFocusCircle)
//               Positioned(
//                   top: y - 20,
//                   left: x - 20,
//                   child: Container(
//                     height: 40,
//                     width: 40,
//                     decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border:
//                         Border.all(color: Colors.white, width: 1.5)),
//                   )),
//             Positioned(
//               top: 0.03.sh,
//               right: 0.10.sw,
//               child: RotatedBox(
//                 quarterTurns: 1 -
//                     myCameraController.controller.value.description
//                         .sensorOrientation ~/
//                         360,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     navigationController.goBack();
//                   },
//                   child: Text(
//                     "Back",
//                     style: Theme.of(context)
//                         .textTheme
//                         .headline1
//                         ?.copyWith(
//                         fontSize: 10.sp,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     onPrimary: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 10),
//                     primary: primaryColor,
//                     shape: RoundedRectangleBorder(
//                       //to set border radius to button
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 0.03.sh,
//               right: 0.10.sw,
//               child: RotatedBox(
//                 quarterTurns: 1 -
//                     myCameraController.controller.value.description
//                         .sensorOrientation ~/
//                         360,
//                 child: Obx(()=>Row(
//                   children: [
//                     myCameraController.angleCalculator.value ?
//                     Container(
//                       padding: EdgeInsets.all(10.r),
//                       decoration: BoxDecoration(
//                         color: checkIndicatorColor(myCameraController.redGreenIndicatorCurrentImage.value),
//                         border: Border.all(color: Colors.black54),
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ) : const SizedBox.shrink(),
//                     SizedBox(width: 0.01.sw,),
//                     // Text( myCameraController.redGreenIndicatorCurrentImage.value ?  'Stop' : "Pass", style: Theme.of(context).textTheme.headline1?.copyWith(color: Colors.white, fontSize: 17.sp),),
//                   ],
//                 )),
//               ),
//             ),
//             Positioned(
//                 top: 0.03.sh,
//                 left: 0.12.sw,
//                 child: RotatedBox(
//                   quarterTurns: 1 -
//                       myCameraController.controller.value.description
//                           .sensorOrientation ~/
//                           360,
//                   child: Row(
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           if (flashIndex == 0) {
//                             setState(() {
//                               myCameraController.controller.value
//                                   .setFlashMode(FlashMode.always);
//                               flashIndex = 1;
//                             });
//                           } else if (flashIndex == 1) {
//                             setState(() {
//                               myCameraController.controller.value
//                                   .setFlashMode(FlashMode.auto);
//                               flashIndex = 2;
//                             });
//                           } else {
//                             setState(() {
//                               myCameraController.controller.value
//                                   .setFlashMode(FlashMode.off);
//                               flashIndex = 0;
//                             });
//                           }
//                         },
//                         child: CircleAvatar(
//                             backgroundColor: Colors.black87,
//                             maxRadius: 15.r,
//                             child: listOfFlashButtons[flashIndex]),
//                       ),
//                       SizedBox(
//                         width: 5.sm,
//                       ),
//                       Container(
//                         decoration: const BoxDecoration(
//                             color: Colors.black,
//                             borderRadius:
//                             BorderRadius.all(Radius.circular(15))),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             focusModeAuto ? "Auto" : "Locked",
//                             style: TextStyle(
//                                 color: Colors.white, fontSize: 14.sm),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 5.sm,
//                       ),
//                       GestureDetector(
//                         onTap: () => navigationController
//                             .navigateToNamed(settingsScreen),
//                         child: Container(
//                           decoration: const BoxDecoration(
//                               color: Colors.black,
//                               borderRadius:
//                               BorderRadius.all(Radius.circular(15))),
//                           child: Padding(
//                             padding: const EdgeInsets.all(3.5),
//                             child: Icon(
//                               Icons.settings,
//                               size: 20.sp,
//                               color: Colors.white70,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )),
//             Positioned(
//               bottom: 0.03.sh,
//               left: 0.10.sw,
//               child: RotatedBox(
//                 quarterTurns: 1 -
//                     myCameraController.controller.value.description
//                         .sensorOrientation ~/
//                         360,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Obx(() => Text(
//                       myCameraController.currentExposureOffset
//                           .toStringAsFixed(1) +
//                           'x',
//                       style: const TextStyle(color: Colors.black),
//                     )),
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//                 bottom: 0.05.sh,
//                 child: RotatedBox(
//                   quarterTurns: 0,
//                   child: Container(
//                     height: 10,
//                     width: 0.7.sw,
//                     child: Obx(() => Slider(
//                       value: myCameraController
//                           .currentExposureOffset.value,
//                       min: myCameraController
//                           .minAvailableExposureOffset.value,
//                       max: myCameraController
//                           .maxAvailableExposureOffset.value,
//                       activeColor: Colors.white,
//                       inactiveColor: Colors.white30,
//                       onChanged: (value) async {
//                         setState(() {});
//                         myCameraController
//                             .currentExposureOffset.value = value;
//                         await myCameraController.controller.value
//                             .setExposureOffset(value);
//                       },
//                     )),
//                   ),
//                 )),
//             isCapturingImages
//                 ? RotatedBox(
//               quarterTurns: 1 -
//                   myCameraController.controller.value.description
//                       .sensorOrientation ~/
//                       360,
//               child: Obx(()=>Text(
//                 '${myCameraController.totalImagesCaptured.value}',
//                 style: Theme.of(context)
//                     .textTheme
//                     .headline1
//                     ?.copyWith(
//                     color: Colors.white.withOpacity(0.5),
//                     fontSize: 80.sp),
//               )),
//             )
//                 : const SizedBox.shrink(),
//             Positioned(
//               left: 0.05.sh,
//               child: RotatedBox(
//                 quarterTurns: 1 -
//                     myCameraController.controller.value.description
//                         .sensorOrientation ~/
//                         360,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         if (isCapturingImages) {
//                           // stopCapturingImages();
//                           return;
//                         }
//                         // myCameraController.controller.value.dispose();
//                         if(Platform.isAndroid){
//                           navigationController.getOff(qaRootScreen);
//                         }else{
//                           navigationController
//                               .navigateToNamed(qaRootScreen);
//                         }
//                       },
//                       child: CircleAvatar(
//                         maxRadius: 20.r,
//                         backgroundColor: isCapturingImages
//                             ? Colors.grey
//                             : primaryColor,
//                         foregroundColor: primaryColor,
//                         child: Text(
//                           "Export",
//                           style: Theme.of(context)
//                               .textTheme
//                               .headline2
//                               ?.copyWith(
//                               color: Colors.white, fontSize: 8.sp),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 0.02.sh,
//                     ),
//                     InkWell(
//                       onTap: isCapturingImages
//                           ? stopCapturingImages
//                           : startCapturingImages,
//                       child: CircleAvatar(
//                         maxRadius: 28.r,
//                         backgroundColor:
//                         isCapturingImages ? red : primaryColor,
//                         foregroundColor: primaryColor,
//                         child: Text(
//                           isCapturingImages ? "Stop" : "Start",
//                           style: Theme.of(context)
//                               .textTheme
//                               .headline2
//                               ?.copyWith(
//                               color: Colors.white, fontSize: 12.sp),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 0.02.sh,
//                     ),
//                     // CircleAvatar(
//                     //   backgroundColor: Colors.black87,
//                     //   maxRadius: 20.r,
//                     //   child: IconButton(
//                     //     icon: Icon(
//                     //       Icons.flip_camera_android,
//                     //       size: 18.sp,
//                     //       color: Colors.white70,
//                     //     ),
//                     //     onPressed: () {
//                     //
//                     //       if (myCameraController
//                     //           .controller.value.description ==
//                     //           myCameraController.cameras[0]) {
//                     //         if (myCameraController.cameras.length > 0) {
//                     //           onNewCameraSelected(
//                     //               myCameraController.cameras[1]);
//                     //
//                     //         }
//                     //       } else if (myCameraController
//                     //           .controller.value.description ==
//                     //           myCameraController.cameras[1]) {
//                     //         onNewCameraSelected(
//                     //             myCameraController.cameras[0]);
//                     //
//                     //       }
//                     //     },
//                     //   ),
//                     // )
//                   ],
//                 ),
//               ),
//             ),
//             GestureDetector(
//                 behavior: HitTestBehavior.translucent,
//                 onScaleStart: (details) {
//                   _baseScale = _currentScale;
//                 },
//                 onScaleUpdate: (details) {
//                   _currentScale = (_baseScale * details.scale)
//                       .clamp(myCameraController.minAvailableZoom.value,
//                       myCameraController.maxAvailableZoom.value)
//                       .toDouble();
//                   setState(() {
//                     myCameraController.controller.value
//                         .setZoomLevel(_currentScale);
//                   });
//                 })
//           ],
//         ),
//       ),
//     ),
//   ));
// }
