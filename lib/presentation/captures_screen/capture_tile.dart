import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:emmet/widgets/custom_elevated_button.dart';
import 'package:emmet/core/app_export.dart';

class CaptureTile extends StatelessWidget {
  final int tileIndex;
  final String? imgUrl;
  final Uint8List? imgData;
  final String setNum;
  final bool isClicked;
  final VoidCallback onTileClick;
  final VoidCallback onDelete; // Add this

  const CaptureTile({
    required this.tileIndex,
    required this.imgUrl,
    required this.imgData,
    required this.setNum,
    required this.isClicked,
    required this.onTileClick,
    required this.onDelete, // Add this
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
              child: _buildImage(),
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

  // Function to render image depending on the source type
  Widget _buildImage() {
    if (imgData != null) {
      // If imgData is provided (in-memory image)
      return Image.memory(
        imgData!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
      );
    } else if (imgUrl != null && imgUrl!.isNotEmpty) {
      // If imgUrl is a valid network URL or file path
      return Image.network(
        imgUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
      );
    } else {
      // Fallback if no valid image is provided
      return Icon(Icons.image_not_supported);
    }
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
                onDelete(); // Call the delete callback
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBuild(BuildContext context) {
    return CustomElevatedButton(
      width: 80.h,
      text: "Build",
      leftIcon: Container(
        margin: EdgeInsets.only(right: 8.h),
        child: CustomImageView(
          imagePath: ImageConstant.imgBuild,
          height: 24.adaptSize,
          width: 24.adaptSize,
          fit: BoxFit.cover,
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.buildScreen, arguments: setNum); // Pass setNum
      },
    );
  }

}