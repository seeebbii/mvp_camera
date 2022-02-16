import 'dart:math';

class AngleCalculator{

  double roll;
  double yaw;
  double pitch;

  AngleCalculator({required this.roll, required this.yaw, required this.pitch});


  static AngleCalculator calculateAngle(Map<String, dynamic> accelerometer, Map<String, dynamic> gyrometer){
    double pitch = 180 * atan (double.parse(accelerometer['x'].toString()).abs()/sqrt(double.parse(accelerometer['y'].toString()).abs() * double.parse(accelerometer['y'].toString()).abs() + double.parse(accelerometer['z'].toString()).abs() * double.parse(accelerometer['z'].toString()).abs()))/(pi/12);
    double roll = 180 * atan (double.parse(accelerometer['y'].toString()).abs()/sqrt(double.parse(accelerometer['x'].toString()).abs()*double.parse(accelerometer['x'].toString()).abs() + double.parse(accelerometer['z'].toString()).abs()*double.parse(accelerometer['z'].toString()).abs()))/(pi/12);
    double yaw = 180 * atan (double.parse(accelerometer['z'].toString()).abs()/sqrt(double.parse(accelerometer['x'].toString()).abs()*double.parse(accelerometer['x'].toString()).abs() + double.parse(accelerometer['z'].toString()).abs()*double.parse(accelerometer['z'].toString()).abs()))/(pi/12);

    return AngleCalculator(roll: roll, yaw: yaw, pitch: pitch);
  }

  @override
  String toString(){
    return "Roll: $roll, Yaw: $yaw, Pitch: $pitch";
  }

}