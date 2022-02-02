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