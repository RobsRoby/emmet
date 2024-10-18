import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:emmet/core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkCameraPermission();
  }

  Future<void> checkCameraPermission() async {
    var status = await Permission.camera.status;
    await startServer();
    if (status.isGranted) {
      Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.permissionScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Container(
          width: SizeUtils.width,
          height: SizeUtils.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.5, 0),
              end: Alignment(0.5, 1),
              colors: [
                theme.colorScheme.primary.withOpacity(0.7),
                appTheme.yellow800,
              ],
            ),
          ),
          child: SizedBox(
            width: double.maxFinite,
            child: CustomImageView(
              imagePath: ImageConstant.imgLogo,
              height: 206.adaptSize,
              width: 206.adaptSize,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }
}
