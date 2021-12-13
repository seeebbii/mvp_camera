import 'package:flutter/material.dart';
import 'package:mvp_camera/view/camera/camera_screen.dart';
import 'package:mvp_camera/view/camera/in_app_gallery.dart';
import 'package:mvp_camera/view/welcome/select_interval_screen.dart';
import 'package:mvp_camera/view/welcome/welcome_project_name.dart';
import 'package:mvp_camera/view/welcome/welcome_splash_screen.dart';
// STATIC ROUTE NAMES

// SPLASH / ON BOARDING
const String welcomeSplashScreen = '/welcome-splash-screen';
const String welcomeProjectName = '/welcome-project-name-screen';
const String selectIntervalScreen = '/select-interval-screen';
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
      case welcomeSplashScreen:
        return _getPageRoute(const WelcomeSplashScreen());

      case welcomeProjectName:
        return _getPageRoute(const WelcomeProjectName());

      case selectIntervalScreen:
        return _getPageRoute(const SelectIntervalScreen());

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
