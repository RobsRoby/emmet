import 'package:flutter/material.dart';
import 'package:emmet/widgets/custom_drop_down.dart';
import 'package:emmet/core/app_export.dart';
import 'package:emmet/widgets/bottom_navigation_bar.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int currentIndex = 2;
  List<String> dropdownItemList = ["Low", "Medium", "High"];
  double sliderValue = 52.94;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 47.v),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 49.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text("Settings", style: theme.textTheme.headlineLarge),
                    ),
                    SizedBox(height: 3.v),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Customize your EMMET experience.",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    SizedBox(height: 18.v),
                    Text("Detection Sensitivity", style: CustomTextStyles.bodySmallOnPrimaryContainer),
                    SizedBox(height: 2.v),
                    Text(
                      "Adjust the sensitivity level for detecting LEGO bricks.",
                      style: CustomTextStyles.bodySmallGray500,
                    ),
                    SizedBox(height: 10.v),
                    Padding(
                      padding: EdgeInsets.only(right: 6.h),
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackShape: RoundedRectSliderTrackShape(),
                          activeTrackColor: appTheme.teal400,
                          inactiveTrackColor: appTheme.gray200,
                          thumbColor: appTheme.teal400,
                          thumbShape: RoundSliderThumbShape(),
                        ),
                        child: Slider(
                          value: sliderValue,
                          min: 0.0,
                          max: 100.0,
                          onChanged: (value) {
                            setState(() {
                              sliderValue = value;  // Update the slider value
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 13.v),
                    Text("Camera Resolution", style: CustomTextStyles.bodySmallOnPrimaryContainer),
                    SizedBox(height: 2.v),
                    Text(
                      "Choose the resolution for the camera feed.",
                      style: CustomTextStyles.bodySmallGray500,
                    ),
                    SizedBox(height: 10.v),
                    CustomDropDown(width: 90.h, hintText: "Medium", items: dropdownItemList),
                    SizedBox(height: 20.v),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 234.h,
                        margin: EdgeInsets.symmetric(horizontal: 14.h),
                        padding: EdgeInsets.symmetric(horizontal: 11.h, vertical: 10.v),
                        decoration: AppDecoration.outlineBlack.copyWith(
                          borderRadius: BorderRadiusStyle.roundedBorder4,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomImageView(imagePath: ImageConstant.imgLogo, height: 44.adaptSize, width: 44.adaptSize),
                            SizedBox(height: 7.v),
                            Text(
                              "App Information",
                              style: CustomTextStyles.bodySmallOnPrimaryContainer,
                            ),
                            SizedBox(height: 5.v),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 200.h,
                                margin: EdgeInsets.only(right: 12.h),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "App Name:",
                                        style: theme.textTheme.labelSmall,
                                      ),
                                      TextSpan(
                                        text: " Emmet\n",
                                        style: CustomTextStyles.bodySmallff939393,
                                      ),
                                      TextSpan(
                                        text: "\nVersion:",
                                        style: theme.textTheme.labelSmall,
                                      ),
                                      TextSpan(
                                        text: " 1.0.0 (Alpha Version)\n \n",
                                        style: CustomTextStyles.bodySmallff939393,
                                      ),
                                      TextSpan(
                                        text: "Developer:",
                                        style: theme.textTheme.labelSmall,
                                      ),
                                      TextSpan(
                                        text: "RUGBY BOIZ NG BSCS.\n\n",
                                        style: CustomTextStyles.bodySmallff939393,
                                      ),
                                      TextSpan(
                                        text:
                                        "About Emmet:\nEmmet is your ultimate companion for LEGO brick enthusiasts. Whether you're a seasoned builder or just starting your LEGO journey, Emmet is here to inspire and guide you. With advanced object detection technology, Emmet helps you identify LEGO bricks effortlessly, opening doors to endless creative possibilities.",
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            SizedBox(height: 5.v),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBarWidget(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

