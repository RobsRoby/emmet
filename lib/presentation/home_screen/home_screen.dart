import 'package:emmet/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(horizontal: 23.h, vertical: 33.v),
                child: Column(children: [
                  CustomImageView(
                      imagePath: ImageConstant.imgELogo,
                      height: 60.adaptSize,
                      width: 60.adaptSize),
                  SizedBox(height: 2.v),
                  Text(" Start Detecting!",
                      style: theme.textTheme.headlineLarge),
                  SizedBox(height: 3.v),
                  Text("Point, Explore, and Build!",
                      style: theme.textTheme.bodyMedium),
                  SizedBox(height: 20.v),
                  _buildDetectButton(context),
                  SizedBox(height: 5.v)
                ])),
            bottomNavigationBar: _buildBottomNavigationBar(context)));
  }

  /// Section Widget
  Widget _buildDetectButton(BuildContext context) {
    return SizedBox(
        height: 313.adaptSize,
        width: 313.adaptSize,
        child: Stack(alignment: Alignment.center, children: [
          Align(
              alignment: Alignment.center,
              child: GestureDetector(
                  onTap: () {
                    onTapHover(context);
                  },
                  child: Container(
                      padding: EdgeInsets.all(21.h),
                      decoration: AppDecoration.gradientYellowToTeal.copyWith(
                          borderRadius: BorderRadiusStyle.roundedBorder156),
                      child: Container(
                          height: 271.adaptSize,
                          width: 271.adaptSize,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(135.h),
                              gradient: LinearGradient(
                                  begin: Alignment(0.5, 0),
                                  end: Alignment(0.5, 1),
                                  colors: [
                                    appTheme.teal400.withOpacity(0.1),
                                    theme.colorScheme.primary.withOpacity(0.1)
                                  ])))))),
          Align(
              alignment: Alignment.center,
              child: Container(
                  height: 216.adaptSize,
                  width: 216.adaptSize,
                  padding: EdgeInsets.symmetric(vertical: 42.v),
                  decoration: AppDecoration.gradientYellowToPrimary.copyWith(
                      borderRadius: BorderRadiusStyle.circleBorder108),
                  child: CustomImageView(
                      imagePath: ImageConstant.imgImage1,
                      height: 131.v,
                      alignment: Alignment.center)))
        ]));
  }

  /// Section Widget
  Widget _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
        height: 88.v,
        width: double.maxFinite,
        child: Stack(alignment: Alignment.topCenter, children: [
          CustomImageView(
              imagePath: ImageConstant.imgBg,
              height: 63.v,
              alignment: Alignment.bottomCenter),
          Align(
              alignment: Alignment.topCenter,
              child: Padding(
                  padding:
                      EdgeInsets.only(left: 50.h, right: 50.h, bottom: 8.v),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 3.v),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconButton(
                                      height: 45.adaptSize,
                                      width: 45.adaptSize,
                                      padding: EdgeInsets.all(12.h),
                                      decoration:
                                          IconButtonStyleHelper.fillYellow,
                                      child: CustomImageView(
                                          imagePath:
                                              ImageConstant.imgLocation)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 15.v),
                                      child: Text("Home",
                                          style: theme.textTheme.bodySmall))
                                ])),
                        Spacer(flex: 50),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          CustomIconButton(
                              height: 49.adaptSize,
                              width: 49.adaptSize,
                              padding: EdgeInsets.all(12.h),
                              onTap: () {
                                onTapBtnIconButton(context);
                              },
                              child: CustomImageView(
                                  imagePath:
                                      ImageConstant.imgFrameTeal40049x49)),
                          Padding(
                              padding: EdgeInsets.only(top: 16.v),
                              child: Text("Recent Captures",
                                  style: theme.textTheme.bodySmall))
                        ]),
                        Spacer(flex: 50),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          CustomIconButton(
                              height: 49.adaptSize,
                              width: 49.adaptSize,
                              padding: EdgeInsets.all(12.h),
                              onTap: () {
                                onTapBtnIconButton1(context);
                              },
                              child: CustomImageView(
                                  imagePath: ImageConstant.imgFrame49x49)),
                          Padding(
                              padding: EdgeInsets.only(top: 16.v),
                              child: Text("Settings",
                                  style: theme.textTheme.bodySmall))
                        ])
                      ])))
        ]));
  }

  /// Navigates to the cameraScreen when the action is triggered.
  onTapHover(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.cameraScreen);
  }

  onTapBtnIconButton(BuildContext context) {
    // TODO: implement Actions
  }

  onTapBtnIconButton1(BuildContext context) {
    // TODO: implement Actions
  }
}
