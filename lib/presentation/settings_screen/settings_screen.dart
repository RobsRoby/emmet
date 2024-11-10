import 'package:flutter/material.dart';
import 'package:emmet/widgets/custom_drop_down.dart';
import 'package:emmet/core/app_export.dart';
import 'package:emmet/widgets/bottom_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'geminiValidate.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int currentIndex = 4;
  List<String> dropdownItemList = ["Low", "Medium", "High"];
  double iouThreshold = 0.5;
  double confThreshold = 0.5;
  double classThreshold = 0.5;
  String cameraResolution = "Medium";

  // State variables for GEMINI API key
  bool isApiKeyEditable = false;
  bool showApiKey = false;
  String? _geminiApiKey;
  String? geminiApiKey;

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
      cameraResolution = titleCase(settings['cameraResolution']) ?? "Medium";
      geminiApiKey = settings['GeminiApiKey'] ?? null;
    });
  }

  // Save updated settings to the database
  Future<void> _updateSettings() async {
    await UserDatabaseHelper().updateSettings({
      'iouThreshold': iouThreshold,
      'confThreshold': confThreshold,
      'classThreshold': classThreshold,
      'cameraResolution': cameraResolution.toLowerCase(),
      'GeminiApiKey': _geminiApiKey,
    });
  }

  // Exit the app
  void _exitApp() {
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
                Navigator.of(context).pop();
                _exitApp();
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
              SizedBox(height: 35.v),
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

                    // GEMINI API Key Section
                    Row(
                      children: [
                        Text("GEMINI API Key", style: CustomTextStyles.bodySmallOnPrimaryContainer),
                        SizedBox(width: 8),
                        Tooltip(
                          message: "Enter your GEMINI API key.",
                          child: Icon(Icons.info_outline, color: Colors.grey, size: 20),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            isApiKeyEditable ? Icons.lock_open : Icons.lock,
                            color: isApiKeyEditable ? Colors.green : Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              isApiKeyEditable = !isApiKeyEditable;
                            });
                          },
                        ),
                      ],
                    ),
                    if (isApiKeyEditable) ... [
                      TextField(
                        enabled: isApiKeyEditable,
                        obscureText: !showApiKey, // Toggle to show/hide the key
                        onChanged: (value) {
                          geminiApiKey = value;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter GEMINI API Key",
                          suffixIcon: IconButton(
                            icon: Icon(
                              showApiKey ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                showApiKey = !showApiKey;
                              });
                            },
                          ),
                        ),
                        controller: TextEditingController(text: geminiApiKey),
                        style: TextStyle(fontSize: 16),
                      ),

                      // Show the Update button only when API key is editable
                      SizedBox(height: 10.v), // Add some space
                      ElevatedButton(
                        onPressed: () async {
                          if (geminiApiKey != null && geminiApiKey!.isNotEmpty) {
                            final validationResult = await geminiApiValidate(geminiApiKey!).apiValidate();
                            if (validationResult['success']) {
                              // Proceed to update settings
                              _geminiApiKey = geminiApiKey;
                              _updateSettings();

                              // The API key is valid
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("API Key is saved!")),
                              );
                            } else {
                              // The API key is invalid
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Invalid API Key: ${validationResult['error']}")),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please enter a valid API Key")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), // Add padding
                          foregroundColor: Colors.white, // Set foreground color to white
                        ),
                        child: Text("Update API key"),
                      ),
                    ],

                    SizedBox(height: 20.v),

                    // IOU Threshold Slider
                    _buildSlider("IOU Threshold", "Intersection over Union (IOU) threshold controls the overlap required between predicted and actual boxes.", iouThreshold, (value) {
                      setState(() {
                        iouThreshold = value;
                      });
                      _updateSettings();
                    }),

                    // Confidence Threshold Slider
                    _buildSlider("Confidence Threshold", "Confidence threshold sets the minimum confidence level for predictions to be considered.", confThreshold, (value) {
                      setState(() {
                        confThreshold = value;
                      });
                      _updateSettings();
                    }),

                    // Class Threshold Slider
                    _buildSlider("Class Threshold", "Class threshold determines how confident the model must be when classifying objects.", classThreshold, (value) {
                      setState(() {
                        classThreshold = value;
                      });
                      _updateSettings();
                    }),
                    SizedBox(height: 13.v),

                    // Camera Resolution Dropdown
                    _buildDropdown("Camera Resolution", "Select the resolution for the camera feed in the app.", cameraResolution, dropdownItemList, (value) {
                      setState(() {
                        cameraResolution = titleCase(value);
                      });
                      _updateSettings();
                    }),

                    SizedBox(height: 15.v),

                    // Exit App Button
                    Center(
                      child: TextButton(
                        onPressed: () => _showExitConfirmationDialog(context),
                        child: Text(
                          "Exit App",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
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

  // Reusable widget for sliders
  Widget _buildSlider(String label, String tooltip, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: CustomTextStyles.bodySmallOnPrimaryContainer),
            SizedBox(width: 8),
            Tooltip(
              message: tooltip,
              child: Icon(Icons.info_outline, color: Colors.grey, size: 20),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0.0,
          max: 1.0,
          onChanged: onChanged,
        ),
        SizedBox(height: 10.v),
      ],
    );
  }

  String titleCase(String text) {
    return text
        .split(' ')
        .map((word) =>
    word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
        .join(' ');
  }

  // Reusable widget for dropdown
  Widget _buildDropdown(String label, String tooltip, String currentValue, List<String> items, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(titleCase(label), style: CustomTextStyles.bodySmallOnPrimaryContainer),  // Apply titleCase here
            SizedBox(width: 8),
            Tooltip(
              message: tooltip,
              child: Icon(Icons.info_outline, color: Colors.grey, size: 20),
            ),
          ],
        ),
        CustomDropDown(
          width: 90.h,
          hintText: currentValue,
          items: items,
          onChanged: onChanged,
        ),
        SizedBox(height: 13.v),
      ],
    );
  }

}
