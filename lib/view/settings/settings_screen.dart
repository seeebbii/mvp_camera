import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mvp_camera/app/utils/colors.dart';
import 'package:mvp_camera/app/utils/shared_pref.dart';
import 'package:wakelock/wakelock.dart';

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
    // Get.lazyPut(() => SensorController());
    // final sensorController = Get.find<SensorController>();

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
                    SharedPref().pref.setBool('beep', value);
                  },
                  value: myCameraController.captureBeep.value,
                )),
          ),
          ListTile(
            title: Text(
              'Calculate Angle',
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontWeight: FontWeight.normal),
            ),
            trailing: Obx(() => CupertinoSwitch(
                  onChanged: (bool value) {
                    myCameraController.angleCalculator.value = value;
                    SharedPref().pref.setBool('calculate', value);
                  },
                  value: myCameraController.angleCalculator.value,
                )),
          ),
          ListTile(
            title: Text(
              'Auto Lock',
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontWeight: FontWeight.normal),
            ),
            trailing: Obx(() => CupertinoSwitch(
                  onChanged: (bool value) {
                    myCameraController.wakeLock.value = value;
                    SharedPref().pref.setBool('wakelock', value);
                    if (value == false) {
                      Wakelock.enable();
                    } else {
                      Wakelock.disable();
                    }
                  },
                  value: myCameraController.wakeLock.value,
                )),
          ),
          ListTile(
            title: Text(
              'Auto dim brightness',
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontWeight: FontWeight.normal),
            ),
            trailing: Obx(() => CupertinoSwitch(
                  onChanged: (bool value) {
                    myCameraController.autoDimmer.value = value;
                    SharedPref().pref.setBool('dimmer', value);
                  },
                  value: myCameraController.autoDimmer.value,
                )),
          ),
          ListTile(
            title: Text(
              'Camera Quality',
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontWeight: FontWeight.normal),
            ),
            trailing: DropdownButton<ResolutionPreset>(
              dropdownColor: Colors.black87,
              underline: Container(),
              value: myCameraController.currentResolutionPreset.value,
              items: [
                for (ResolutionPreset preset
                in myCameraController.resolutionPresets)
                  DropdownMenuItem(
                    child: Text(
                      preset
                          .toString()
                          .split('.')[1]
                          .toUpperCase(),
                      style:
                      const TextStyle(color: Colors.white),
                    ),
                    value: preset,
                  )
              ],
              onChanged: (value) {
                setState(() {
                  myCameraController.currentResolutionPreset.value = value!;
                });
                myCameraController.changeCamera(myCameraController.controller.value.description);
              },
              hint: Text("Select item"),
            ),
          ),
          ListTile(
            title: Text(
              'Available Cameras',
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontWeight: FontWeight.normal),
            ),
            subtitle: Container(
              margin: EdgeInsets.symmetric(vertical: 0.02.sh),
              height: 0.1.sh,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: myCameraController.cameras.length,
                  itemBuilder: (ctx, index) {
                    print(myCameraController.cameras[index]);
                    return myCameraController.cameras[index].lensDirection != CameraLensDirection.front ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.sp),
                      child: OutlinedButton(
                        onPressed: () {
                          myCameraController.changeCamera(myCameraController.cameras[index]);
                        },
                        child: Text(
                          'Back Camera ${index+1}',
                          style: Theme.of(context)
                              .textTheme
                              .headline3
                              ?.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 13.sp),
                        ),
                      ),
                    ) : const SizedBox.shrink();
                  }),
            ),
          ),
          // ListTile(
          //   title: Text(
          //     'Show dev logs',
          //     style: Theme.of(context)
          //         .textTheme
          //         .headline3
          //         ?.copyWith(fontWeight: FontWeight.normal),
          //   ),
          //   trailing: Obx(() => CupertinoSwitch(
          //         onChanged: (bool value) {
          //           myCameraController.devLogs.value = value;
          //         },
          //         value: myCameraController.devLogs.value,
          //       )),
          // ),
          // Obx(() => myCameraController.devLogs.value
          //     ? ListTile(
          //         title: Text(
          //           'Gyroscope Events',
          //           style: Theme.of(context)
          //               .textTheme
          //               .headline3
          //               ?.copyWith(fontWeight: FontWeight.normal),
          //         ),
          //         subtitle: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Obx(() => Text(
          //                   "X: ${sensorController.gyroscopeEvent.value.x.toStringAsFixed(2)}",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyText1
          //                       ?.copyWith(color: Colors.white),
          //                 )),
          //             Obx(() => Text(
          //                   "Y: ${sensorController.gyroscopeEvent.value.y.toStringAsFixed(2)}",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyText1
          //                       ?.copyWith(color: Colors.white),
          //                 )),
          //             Obx(() => Text(
          //                   "Z: ${sensorController.gyroscopeEvent.value.z.toStringAsFixed(2)}",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyText1
          //                       ?.copyWith(color: Colors.white),
          //                 )),
          //           ],
          //         ),
          //       )
          //     : const SizedBox.shrink()),
          // Obx(() => myCameraController.devLogs.value
          //     ? ListTile(
          //         title: Text(
          //           'Accelerometer Events',
          //           style: Theme.of(context)
          //               .textTheme
          //               .headline3
          //               ?.copyWith(fontWeight: FontWeight.normal),
          //         ),
          //         subtitle: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Obx(() => Text(
          //                   "X: ${sensorController.accelerometerEvent.value.x.toStringAsFixed(2)}",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyText1
          //                       ?.copyWith(color: Colors.white),
          //                 )),
          //             Obx(() => Text(
          //                   "Y: ${sensorController.accelerometerEvent.value.y.toStringAsFixed(2)}",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyText1
          //                       ?.copyWith(color: Colors.white),
          //                 )),
          //             Obx(() => Text(
          //                   "Z: ${sensorController.accelerometerEvent.value.z.toStringAsFixed(2)}",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyText1
          //                       ?.copyWith(color: Colors.white),
          //                 )),
          //           ],
          //         ),
          //       )
          //     : const SizedBox.shrink()),
          // Obx(() => myCameraController.devLogs.value
          //     ? ListTile(
          //         title: Text(
          //           'Orientation',
          //           style: Theme.of(context)
          //               .textTheme
          //               .headline3
          //               ?.copyWith(fontWeight: FontWeight.normal),
          //         ),
          //         subtitle: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Obx(() => Text(
          //                   "X (Roll): ${(sensorController.orientationEvent.value.roll* 180 / pi).toStringAsFixed(0)}",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyText1
          //                       ?.copyWith(color: Colors.white),
          //                 )),
          //             Obx(() => Text(
          //                   "Y (Pitch): ${(sensorController.orientationEvent.value.pitch* 180 / pi).toStringAsFixed(0)}",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyText1
          //                       ?.copyWith(color: Colors.white),
          //                 )),
          //             Obx(() => Text(
          //                   "Z (Yaw): ${(sensorController.orientationEvent.value.yaw* 180 / pi).toStringAsFixed(0)}",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyText1
          //                       ?.copyWith(color: Colors.white),
          //                 )),
          //           ],
          //         ),
          //       )
          //     : const SizedBox.shrink()),
          // Obx(() => myCameraController.devLogs.value
          //     ? ListTile(
          //         title: Text(
          //           'Absolute Orientation',
          //           style: Theme.of(context)
          //               .textTheme
          //               .headline3
          //               ?.copyWith(fontWeight: FontWeight.normal),
          //         ),
          //         subtitle: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Obx(() => Text(
          //                   "X (Roll): ${(sensorController.absoluteOrientationEvent.value.roll* 180 /pi).toStringAsFixed(0)}",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyText1
          //                       ?.copyWith(color: Colors.white),
          //                 )),
          //             Obx(() => Text(
          //                   "Y (Pitch): ${(sensorController.absoluteOrientationEvent.value.pitch * 180 / pi).toStringAsFixed(0)}",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyText1
          //                       ?.copyWith(color: Colors.white),
          //                 )),
          //             Obx(() => Text(
          //                   "Z (Yaw): ${(sensorController.absoluteOrientationEvent.value.yaw * 180 / pi).toStringAsFixed(0)}",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyText1
          //                       ?.copyWith(color: Colors.white),
          //                 )),
          //           ],
          //         ),
          //       )
          //     : const SizedBox.shrink()),
          // Obx(() => myCameraController.devLogs.value
          //     ? ListTile(
          //   title: Text(
          //     'Current User Location: ',
          //     style: Theme.of(context)
          //         .textTheme
          //         .headline3
          //         ?.copyWith(fontWeight: FontWeight.normal),
          //   ),
          //   subtitle: Obx(() => Text(
          //     "${mapController.userLocation.value}",
          //     style: Theme.of(context)
          //         .textTheme
          //         .bodyText1
          //         ?.copyWith(color: Colors.white),
          //   )),
          // )
          //     : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
