// ignore_for_file: unnecessary_new

import 'dart:io' as io;
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:mvp_camera/app/constant/image_paths.dart';
import 'package:mvp_camera/app/router/router_generator.dart';
import 'package:mvp_camera/app/utils/colors.dart';
import 'package:mvp_camera/view/components/custom_button.dart';
import 'package:mvp_camera/view/components/custom_textfield.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SelectIntervalScreen extends StatefulWidget {
  const SelectIntervalScreen({Key? key}) : super(key: key);

  @override
  _SelectIntervalScreenState createState() => _SelectIntervalScreenState();
}

class _SelectIntervalScreenState extends State<SelectIntervalScreen> {
  final formKey = GlobalKey<FormState>();

  void _trySubmit() async {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      var dirPath = await getExternalStorageDirectory();
      debugPrint(myCameraController.projectNameController.value.text);
      debugPrint(myCameraController.intervalController.value.text);
      final myImgDir = await new io.Directory(
              '${dirPath!.path}/${myCameraController.projectNameController.value.text}')
          .create();
      myCameraController.projectDirectory = myImgDir;

      getLocationPermission();

      // var projectNameDirectory = await new io.Directory(
      //         '${dirPath?.path}/${myCameraController.projectNameController.value.text}')
      //     .create(recursive: true);
      //
      // final myImagePath = '${projectNameDirectory.path}/MyImages' ;
      // final myImgDir = await new io.Directory(myImagePath).create(recursive: true);
      //
      // print(projectNameDirectory);

      navigationController.navigateToNamed(cameraScreen);
    }
  }

  final List<String> intervals = const [
    "1 sec",
    "2 sec",
    "3 sec",
    "4 sec",
    "Custom",
  ];

  void getLocationPermission() async {
    if (await Permission.locationWhenInUse.isDenied) {
      Permission.locationWhenInUse.request().then((value) async {
        if (value.isGranted) {
          if (await Permission.locationAlways.isDenied) {
            Permission.locationAlways
                .request()
                .then((value) => debugPrint(value.toString()));
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  bool _isNumeric(String? result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            navigationController.goBack();
          },
          icon: Icon(
            Icons.chevron_left,
            color: primaryColor,
            size: 25.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              SizedBox(
                height: 0.1.sh,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(ImagePaths.boxLogo),
                  Image.asset(ImagePaths.intervalLogo),
                ],
              ),
              SizedBox(
                height: 0.03.sh,
              ),
              Center(
                  child: Text(
                "Please Set the Interval in Seconds",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(color: whiteColor),
              )),
              SizedBox(
                height: 0.1.sh,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.sp),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: primaryColor)),
                    child: TextFormField(
                      validator: (str) {
                        if (_isNumeric(str) == false) {
                          return "Required*";
                        } else if (int.parse(str ?? '0') <= 0) {
                          return "Invalid";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(color: whiteColor),
                      controller: myCameraController.intervalController.value,
                      decoration: InputDecoration(
                        hintText: "Set the Interval",
                        border: InputBorder.none,
                        suffixText: " Seconds",
                        focusColor: primaryColor,
                        suffixIcon: PopupMenuButton<String>(
                          icon: const Icon(Icons.arrow_drop_down),
                          color: backgroundColor,
                          onSelected: (String value) {
                            if (value == 'Custom') {
                              myCameraController.intervalController.value.text =
                                  '';
                            } else {
                              myCameraController.intervalController.value.text =
                                  value[0];
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return intervals
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
                  )),
              SizedBox(
                height: 0.03.sh,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.sp),
                  child:
                      CustomButton(buttonText: "Start", onPressed: _trySubmit)),
            ],
          ),
        ),
      ),
    );
  }
}
