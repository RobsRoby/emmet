import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key})
      : super(
          key: key,
        );

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
