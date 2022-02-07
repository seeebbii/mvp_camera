import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mvp_camera/app/utils/colors.dart';

import '../../app/constant/controllers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: []);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 18.sp,
          ),
          onPressed: () => navigationController.goBack(),
        ),
        centerTitle: true,
        title: Text(
          "Settings",
          style: Theme.of(context)
              .textTheme
              .headline1
              ?.copyWith(color: Colors.white, fontSize: 16.sp),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              'Capture Beep',
              style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.normal),
            ),
            trailing: Obx(
                ()=> CupertinoSwitch(
                  onChanged: (bool value) {
                    myCameraController.captureBeep.value = value;
                  },
                  value: myCameraController.captureBeep.value,
                )
            ),
          )
        ],
      ),
    );
  }
}
