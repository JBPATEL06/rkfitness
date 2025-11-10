import 'package:flutter/material.dart';

class Responsive {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double textScaleFactor(BuildContext context) {
     return MediaQuery.of(context).textScaler.scale(1.0);
  }

  static bool isMobile(BuildContext context) {
    return screenWidth(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= 600 && screenWidth(context) < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= 1200;
  }

  static double responsiveWidth(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  static double responsiveHeight(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }

  static double getProportionateScreenHeight(BuildContext context, double inputHeight) {
    double screenHeight = MediaQuery.of(context).size.height;
    // 812 is the layout height that designer use
    return (inputHeight / 812.0) * screenHeight;
  }

  static double getProportionateScreenWidth(BuildContext context, double inputWidth) {
    double screenWidth = MediaQuery.of(context).size.width;
    // 375 is the layout width that designer use
    return (inputWidth / 375.0) * screenWidth;
  }
}