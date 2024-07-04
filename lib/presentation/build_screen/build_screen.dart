import 'package:emmet/widgets/app_bar/custom_app_bar.dart';
import 'package:emmet/widgets/app_bar/appbar_leading_image.dart';
import 'package:emmet/widgets/app_bar/appbar_title.dart';
import 'package:emmet/widgets/app_bar/appbar_subtitle.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

// ignore_for_file: must_be_immutable
class BuildScreen extends StatelessWidget {
  BuildScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: _buildAppBar(context),
            body: Column(
              children: [
                Expanded(
                  child: Positioned.fill(
                    child: CustomImageView(imagePath: ImageConstant.imgCamera),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: PageView(
                      children: [
                        CustomImageView(imagePath: ImageConstant.imgMedia), // replace with your images
                        CustomImageView(imagePath: ImageConstant.imgMedia),
                        CustomImageView(imagePath: ImageConstant.imgMedia),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 70.v,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(5, (index) {
                      return Container(
                        width: 100.h,
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            'Part ${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            )));
  }

  /// TopBar
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
          AppbarTitle(
              text: "Build", margin: EdgeInsets.only(left: 11.h, right: 13.h)),
          AppbarSubtitle(text: "An Airplane")
        ]),
        styleType: Style.bgShadow);
  }

  /// Navigates back to the previous screen.
  onTapArrowLeft(BuildContext context) {
    Navigator.pop(context);
  }
}

