import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mvp_camera/app/utils/colors.dart';

ThemeData myTheme = ThemeData(
    primaryTextTheme: GoogleFonts.montserratTextTheme(),
    textTheme: TextTheme(
      headline1: TextStyle(
        fontFamily: GoogleFonts.montserrat().fontFamily,
        letterSpacing: 2.7,
        fontSize: 32.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      headline2: TextStyle(
        fontFamily: GoogleFonts.montserrat().fontFamily,
        fontSize: 11.sp,
        color: Colors.grey.shade500,
      ),
      headline3: TextStyle(
        fontFamily: GoogleFonts.montserrat().fontFamily,
        fontSize: 18.sp,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
      bodyText1: TextStyle(
        fontFamily: GoogleFonts.montserrat().fontFamily,
        fontSize: 12.sp,
        color: Colors.black,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 13.sp),
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.transparent,
      elevation: 0,
    ),
    primarySwatch: MaterialColor(primaryColor.value, color),
    primaryColor: primaryColor,
    accentColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    cardColor: primaryColor,
    dividerColor: dividerColor,
    focusColor: primaryColor,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.transparent,
        splashFactory: NoSplash.splashFactory
      ),
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        primary: primaryColor,
        shape: RoundedRectangleBorder( //to set border radius to button
            borderRadius: BorderRadius.circular(12)
        ),
      ),
    ),
    drawerTheme:  DrawerThemeData(
      backgroundColor: primaryColor,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        primary: primaryColor,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: blue, elevation: 5));