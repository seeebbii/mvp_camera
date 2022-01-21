import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvp_camera/controller/map_controller.dart';
import 'package:mvp_camera/controller/navigation_controller.dart';
import 'package:wakelock/wakelock.dart';
import 'app/constant/image_paths.dart';
import 'app/router/router_generator.dart';
import 'app/theme/app_theme.dart';
import 'controller/my_camera_controller.dart';
import 'controller/sensor_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(NavigationController());
  Get.put(SensorController());

  // FOR GOOGLE MAPS
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
        builder: () => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: myTheme,
          initialRoute: welcomeSplashScreen,
          onGenerateRoute: RouteGenerator.onGeneratedRoutes,
        ));
  }
}
