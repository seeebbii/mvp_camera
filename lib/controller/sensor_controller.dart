import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart' as sensorPlus;

class SensorController extends GetxController {

  // OLD PACKAGE VARIABLES
  late Rx<sensorPlus.AccelerometerEvent> accelerometerEvent =
      sensorPlus.AccelerometerEvent(0, 0, 0).obs;
  late Rx<sensorPlus.UserAccelerometerEvent> userAccelerometerEvent =
      sensorPlus.UserAccelerometerEvent(0, 0, 0).obs;
  late Rx<sensorPlus.GyroscopeEvent> gyroscopeEvent =
      sensorPlus.GyroscopeEvent(0, 0, 0).obs;
  late Rx<sensorPlus.MagnetometerEvent> magnetometerEvent =
      sensorPlus.MagnetometerEvent(0, 0, 0).obs;

  // NEW PACKAGE VARIABLES
  late Rx<OrientationEvent> orientationEvent = OrientationEvent(0, 0, 0).obs;
  late Rx<AbsoluteOrientationEvent> absoluteOrientationEvent = AbsoluteOrientationEvent(0, 0, 0).obs;
  // CSV FILE DATA
  Directory? extDir;
  List<List<dynamic>> rows = [];
  List<dynamic> row = [];

  void initCsvFile() {
    row.add("Date");
    row.add("Time");
    row.add("Gyro-Sensor");
    row.add("Accelerometer");
    row.add("Absolute Orientation");
    rows.add(row);
  }

  void createCsvFile() async {
    // ADDING ROWS TO CSV FILE UNTIL THE CAMERA IS STOPPED TAKING PICTURES
    List<dynamic> row = [];
    row.add(DateFormat('MM/dd/yyyy').format(DateTime.now()));
    row.add(DateFormat('hh:mm:ss').format(DateTime.now()));
    row.add(
        "X: ${gyroscopeEvent.value.x}, Y: ${gyroscopeEvent.value.y}, Z: ${gyroscopeEvent.value.z}");
    row.add(
        "X: ${accelerometerEvent.value.x}, Y: ${accelerometerEvent.value.y}, Z: ${accelerometerEvent.value.z}");
    row.add(
        "Roll: ${absoluteOrientationEvent.value.roll}, Pitch: ${absoluteOrientationEvent.value.pitch}, Yaw: ${absoluteOrientationEvent.value.yaw}");
    rows.add(row);
  }

  void saveCsvFile() async {
    // CONVERTING LIST TO CSV ROWS
    String csv = const ListToCsvConverter().convert(rows);
    final String currProject =
        myCameraController.projectNameController.value.text;

    Directory csvDirectory = await Directory(extDir!.path + "/csv/$currProject")
        .create(recursive: true);
    // SAVING CSV FILE
    // var rng = Random();
    File file = File(csvDirectory.path + "/${DateFormat('MM:dd:yyyy').format(DateTime.now()).toString()}-${DateFormat('hh:mm:ss').format(DateTime.now()).toString()}.csv");
    file.writeAsStringSync(csv, mode: FileMode.append);

    // CLEARING DATA AFTER SAVING
    row.clear();
    rows.clear();
  }

  void initDirectory() async {
    // CREATING A NEWS DIRECTORY UNDER MY PROJECT PATH
    if (Platform.isAndroid) {
      extDir = await getExternalStorageDirectory();
    }
    if (Platform.isIOS) {
      extDir = await getApplicationDocumentsDirectory();
    }
  }

  @override
  void onInit() {
    super.onInit();
    listenToEvents();
    initDirectory();
  }

  void listenToEvents() {

    // NEW PACKAGE FOR GETTING SENSORS INFO

    sensorPlus.accelerometerEvents.listen((sensorPlus.AccelerometerEvent event) {
      accelerometerEvent.value = event;
    });

    sensorPlus.userAccelerometerEvents.listen((sensorPlus.UserAccelerometerEvent event) {
      userAccelerometerEvent.value = event;
    });

    sensorPlus.gyroscopeEvents.listen((sensorPlus.GyroscopeEvent event) {
      gyroscopeEvent.value = event;
      // print(event);
    });

    sensorPlus.magnetometerEvents.listen((sensorPlus.MagnetometerEvent event) {
      magnetometerEvent.value = event;
    });

    // OLD PACKAGE TO GET ROLL < YAW < PITCH

    motionSensors.isOrientationAvailable().then((available) {
      if (available) {
        motionSensors.orientation.listen((OrientationEvent event) {
          orientationEvent.value = event;
        });
      }
    });

    motionSensors.absoluteOrientation.listen((AbsoluteOrientationEvent event) {
      absoluteOrientationEvent.value = event;
    });


  }
}
