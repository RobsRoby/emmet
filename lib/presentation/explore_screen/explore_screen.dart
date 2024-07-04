import 'package:emmet/widgets/app_bar/custom_app_bar.dart';
import 'package:emmet/widgets/app_bar/appbar_leading_image.dart';
import 'package:emmet/widgets/app_bar/appbar_title.dart';
import 'package:emmet/widgets/app_bar/appbar_subtitle.dart';
import 'package:emmet/widgets/custom_outlined_button.dart';
import 'package:emmet/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

// ignore_for_file: must_be_immutable
class ExploreScreen extends StatelessWidget {
  ExploreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: _buildAppBar(context),
            body: SizedBox(
                width: SizeUtils.width,
                child: SingleChildScrollView(
                    padding: EdgeInsets.only(top: 25.v),
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.h),
                        child: Column(children: [
                          _buildCard(context),
                        ]))))));
  }

  /// Top Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
        leadingWidth: 54.h,
        leading: AppbarLeadingImage(
            imagePath: ImageConstant.imgArrowLeft,
            margin: EdgeInsets.only(left: 30.h, top: 20.v, bottom: 20.v),
            onTap: () {
              onTapArrowLeft(context);
            }),
        centerTitle: true,
        title: Column(children: [
          AppbarTitle(text: "Explore"),
          AppbarSubtitle(
              text: "215 bricks", margin: EdgeInsets.symmetric(horizontal: 3.h))
        ]),
        styleType: Style.bgShadow);
  }

  /// Save Button
  Widget _buildSave(BuildContext context) {
    return CustomOutlinedButton(
        width: 100.h,
        text: "Save",
        leftIcon: Container(
            margin: EdgeInsets.only(right: 7.h),
            child: CustomImageView(
                imagePath: ImageConstant.imgSave,
                height: 24.adaptSize,
                width: 24.adaptSize)),
        onPressed: () {
          onTapSave(context);
        }
    );
  }

  /// Build Button
  Widget _buildBuild(BuildContext context) {
    return CustomElevatedButton(
        width: 103.h,
        text: "Build",
        margin: EdgeInsets.only(left: 7.h),
        leftIcon: Container(
            margin: EdgeInsets.only(right: 8.h),
            child: CustomImageView(
                imagePath: ImageConstant.imgBuild,
                height: 24.adaptSize,
                width: 24.adaptSize)),
        onPressed: () {
          onTapBuild(context);
        });
  }

  /// LEGO Set Card
  Widget _buildCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.h),
      decoration: AppDecoration.outlineBlack9001
          .copyWith(borderRadius: BorderRadiusStyle.roundedBorder11),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImageView(imagePath: ImageConstant.imgMedia, height: 189.v),
            SizedBox(height: 17.v),
            Padding(
              padding: EdgeInsets.only(left: 15.h),
              child: Text("An Airplane", style: theme.textTheme.titleSmall),
            ),
            SizedBox(height: 10.v),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 15.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSave(context),
                    _buildBuild(context),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15.v),
          ],
        ),
      ),
    );
  }

  onTapBuild(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.buildScreen);
  }

  onTapSave(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('LEGO set saved!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  onTapArrowLeft(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Go back home or capture bricks?"),
          actions: <Widget>[
            TextButton(
              child: Text("Go Home"),
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
              },
            ),
            TextButton(
              child: Text("Capture Another"),
              onPressed: () {
                // Implement navigation to capture screen or take action
                Navigator.pushReplacementNamed(context, AppRoutes.cameraScreen);
              },
            ),
          ],
        );
      },
    );
  }

}
