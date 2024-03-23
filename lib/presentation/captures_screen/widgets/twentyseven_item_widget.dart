import 'package:emmet/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

// ignore: must_be_immutable
class TwentysevenItemWidget extends StatelessWidget {
  const TwentysevenItemWidget({Key? key})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 164.v,
      width: 135.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgCapture,
            width: 135.h,
            radius: BorderRadius.circular(
              9.h,
            ),
            alignment: Alignment.center,
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 13.h,
                vertical: 45.v,
              ),
              decoration: AppDecoration.fillYellow.copyWith(
                borderRadius: BorderRadiusStyle.roundedBorder11,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomElevatedButton(
                    width: 103.h,
                    text: "Build",
                    leftIcon: Container(
                      margin: EdgeInsets.only(right: 6.h),
                      child: CustomImageView(
                        imagePath: ImageConstant.imgFrameOnprimary,
                        height: 21.adaptSize,
                        width: 21.adaptSize,
                      ),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                  SizedBox(height: 3.v),
                  CustomElevatedButton(
                    width: 102.h,
                    text: "Delete",
                    leftIcon: Container(
                      margin: EdgeInsets.only(right: 6.h),
                      child: CustomImageView(
                        imagePath: ImageConstant.imgFrameOnprimary24x24,
                        height: 24.adaptSize,
                        width: 24.adaptSize,
                      ),
                    ),
                    buttonStyle: CustomButtonStyles.fillPrimaryTL17,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
