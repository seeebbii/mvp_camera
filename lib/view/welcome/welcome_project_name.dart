import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:mvp_camera/app/router/router_generator.dart';
import 'package:mvp_camera/app/utils/colors.dart';
import 'package:mvp_camera/controller/my_camera_controller.dart';
import 'package:mvp_camera/view/components/custom_button.dart';
import 'package:mvp_camera/view/components/custom_textfield.dart';
import 'package:permission_handler/permission_handler.dart';

class WelcomeProjectName extends StatefulWidget {
  const WelcomeProjectName({Key? key}) : super(key: key);

  @override
  State<WelcomeProjectName> createState() => _WelcomeProjectNameState();
}

class _WelcomeProjectNameState extends State<WelcomeProjectName>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final localNameController = TextEditingController();

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      if (await Permission.photos.isDenied ||
          await Permission.storage.isDenied ||
          await Permission.accessMediaLocation.isDenied) {
        Permission.photos.request().then((value) {
          Permission.storage.request().then((value) {
            Permission.accessMediaLocation
                .request()
                .then((value) => debugPrint(value.toString()));
          });
        });
      }
      debugPrint("HEY PROJECT: " +
          myCameraController.projectNameController.value.text);
      navigationController.navigateToNamed(selectIntervalScreen);
    }
  }

  @override
  void initState() {
    Get.put(MyCameraController());
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      callAppLockDialog();
    });
  }

  void callAppLockDialog() {
    showDialog(
        context: context, builder: (_) => WillPopScope(onWillPop: () async => false,
        child: MyDialog()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 0.2.sh,
              ),
              Center(
                  child: Text(
                "Welcome",
                style: Theme.of(context)
                    .textTheme
                    .headline1
                    ?.copyWith(color: Colors.white),
              )),
              Center(
                  child: Text(
                "Create Data Capture Folder",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(color: bodyTextColor),
              )),
              SizedBox(
                height: 0.2.sh,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.sp),
                child: Obx(() => CustomTextField(
                    controller: myCameraController.projectNameController.value,
                    containerBoxColor: Colors.grey,
                    borderRadius: 12.r,
                    obSecureText: false,
                    validator: (str) {
                      if (str == '' || str == null) {
                        return "Required*";
                      }
                      return null;
                    },
                    action: TextInputAction.done,
                    keyType: TextInputType.text,
                    hintText: "Enter the Project Name",
                    suffixIcon: const SizedBox.shrink())),
              ),
              SizedBox(
                height: 0.03.sh,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.sp),
                child: CustomButton(buttonText: "Next", onPressed: _trySubmit),
              ),
              SizedBox(
                height: 0.015.sh,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.sp),
                child: CustomButton(
                    buttonText: "Exit App", onPressed: () => exit(0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyDialog extends StatelessWidget {
  MyDialog({Key? key}) : super(key: key);
  final accentColor = backgroundColor;

  final passCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3,
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: EdgeInsets.all(20.sm),
              child: CustomTextField(
                  controller: passCodeController,
                  containerBoxColor: Colors.grey,
                  borderRadius: 12.r,
                  obSecureText: true,
                  validator: (str) {
                    if (str == '' || str == null) {
                      return "Required*";
                    }
                    return null;
                  },
                  action: TextInputAction.done,
                  keyType: TextInputType.text,
                  hintText: "Enter your passcode?",
                  suffixIcon: const SizedBox.shrink()),
            ),
            SizedBox(
              width: 0.3.sw,
              child: CustomButton(
                  buttonText: "Verify",
                  onPressed: () {
                    if (passCodeController.text.trim() == "metaspatial" ||
                        passCodeController.text.trim() == "Metaspatial" || passCodeController.text.trim() == "admin") {
                      navigationController.goBack();
                    }else{
                      passCodeController.clear();
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
