import 'package:emmet/widgets/custom_floating_text_field.dart';
import 'package:emmet/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

// ignore_for_file: must_be_immutable
class PermissionScreen extends StatelessWidget {
  PermissionScreen({Key? key}) : super(key: key);

  TextEditingController timeController = TextEditingController();

  TextEditingController grantAccessController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: 49.v),
                child: Column(children: [
                  CustomImageView(
                      imagePath: ImageConstant.imgEmmet1,
                      height: 73.adaptSize,
                      width: 73.adaptSize),
                  SizedBox(height: 19.v),
                  Text("Permission Request", style: theme.textTheme.bodyLarge),
                  SizedBox(height: 7.v),
                  SizedBox(
                      width: 226.h,
                      child: Text(
                          "To detect LEGO bricks and provide you with an optimal experience, we need access to your device's camera. This will allow us to analyze images and identify LEGO bricks in real-time.",
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: CustomTextStyles.bodySmallOnPrimaryContainer)),
                  SizedBox(height: 20.v),
                  CustomFloatingTextField(
                      width: 233.h,
                      controller: timeController,
                      labelText: "Why we need camera access",
                      labelStyle: CustomTextStyles.bodySmallOnPrimaryContainer,
                      hintText: "Why we need camera access",
                      prefix: Container(
                          margin: EdgeInsets.only(left: 12.h, right: 11.h),
                          child: CustomImageView(
                              imagePath: ImageConstant.imgFrame,
                              height: 24.adaptSize,
                              width: 24.adaptSize)),
                      prefixConstraints: BoxConstraints(maxHeight: 53.v)),
                  SizedBox(height: 19.v),
                  Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.h, vertical: 9.v),
                      decoration: AppDecoration.outlineBlack.copyWith(
                          borderRadius: BorderRadiusStyle.roundedBorder4),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            CustomImageView(
                                imagePath: ImageConstant.imgFrameTeal400,
                                height: 24.adaptSize,
                                width: 24.adaptSize,
                                margin: EdgeInsets.only(top: 6.v, bottom: 3.v)),
                            Padding(
                                padding: EdgeInsets.only(left: 11.h, top: 6.v),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Your privacy matters",
                                          style: CustomTextStyles
                                              .bodySmallGray500),
                                      SizedBox(height: 1.v),
                                      Text("No images are stored or shared",
                                          style: CustomTextStyles
                                              .bodySmallOnPrimaryContainer)
                                    ]))
                          ])),
                  SizedBox(height: 19.v),
                  CustomFloatingTextField(
                      width: 233.h,
                      controller: grantAccessController,
                      labelText: "Grant Access",
                      labelStyle: CustomTextStyles.bodySmallOnPrimaryContainer,
                      hintText: "Grant Access",
                      textInputAction: TextInputAction.done,
                      prefix: Container(
                          margin: EdgeInsets.only(left: 14.h, right: 8.h),
                          child: CustomImageView(
                              imagePath: ImageConstant.imgFrameTeal40024x24,
                              height: 24.adaptSize,
                              width: 24.adaptSize)),
                      prefixConstraints: BoxConstraints(maxHeight: 53.v)),
                  SizedBox(height: 29.v),
                  CustomElevatedButton(
                      height: 47.v,
                      width: 233.h,
                      text: "ALLOW",
                      buttonStyle: CustomButtonStyles.fillPrimary,
                      buttonTextStyle: theme.textTheme.labelLarge!,
                      onPressed: () {
                        onTapALLOW(context);
                      }),
                  SizedBox(height: 63.v),
                  SizedBox(width: 108.h, child: Divider())
                ]))));
  }

  /// Navigates to the homeScreen when the action is triggered.
  onTapALLOW(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.homeScreen);
  }
}
