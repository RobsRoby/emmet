import 'package:emmet/widgets/custom_drop_down.dart';
import 'package:emmet/widgets/custom_icon_button.dart';
import 'package:emmet/widgets/custom_floating_button.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

// ignore_for_file: must_be_immutable
class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);

  List<String> dropdownItemList = ["Item One", "Item Two", "Item Three"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: SizedBox(
                width: double.maxFinite,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(height: 47.v),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 49.h),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                                alignment: Alignment.center,
                                child: Text("Settings",
                                    style: theme.textTheme.headlineLarge)),
                            SizedBox(height: 3.v),
                            Align(
                                alignment: Alignment.center,
                                child: Text("Customize your EMMET experience.",
                                    style: theme.textTheme.bodyMedium)),
                            SizedBox(height: 18.v),
                            Text("Detection Sensitivity",
                                style: CustomTextStyles
                                    .bodySmallOnPrimaryContainer),
                            SizedBox(height: 2.v),
                            Text(
                                " Adjust the sensitivity level for detecting LEGO bricks.",
                                style: CustomTextStyles.bodySmallGray500),
                            SizedBox(height: 10.v),
                            Padding(
                                padding: EdgeInsets.only(right: 6.h),
                                child: SliderTheme(
                                    data: SliderThemeData(
                                        trackShape:
                                            RoundedRectSliderTrackShape(),
                                        activeTrackColor: appTheme.teal400,
                                        inactiveTrackColor: appTheme.gray200,
                                        thumbColor: appTheme.teal400,
                                        thumbShape: RoundSliderThumbShape()),
                                    child: Slider(
                                        value: 52.94,
                                        min: 0.0,
                                        max: 100.0,
                                        onChanged: (value) {}))),
                            SizedBox(height: 13.v),
                            Text("Camera Resolution",
                                style: CustomTextStyles
                                    .bodySmallOnPrimaryContainer),
                            SizedBox(height: 2.v),
                            Text("Choose the resolution for the camera feed.",
                                style: CustomTextStyles.bodySmallGray500),
                            SizedBox(height: 10.v),
                            CustomDropDown(
                                width: 63.h,
                                hintText: "Medium",
                                items: dropdownItemList),
                            SizedBox(height: 20.v),
                            Align(
                                alignment: Alignment.center,
                                child: Container(
                                    width: 234.h,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 14.h),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 11.h, vertical: 10.v),
                                    decoration: AppDecoration.outlineBlack
                                        .copyWith(
                                            borderRadius: BorderRadiusStyle
                                                .roundedBorder4),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CustomImageView(
                                              imagePath: ImageConstant.imgPlay,
                                              height: 44.adaptSize,
                                              width: 44.adaptSize),
                                          SizedBox(height: 7.v),
                                          Text("App Information",
                                              style: CustomTextStyles
                                                  .bodySmallOnPrimaryContainer),
                                          SizedBox(height: 5.v),
                                          Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                  width: 198.h,
                                                  margin: EdgeInsets.only(
                                                      right: 12.h),
                                                  child: RichText(
                                                      text: TextSpan(children: [
                                                        TextSpan(
                                                            text: "App Name:",
                                                            style: theme
                                                                .textTheme
                                                                .labelSmall),
                                                        TextSpan(
                                                            text: " Emmet\n",
                                                            style: CustomTextStyles
                                                                .bodySmallff939393),
                                                        TextSpan(
                                                            text: "\nVersion:",
                                                            style: theme
                                                                .textTheme
                                                                .labelSmall),
                                                        TextSpan(
                                                            text:
                                                                " 1.0.0 (Alpha Version)\n \n",
                                                            style: CustomTextStyles
                                                                .bodySmallff939393),
                                                        TextSpan(
                                                            text: "Developer:",
                                                            style: theme
                                                                .textTheme
                                                                .labelSmall),
                                                        TextSpan(
                                                            text:
                                                                " Creative Minds Co.\n\n",
                                                            style: CustomTextStyles
                                                                .bodySmallff939393),
                                                        TextSpan(
                                                            text:
                                                                "About Emmet:\nEmmet is your ultimate companion for LEGO brick enthusiasts. Whether you're a seasoned builder or just starting your LEGO journey, Emmet is here to inspire and guide you. With advanced object detection technology, Emmet helps you identify LEGO bricks effortlessly, opening doors to endless creative possibilities.",
                                                            style: theme
                                                                .textTheme
                                                                .labelSmall)
                                                      ]),
                                                      textAlign:
                                                          TextAlign.left))),
                                          SizedBox(height: 5.v)
                                        ])))
                          ]))
                ])),
            bottomNavigationBar: _buildBottonNavigationBar(context),
            floatingActionButton: _buildFloatingActionButton(context)));
  }

  /// Section Widget
  Widget _buildBottonNavigationBar(BuildContext context) {
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
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                        padding: EdgeInsets.only(top: 3.v),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          CustomIconButton(
                              height: 45.adaptSize,
                              width: 45.adaptSize,
                              padding: EdgeInsets.all(12.h),
                              onTap: () {
                                onTapBtnSettings(context);
                              },
                              child: CustomImageView(
                                  imagePath: ImageConstant.imgSettings)),
                          Padding(
                              padding: EdgeInsets.only(top: 15.v),
                              child: Text("Home",
                                  style: theme.textTheme.bodySmall))
                        ])),
                    Spacer(flex: 46),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      CustomIconButton(
                          height: 49.adaptSize,
                          width: 49.adaptSize,
                          padding: EdgeInsets.all(12.h),
                          onTap: () {
                            onTapBtnIconButton(context);
                          },
                          child: CustomImageView(
                              imagePath: ImageConstant.imgFrameTeal40049x49)),
                      Padding(
                          padding: EdgeInsets.only(top: 16.v),
                          child: Text("Recent Captures",
                              style: theme.textTheme.bodySmall))
                    ]),
                    Spacer(flex: 53),
                    Padding(
                        padding: EdgeInsets.only(top: 66.v, right: 6.h),
                        child:
                            Text("Settings", style: theme.textTheme.bodySmall))
                  ])))
        ]));
  }

  /// Section Widget
  Widget _buildFloatingActionButton(BuildContext context) {
    return CustomFloatingButton(
        height: 49,
        width: 49,
        backgroundColor: appTheme.yellow100,
        child: CustomImageView(
            imagePath: ImageConstant.imgFrame2, height: 24.5.v, width: 24.5.h));
  }

  onTapBtnSettings(BuildContext context) {
    // TODO: implement Actions
  }

  /// Navigates to the capturesScreen when the action is triggered.
  onTapBtnIconButton(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.capturesScreen);
  }
}
