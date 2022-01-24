import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
class SensorController extends GetxController {

  static SensorController instance = Get.find();

  late Rx<AccelerometerEvent> accelerometerEvent = AccelerometerEvent(0, 0, 0).obs;
  late Rx<UserAccelerometerEvent> userAccelerometerEvent = UserAccelerometerEvent(0, 0, 0).obs;
  late Rx<GyroscopeEvent> gyroscopeEvent = GyroscopeEvent(0, 0, 0).obs;
  late Rx<MagnetometerEvent> magnetometerEvent =MagnetometerEvent(0, 0, 0).obs;


  @override
  void onInit() {
    super.onInit();
    listenToEvents();
  }

  void listenToEvents(){
    accelerometerEvents.listen((AccelerometerEvent event) {
      accelerometerEvent.value = event;
    });

    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      userAccelerometerEvent.value = event;
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      gyroscopeEvent.value = event;
      print(event);
    });

    magnetometerEvents.listen((MagnetometerEvent event) {
      magnetometerEvent.value = event;
    });
  }
}