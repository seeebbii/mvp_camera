import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mvp_camera/app/utils/colors.dart';

import '../../app/constant/controllers.dart';
import '../../app/utils/angle_calculator.dart';
import '../../controller/sensor_controller.dart';

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
    Get.lazyPut(() => SensorController());
    final sensorController = Get.find<SensorController>();

    Map<String, dynamic> gyroScopeInfo = {
      "x": sensorController.gyroscopeEvent.value.z.toStringAsFixed(3),
      "y": sensorController.gyroscopeEvent.value.y.toStringAsFixed(3),
      "z": sensorController.gyroscopeEvent.value.z.toStringAsFixed(3),
    };

    Map<String, dynamic> accelerometerInfo = {
      "x": sensorController.accelerometerEvent.value.z.toStringAsFixed(3),
      "y": sensorController.accelerometerEvent.value.y.toStringAsFixed(3),
      "z": sensorController.accelerometerEvent.value.z.toStringAsFixed(3),
    };


    AngleCalculator calculations = AngleCalculator.calculateAngle(accelerometerInfo, gyroScopeInfo,);


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
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontWeight: FontWeight.normal),
            ),
            trailing: Obx(() => CupertinoSwitch(
                  onChanged: (bool value) {
                    myCameraController.captureBeep.value = value;
                  },
                  value: myCameraController.captureBeep.value,
                )),
          ),
          ListTile(
            title: Text(
              'Gyroscope Events',
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontWeight: FontWeight.normal),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text("X (Roll): ${sensorController.gyroscopeEvent.value.x.toStringAsFixed(2)}",style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),)),
                Obx(() => Text("Y (Pitch): ${sensorController.gyroscopeEvent.value.y.toStringAsFixed(2)}",style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),)),
                Obx(() => Text("Z (Yaw): ${sensorController.gyroscopeEvent.value.z.toStringAsFixed(2)}",style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),)),
              ],
            ),
          ),
          ListTile(
            title: Text(
              'Accelerometer Events',
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontWeight: FontWeight.normal),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text("X (Roll): ${sensorController.accelerometerEvent.value.x.toStringAsFixed(2)}",style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),)),
                Obx(() => Text("Y (Pitch): ${sensorController.accelerometerEvent.value.y.toStringAsFixed(2)}",style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),)),
                Obx(() => Text("Z (Yaw): ${sensorController.accelerometerEvent.value.z.toStringAsFixed(2)}",style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
