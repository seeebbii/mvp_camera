// ignore_for_file: unnecessary_new

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
  final intervalController = TextEditingController();

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
            Container(
                height: 0.1.sh,
                width: 0.5.sw,
                child: Image.asset(ImagePaths.appLogo)),
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
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.copyWith(color: whiteColor),
                  controller: intervalController,
                  decoration: InputDecoration(
                    suffixIcon: PopupMenuButton<String>(
                      icon: const Icon(Icons.arrow_drop_down),
                      onSelected: (String value) {
                        if (value == 'Custom') {
                          intervalController.text = '';
                        } else {
                          intervalController.text = value[0];
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return intervals
                            .map<PopupMenuItem<String>>((String value) {
                          return new PopupMenuItem(
                              child: new Text(value), value: value);
                        }).toList();
                      },
                    ),
                  ),
                )),
            SizedBox(
              height: 0.03.sh,
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.sp),
                child: CustomButton(
                    buttonText: "Start",
                    onPressed: () {
                      navigationController.navigateToNamed(cameraScreen);
                    })),
          ],
        ),
      ),
    );
  }
}
