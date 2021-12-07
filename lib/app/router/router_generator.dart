import 'package:flutter/material.dart';
import 'package:mvp_camera/view/camera/camera_screen.dart';
import 'package:mvp_camera/view/camera/in_app_gallery.dart';
import 'package:mvp_camera/view/splash/main_splash_screen.dart';
// STATIC ROUTE NAMES

// SPLASH / ON BOARDING
const String mainSplashScreen = '/main-splash-screen';
const String cameraScreen = '/camera-screen';
const String inAppGallery = '/in-app-gallery';

// ignore: todo
// TODO : ROUTES GENERATOR CLASS THAT CONTROLS THE FLOW OF NAVIGATION/ROUTING


class RouteGenerator {
  // FUNCTION THAT HANDLES ROUTING
  static Route<dynamic> onGeneratedRoutes(RouteSettings settings) {
    late dynamic args;
    if (settings.arguments != null) {
      args = settings.arguments as Map;
    }
    debugPrint(settings.name);
    switch (settings.name) {

      case mainSplashScreen:
        return _getPageRoute(const MainSplashScreen());

        case cameraScreen:
        return _getPageRoute(const CameraScreen());

        case inAppGallery:
        return _getPageRoute(const InAppGallery());


      default:
        return _errorRoute();
    }
  }

  // FUNCTION THAT HANDLES NAVIGATION
  static PageRoute _getPageRoute(Widget child) {
    return MaterialPageRoute(builder: (ctx) => child);
  }

  // 404 PAGE
  static PageRoute _errorRoute() {
    return MaterialPageRoute(builder: (ctx) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('404'),
        ),
        body: const Center(
          child: Text('ERROR 404: Not Found'),
        ),
      );
    });
  }
}
