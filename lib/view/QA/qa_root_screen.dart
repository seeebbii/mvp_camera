import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvp_camera/app/router/router_generator.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/constant/controllers.dart';
import '../../app/utils/angle_calculator.dart';
import '../../app/utils/colors.dart';
import '../../app/utils/dialogs.dart';

class QaRootScreen extends StatefulWidget {
  const QaRootScreen({Key? key}) : super(key: key);

  @override
  _QaRootScreenState createState() => _QaRootScreenState();
}

class _QaRootScreenState extends State<QaRootScreen> {
  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
    //     overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    // FETCH TOTAL NUMBER OF FILES IN CURRENT DIRECTORY
    WidgetsBinding.instance?.addPostFrameCallback((duration) {
      Dialogs.showLoadingDialog(context);
      Future.delayed(
          const Duration(
            seconds: 3,
          ), () {
        fetchFilesController.checkDirectoriesAndFetch(
            myCameraController.projectNameController.value.text);
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
    //     overlays: []);

    if (Platform.isAndroid) {
      myCameraController.getAvailableCameras();
    }

    mapController.controller.dispose();
    fetchFilesController.filesInCurrentProject.clear();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (mounted) {
      debugPrint("Mounted");
    } else {
      debugPrint("Not Mounted");
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor.withOpacity(1),
      body: buildStackedContainer(),
    );
  }

  Widget buildStackedContainer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 0.65.sh,
                child: Obx(() => GoogleMap(
                      mapType: MapType.normal,
                      markers: mapController.imageMarkers.value,
                      zoomControlsEnabled: false,
                      initialCameraPosition:
                          mapController.currentLocationCameraPosition.value,
                      onMapCreated: mapController.onMapCreated,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                    )),
              ),
              Positioned(
                top: 3.sp,
                left: 3.sp,
                child: ElevatedButton(
                  onPressed: () {
                    if (Platform.isAndroid) {
                      if (myCameraController
                          .controller.value.value.isInitialized) {
                        myCameraController.getAvailableCameras().then((value) {
                          navigationController.getOff(cameraScreen);
                        });
                      }else{
                        print("CAMERA IS: ${myCameraController.controller.value.value.isInitialized}");
                      }
                    } else {
                      navigationController.goBack();
                    }
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
                        horizontal: 10, vertical: 15),
                    primary: primaryColor,
                    shape: RoundedRectangleBorder(
                        //to set border radius to button
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(1),
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(15.sm),
              //   topRight: Radius.circular(15.sm),
              // )
            ),
            child: Column(
              children: [
                _buildDropDown(),
                SizedBox(
                  height: 0.01.sh.sm,
                ),
                _buildTotalFiles(),
                // SizedBox(
                //   height: 0.01.sh.sm,
                // ),
                // _buildTotalGyro(),
                SizedBox(
                  height: 0.05.sh.sm,
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalFiles() {
    return Padding(
      padding: EdgeInsets.all(10.0.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Number of Photos: ",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.copyWith(color: Colors.white, fontSize: 14.sp.sm),
            ),
          ),
          Expanded(
              child: Obx(
            () => Text(
              "${Platform.isAndroid ? fetchFilesController.filesInCurrentProject.length : fetchFilesController.filesInCurrentProjectForIos.length}",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.copyWith(color: Colors.white, fontSize: 14.sp.sm),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDropDown() {
    return Padding(
      padding: EdgeInsets.all(10.0.sm),
      child: Row(
        children: [
          Expanded(
              child: Text(
            "Current Project Directory: ",
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(color: Colors.white, fontSize: 14.sp.sm),
          )),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: backgroundColor,
                  border: Border.all(color: primaryColor)),
              child: TextFormField(
                validator: (str) {
                  return null;
                },
                keyboardType: TextInputType.none,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(color: whiteColor),
                controller: myCameraController.projectNameController.value,
                decoration: InputDecoration(
                  hintText: "Current Project",
                  border: InputBorder.none,
                  focusColor: primaryColor,
                  suffixIcon: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: primaryColor,
                    ),
                    color: backgroundColor,
                    onSelected: (String value) {
                      if (value ==
                          myCameraController.projectNameController.value.text) {
                        return;
                      }
                      Dialogs.showLoadingDialog(context);

                      // REMOVING THE DATA OF PREVIOUS FILE CAPTURED
                      myCameraController.tempAbsoluteOrientation.value =
                          AngleCalculator(roll: 0, yaw: 0, pitch: 0);

                      WidgetsBinding.instance?.addPostFrameCallback((duration) {
                        myCameraController.projectNameController.value.text =
                            value;
                        fetchFilesController.checkDirectoriesAndFetch(
                            myCameraController
                                .projectNameController.value.text);
                        myCameraController.changeProjectDirectory(
                            myCameraController
                                .projectNameController.value.text);
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return fetchFilesController.listOfAvailableProject
                          .map<PopupMenuItem<String>>((String value) {
                        return PopupMenuItem(
                          child: Text(
                            value,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.copyWith(color: Colors.white),
                          ),
                          value: value,
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // ElevatedButton(
        //   onPressed: () {
        //     List<String> filesToBeShared = <String>[];
        //     if (Platform.isIOS) {
        //       filesToBeShared = fetchFilesController.filesInCurrentProjectForIos
        //           .map((element) => element.fileData.path)
        //           .toList();
        //     }
        //     if (Platform.isAndroid) {
        //       filesToBeShared = fetchFilesController.filesInCurrentProject
        //           .map((element) => element.imageFile.path)
        //           .toList();
        //     }
        //     if (filesToBeShared.isNotEmpty) {
        //       Share.shareFiles(filesToBeShared);
        //     }
        //   },
        //   child: Text(
        //     "Save",
        //     style: Theme.of(context)
        //         .textTheme
        //         .bodyText1
        //         ?.copyWith(color: Colors.white, fontSize: 13.sp),
        //   ),
        //   style: ElevatedButton.styleFrom(
        //     onPrimary: Colors.white,
        //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        //     primary: Colors.green,
        //     shape: RoundedRectangleBorder(
        //         //to set border radius to button
        //         borderRadius: BorderRadius.circular(12)),
        //   ),
        // ),
        ElevatedButton(
          onPressed: _buildConfirmationDialog,
          child: Text(
            "Delete",
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(color: Colors.white, fontSize: 13.sp),
          ),
          style: ElevatedButton.styleFrom(
            onPrimary: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            primary: Colors.red,
            shape: RoundedRectangleBorder(
                //to set border radius to button
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _buildConfirmationDialog() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => const ConfirmationDialog());
  }

//
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({Key? key}) : super(key: key);
  final accentColor = backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                  offset: const Offset(12, 26),
                  blurRadius: 50,
                  spreadRadius: 0,
                  color: Colors.grey.withOpacity(.1)),
            ]),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.sp, vertical: 15.sp),
              child: ListTile(
                title: Text(
                  "Are you sure you want to delete this directory?",
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      ?.copyWith(fontSize: 16.sp),
                ),
              ),
            ),
            SizedBox(
              height: 0.01.sh,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                    onPressed: () => navigationController.goBack(),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    // POPPING THE CURRENT DIALOG
                    navigationController.goBack();
                    // DELETING SELECTED DIRECTORY
                    myCameraController.projectDirectory
                        .deleteSync(recursive: true);
                    // DELETING NAME OF PROJECT FROM OUR LIST OF AVAILABLE PROJECTS
                    fetchFilesController.listOfAvailableProject.removeWhere(
                        (projectName) =>
                            projectName ==
                            myCameraController
                                .projectNameController.value.text);
                    // SWITCHING PROJECT TO ZERO th INDEX OF AVAILABLE PROJECTS
                    if (fetchFilesController
                        .listOfAvailableProject.isNotEmpty) {
                      Dialogs.showLoadingDialog(context);
                      WidgetsBinding.instance?.addPostFrameCallback((duration) {
                        myCameraController.projectNameController.value.text =
                            fetchFilesController.listOfAvailableProject[0];
                        fetchFilesController.checkDirectoriesAndFetch(
                            myCameraController
                                .projectNameController.value.text);
                        myCameraController.changeProjectDirectory(
                            myCameraController
                                .projectNameController.value.text);
                      });
                    }
                  },
                  child: const Text("Confirm"),
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    primary: Colors.red,
                    shape: RoundedRectangleBorder(
                        //to set border radius to button
                        borderRadius: BorderRadius.circular(12)),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
