import 'package:flutter/material.dart';
import 'package:emmet/widgets/custom_elevated_button.dart';
import 'package:emmet/core/app_export.dart';

class CaptureTile extends StatelessWidget {
  final int tileIndex;
  final bool isClicked;
  final VoidCallback onTileClick;

  const CaptureTile({
    required this.tileIndex,
    required this.isClicked,
    required this.onTileClick,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTileClick,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomImageView(
                  imagePath: ImageConstant.imgMedia,
                  height: 40.adaptSize,
                  width: 40.adaptSize),
            ),
            if (isClicked)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBuild(context),
                    SizedBox(height: 5), // Add space between buttons if needed
                    _buildDelete(context),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Delete Button
  Widget _buildDelete(BuildContext context) {
    return CustomElevatedButton(
      width: 80.h,
      text: "Delete",
      leftIcon: Container(
        margin: EdgeInsets.only(right: 8.h),
        child: CustomImageView(
          imagePath: ImageConstant.imgDelete,
          height: 24.adaptSize,
          width: 24.adaptSize,
        ),
      ),
      buttonStyle: CustomButtonStyles.fillPrimaryTL17,
      onPressed: () {
        _showDeleteConfirmation(context);
      },
    );
  }

  /// Show Delete Confirmation Dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this LEGO set?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteItem(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// Delete Logic
  void _deleteItem(BuildContext context) {
    // Perform your delete logic here
    // Example: delete the item from a list or database
    // Update UI or show confirmation message
    showDialog(
      context: context,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: Text("Deleted"),
          content: Text("LEGO set has been deleted."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(alertContext).pop();

              },
            ),
          ],
        );
      },
    );
    // Here you can perform further actions after deletion if needed
  }

  /// Build Button
  Widget _buildBuild(BuildContext context) {
    return CustomElevatedButton(
      width: 80.h,
      text: "Build",
      leftIcon: Container(
          margin: EdgeInsets.only(right: 8.h),
          child: CustomImageView(
              imagePath: ImageConstant.imgBuild,
              height: 24.adaptSize,
              width: 24.adaptSize)),
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.buildScreen);
      },
    );
  }
}



