import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:mvp_camera/app/constant/image_paths.dart';
import 'package:mvp_camera/app/router/router_generator.dart';
import 'package:mvp_camera/app/utils/colors.dart';
import 'package:mvp_camera/view/components/custom_button.dart';
import 'package:mvp_camera/view/components/custom_textfield.dart';

class SelectIntervalScreen extends StatefulWidget {
  const SelectIntervalScreen({Key? key}) : super(key: key);

  @override
  _SelectIntervalScreenState createState() => _SelectIntervalScreenState();
}

class _SelectIntervalScreenState extends State<SelectIntervalScreen> {
  final formKey = GlobalKey<FormState>();
  String? _currentSelectedValue;

  final List<String> intervals = const [
    "1 sec",
    "2 sec",
    "3 sec",
    "4 sec",
    "Custom",
  ];

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
        child: Column(
          children: [
            SizedBox(
              height: 0.1.sh,
            ),
            Image.asset(ImagePaths.appLogo),
            SizedBox(
              height: 0.03.sh,
            ),
            Center(
                child: Text(
              "Please Set the Interval",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.copyWith(color: bodyTextColor),
            )),
            SizedBox(
              height: 0.1.sh,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.sp),
              child: const Text("DROP DOWN HERE"),
            ),
            SizedBox(
              height: 0.03.sh,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.sp),
              child: CustomButton(
                  buttonText: "Start",
                  onPressed: () {
                    navigationController.navigateToNamed(cameraScreen);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
