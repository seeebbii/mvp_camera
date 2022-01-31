import 'dart:io';

import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorController extends GetxController {
  late Rx<AccelerometerEvent> accelerometerEvent =
      AccelerometerEvent(0, 0, 0).obs;
  late Rx<UserAccelerometerEvent> userAccelerometerEvent =
      UserAccelerometerEvent(0, 0, 0).obs;
  late Rx<GyroscopeEvent> gyroscopeEvent = GyroscopeEvent(0, 0, 0).obs;
  late Rx<MagnetometerEvent> magnetometerEvent = MagnetometerEvent(0, 0, 0).obs;

  // CSV FILE DATA
  Directory? extDir;
  List<List<dynamic>> rows = [];
  List<dynamic> row = [];

  void initCsvFile() {
    row.add("Date");
    row.add("Time");
    row.add("Gyro-Sensor");
    row.add("Accelerometer");
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
    rows.add(row);
  }

  void saveCsvFile() async {
    // CONVERTING LIST TO CSV ROWS
    String csv = const ListToCsvConverter().convert(rows);
    String currProject = myCameraController.projectNameController.value.text;

    Directory csvDirectory = await Directory(extDir!.path + "/csv/$currProject")
        .create(recursive: true);
    // SAVING CSV FILE
    File file = File(
        csvDirectory.path + "/${DateTime.now().toUtc().toIso8601String()}.csv");
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
    accelerometerEvents.listen((AccelerometerEvent event) {
      accelerometerEvent.value = event;
    });

    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      userAccelerometerEvent.value = event;
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      gyroscopeEvent.value = event;
      // print(event);
    });

    magnetometerEvents.listen((MagnetometerEvent event) {
      magnetometerEvent.value = event;
    });
  }
}
