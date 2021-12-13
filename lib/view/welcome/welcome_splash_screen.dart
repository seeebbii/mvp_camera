import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:mvp_camera/app/constant/image_paths.dart';
import 'package:mvp_camera/app/router/router_generator.dart';

class WelcomeSplashScreen extends StatefulWidget {
  const WelcomeSplashScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeSplashScreen> createState() => _WelcomeSplashScreenState();
}

class _WelcomeSplashScreenState extends State<WelcomeSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController animation;
  late Animation<double> _fadeInFadeOut;

  @override
  void initState() {
    Timer(const Duration(seconds: 4),
            () => navigationController.getOffAll(welcomeProjectName));
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 1).animate(animation);

    animation.addStatusListener((status) {
      // if (status == AnimationStatus.completed) {
      //   animation.reverse();
      // } else if (status == AnimationStatus.dismissed) {
      //   animation.forward();
      // }
    });
    animation.forward();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
            opacity: _fadeInFadeOut,
            child: Image.asset(
          ImagePaths.appLogo,
          height: 100.sp,
        )),
      ),
    );
  }
}
