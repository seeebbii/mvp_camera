import 'package:mvp_camera/controller/fetch_files_controller.dart';
import 'package:mvp_camera/controller/map_controller.dart';
import 'package:mvp_camera/controller/my_camera_controller.dart';
import 'package:mvp_camera/controller/navigation_controller.dart';
import '../../controller/sensor_controller.dart';

MyCameraController myCameraController = MyCameraController.instance;
NavigationController navigationController = NavigationController.instance;
MapController mapController = MapController.instance;
SensorController sensorController = SensorController.instance;
FetchFilesController fetchFilesController = FetchFilesController.instance;