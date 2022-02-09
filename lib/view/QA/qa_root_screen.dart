import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app/constant/controllers.dart';
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
    myCameraController.getAvailableCameras();

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
      backgroundColor: Colors.white,
      body: buildStackedContainer(),
    );
  }

  Widget buildStackedContainer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
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
        Positioned.fill(top: 0.8.sh.sm, child: modalBottomSheet()),
        Positioned(
          top: 3.sp,
          left: 3.sp,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              primary: primaryColor,
              shape: RoundedRectangleBorder(
                  //to set border radius to button
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget modalBottomSheet() {
    return DraggableScrollableSheet(
        initialChildSize: .3,
        minChildSize: .2,
        maxChildSize: 1,
        builder: (BuildContext _, ScrollController scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Container(
              decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.sm),
                    topRight: Radius.circular(15.sm),
                  )),
              child: Column(
                children: [
                  Center(
                    child: Icon(
                      Icons.maximize,
                      size: 50.sm,
                      color: Colors.white,
                    ),
                  ),
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
                    height: 0.1.sh.sm,
                  ),
                ],
              ),
            ),
          );
        });
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
              "${fetchFilesController.filesInCurrentProject.length}",
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

//
}
