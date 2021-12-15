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
      print("HEY PROJECT: " +
          myCameraController.projectNameController.value.text);
      navigationController.navigateToNamed(selectIntervalScreen);
    }
  }

  @override
  void initState() {
    Get.put(MyCameraController());
    // WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint(state.toString());
    if (state == AppLifecycleState.inactive && myCameraController.controller.value.value.isInitialized) {
      myCameraController.controller.value.dispose();
    }
    if (state == AppLifecycleState.resumed) {
      myCameraController.getAvailableCameras();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Please Enter the information!",
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
            ],
          ),
        ),
      ),
    );
  }
}
