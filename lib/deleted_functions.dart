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