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
                  "To detect LEGO bricks and save screenshots, we need access to your device's camera and storage.",
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.bodySmallOnPrimaryContainer,
                ),
              ),
              SizedBox(height: 20.v),
              permissionItem(
                iconPath: ImageConstant.cameraIconFilled,
                title: "Why we need camera access",
                description: "Allows us to detect LEGO bricks.",
              ),
              permissionItem(
                iconPath: ImageConstant.securityIconFilled,
                title: "Your privacy matters",
                description: "No data is shared without permission.",
              ),
              permissionItem(
                iconPath: ImageConstant.accessIconFilled,
                title: "Grant Access",
                description: "Allows saving screenshots to your device.",
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

  Widget permissionItem({required String iconPath, required String title, required String description}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60.h, vertical: 5.v),
      child: Row(
        children: [
          CustomImageView(
            imagePath: iconPath,
            height: 24.adaptSize,
            width: 24.adaptSize,
            margin: EdgeInsets.only(top: 6.v, bottom: 3.v),
          ),
          SizedBox(width: 11.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CustomTextStyles.bodySmallOnPrimaryContainer),
              SizedBox(height: 1.v),
              Text(description, style: CustomTextStyles.bodySmallGray500),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> onTapALLOW(BuildContext context) async {
    try {
      // Request camera permission
      var cameraStatus = await Permission.camera.request();
      // Request storage permission
      var storageStatus = await Permission.storage.request();

      if (cameraStatus.isGranted && storageStatus.isGranted) {
        // Navigate to the home screen if both permissions are granted
        Navigator.pushNamed(context, AppRoutes.homeScreen);
      } else {
        // If any permission is denied, show a dialog
        String deniedPermission = cameraStatus.isDenied ? "Camera" : "Storage";
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Permission Denied"),
              content: Text("The system will not continue without $deniedPermission access."),
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
      // Handle any errors in permission request process
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
