import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({Key? key}) : super(key: key);

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
                    color: theme.colorScheme.onPrimary,
                    image: DecorationImage(
                        image: AssetImage(ImageConstant.imgCamera),
                        fit: BoxFit.cover)),
                child: Container(
                    width: double.maxFinite,
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.h, vertical: 30.v),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _buildEighteen(context),
                      Spacer(),
                      CustomImageView(
                          imagePath: ImageConstant.imgFloatingIcon,
                          height: 30.adaptSize,
                          width: 30.adaptSize),
                      SizedBox(height: 4.v),
                      SizedBox(
                          width: 164.h,
                          child: Text(
                              " Press the capture button to freeze the current frame and analyze the LEGO bricks present.",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: CustomTextStyles.labelMedium10_1)),
                      SizedBox(height: 10.v),
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 39.h),
                          decoration: AppDecoration.outlineBlack900.copyWith(
                              borderRadius: BorderRadiusStyle.roundedBorder23),
                          child: GestureDetector(
                              onTap: () {
                                onTapThirtyOne(context);
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 80.h, vertical: 9.v),
                                  decoration: AppDecoration.fillPrimary
                                      .copyWith(
                                          borderRadius: BorderRadiusStyle
                                              .roundedBorder23),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: 5.v),
                                        Text("Capture",
                                            style: CustomTextStyles
                                                .titleLargeOnPrimary)
                                      ])))),
                      SizedBox(height: 17.v)
                    ])))));
  }

  /// Section Widget
  Widget _buildEighteen(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 5.h),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          CustomImageView(
              imagePath: ImageConstant.imgCloseButton,
              height: 35.adaptSize,
              width: 35.adaptSize,
              onTap: () {
                onTapImgCloseButton(context);
              }),
          CustomImageView(imagePath: ImageConstant.imgClose, width: 35.h)
        ]));
  }

  /// Navigates to the homeScreen when the action is triggered.
  onTapImgCloseButton(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.homeScreen);
  }

  /// Navigates to the exploreScreen when the action is triggered.
  onTapThirtyOne(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.exploreScreen);
  }
}
