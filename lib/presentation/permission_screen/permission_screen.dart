import 'package:emmet/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatefulWidget {
  PermissionScreen({Key? key}) : super(key: key);

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
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
          child: Column(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgLogo,
                height: 73.adaptSize,
                width: 73.adaptSize,
              ),
              SizedBox(height: 19.v),
              Text("Permission Request", style: theme.textTheme.bodyLarge),
              SizedBox(height: 7.v),
              SizedBox(
                width: 226.h,
                child: Text(
                  "To detect LEGO bricks and provide you with an optimal experience, we need access to your device's camera.",
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.bodySmallOnPrimaryContainer,
                ),
              ),
              SizedBox(height: 20.v),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 60.h, vertical: 5.v),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CustomImageView(
                      imagePath: ImageConstant.cameraIconFilled,
                      height: 24.adaptSize,
                      width: 24.adaptSize,
                      margin: EdgeInsets.only(top: 6.v, bottom: 3.v),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 11.h, top: 6.v),
                      child: Column(
                        children: [
                          Text(
                            "Why we need camera access",
                            style: CustomTextStyles.bodySmallOnPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 19.v),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 60.h, vertical: 5.v),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CustomImageView(
                      imagePath: ImageConstant.securityIconFilled,
                      height: 24.adaptSize,
                      width: 24.adaptSize,
                      margin: EdgeInsets.only(top: 6.v, bottom: 3.v),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 11.h, top: 6.v),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your privacy matters",
                            style: CustomTextStyles.bodySmallGray500,
                          ),
                          SizedBox(height: 1.v),
                          Text(
                            "No images are stored or shared",
                            style: CustomTextStyles.bodySmallOnPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 19.v),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 60.h, vertical: 5.v),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CustomImageView(
                      imagePath: ImageConstant.accessIconFilled,
                      height: 24.adaptSize,
                      width: 24.adaptSize,
                      margin: EdgeInsets.only(top: 6.v, bottom: 3.v),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 11.h, top: 6.v),
                      child: Column(
                        children: [
                          Text(
                            "Grant Access",
                            style: CustomTextStyles.bodySmallOnPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 29.v),
              CustomElevatedButton(
                height: 47.v,
                width: 233.h,
                text: "ALLOW",
                buttonStyle: CustomButtonStyles.fillPrimary,
                buttonTextStyle: theme.textTheme.labelLarge!,
                onPressed: () {
                  onTapALLOW(context);
                },
              ),
              SizedBox(height: 63.v),
              SizedBox(width: 108.h, child: Divider()),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onTapALLOW(BuildContext context) async {
    try {
      var status = await Permission.camera.request();
      if (status.isGranted) {
        Navigator.pushNamed(context, AppRoutes.homeScreen);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Permission Denied"),
              content: Text("The system will not continue without camera access."),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("An error occurred while requesting permission: $e"),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

}

