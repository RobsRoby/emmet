import 'package:flutter/material.dart';
import 'package:emmet/widgets/custom_drop_down.dart';
import 'package:emmet/core/app_export.dart';
import 'package:emmet/widgets/bottom_navigation_bar.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int currentIndex = 2;
  List<String> dropdownItemList = ["Low", "Medium", "High"];
  double iouThreshold = 0.5;
  double confThreshold = 0.5;
  double classThreshold = 0.5;
  String cameraResolution = "Medium";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Fetch settings from the database
  Future<void> _loadSettings() async {
    final settings = await UserDatabaseHelper().getSettings();
    setState(() {
      iouThreshold = settings['iouThreshold'] ?? 0.5;
      confThreshold = settings['confThreshold'] ?? 0.5;
      classThreshold = settings['classThreshold'] ?? 0.5;
      cameraResolution = settings['cameraResolution'] ?? "Medium";
    });
  }

  // Save updated settings to the database
  Future<void> _updateSettings() async {
    await UserDatabaseHelper().updateSettings({
      'iouThreshold': iouThreshold,
      'confThreshold': confThreshold,
      'classThreshold': classThreshold,
      'cameraResolution': cameraResolution,
    });
  }

  // Exit the app
  void _exitApp() {
    // This will close the app
    SystemNavigator.pop();
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Exit"),
          content: Text("Are you sure you want to exit the app?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Exit"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _exitApp(); // Call the method to exit the app
              },
            ),
          ],
        );
      },
    );
  }

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

                    // IOU Threshold Slider
                    Row(
                      children: [
                        Text("IOU Threshold", style: CustomTextStyles.bodySmallOnPrimaryContainer),
                        SizedBox(width: 8),
                        Tooltip(
                          message: "Intersection over Union (IOU) threshold controls the overlap required between predicted and actual boxes.",
                          child: Icon(Icons.info_outline, color: Colors.grey, size: 20),
                        ),
                      ],
                    ),
                    Slider(
                      value: iouThreshold,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        setState(() {
                          iouThreshold = value;
                        });
                        _updateSettings(); // Save when value changes
                      },
                    ),
                    SizedBox(height: 10.v),

                    // Confidence Threshold Slider
                    Row(
                      children: [
                        Text("Confidence Threshold", style: CustomTextStyles.bodySmallOnPrimaryContainer),
                        SizedBox(width: 8),
                        Tooltip(
                          message: "Confidence threshold sets the minimum confidence level for predictions to be considered.",
                          child: Icon(Icons.info_outline, color: Colors.grey, size: 20),
                        ),
                      ],
                    ),
                    Slider(
                      value: confThreshold,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        setState(() {
                          confThreshold = value;
                        });
                        _updateSettings();
                      },
                    ),
                    SizedBox(height: 10.v),

                    // Class Threshold Slider
                    Row(
                      children: [
                        Text("Class Threshold", style: CustomTextStyles.bodySmallOnPrimaryContainer),
                        SizedBox(width: 8),
                        Tooltip(
                          message: "Class threshold determines how confident the model must be when classifying objects.",
                          child: Icon(Icons.info_outline, color: Colors.grey ,size: 20),
                        ),
                      ],
                    ),
                    Slider(
                      value: classThreshold,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        setState(() {
                          classThreshold = value;
                        });
                        _updateSettings();
                      },
                    ),
                    SizedBox(height: 13.v),

                    // Camera Resolution Dropdown
                    Row(
                      children: [
                        Text("Camera Resolution", style: CustomTextStyles.bodySmallOnPrimaryContainer),
                        SizedBox(width: 8),
                        Tooltip(
                          message: "Select the resolution for the camera feed in the app.",
                          child: Icon(Icons.info_outline, color: Colors.grey, size: 20),
                        ),
                      ],
                    ),
                    CustomDropDown(
                      width: 90.h,
                      hintText: cameraResolution,
                      items: dropdownItemList,
                      onChanged: (value) {
                        setState(() {
                          cameraResolution = value;
                        });
                        _updateSettings();
                      },
                    ),

                    SizedBox(height: 30.v),

                    // Exit App Button
                    Center(
                      child: TextButton(
                        onPressed: () => _showExitConfirmationDialog(context),
                        child: Text(
                          "Exit App",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white, // Set the text color to white
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red, // Set the button color
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0), // Set the border radius
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 5.v),

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

