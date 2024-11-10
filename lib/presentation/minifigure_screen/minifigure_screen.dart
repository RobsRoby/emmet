// ignore_for_file: unused_import, unused_field, unused_element
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:emmet/widgets/bottom_navigation_bar.dart';
import 'package:emmet/core/app_export.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';

class MinifigureScreen extends StatefulWidget {
  MinifigureScreen({Key? key}) : super(key: key);

  @override
  _MinifigureScreenState createState() => _MinifigureScreenState();
}

class _MinifigureScreenState extends State<MinifigureScreen> with SingleTickerProviderStateMixin {
  WebViewController? _webViewController;
  int currentIndex = 3;
  bool _isCustomizationVisible = false;

  double _expressionValue = 0;
  double _upperHueValue = 200.0;
  double _upperSaturationValue = 0.0;
  double _upperLightnessValue = 90.0;
  double _lowerHueValue = 200.0;
  double _lowerSaturationValue = 0.0;
  double _lowerLightnessValue = 90.0;

  late TabController _tabController;

  // Initialize ScreenshotController
  final ScreenshotController _screenshotController = ScreenshotController();

  bool _isWebViewLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _initializeWebViewController() async {
    _webViewController = WebViewController()
      ..loadRequest(Uri.parse('http://127.0.0.1:8080/minifigure_maker/index.html'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isWebViewLoading = true; // Start shimmer when loading starts
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isWebViewLoading = false; // Stop shimmer when loading finishes
            });
          },
        ),
      );
  }

  void _callExplodeMinifigure() {
    _webViewController?.runJavaScript('explodeMinifigure();');
  }

  void _callRandomizeInputs() {
    _webViewController?.runJavaScript('randomizeInputs();');
  }

  void _callSetExpression() {
    _webViewController?.runJavaScript('setExpression(${_expressionValue.toInt()});');
  }

  void _callSetColors() {
    _webViewController?.runJavaScript('setColors(${_upperHueValue.toInt()}, ${_upperSaturationValue.toInt()}, ${_upperLightnessValue.toInt()}, ${_lowerHueValue.toInt()}, ${_lowerSaturationValue.toInt()}, ${_lowerLightnessValue.toInt()});');
  }

  // Function to capture the WebView screenshot
  Future<void> _captureScreenshot() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      // Use FilePicker to ask the user where to save the file
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        // Save the image in the chosen directory
        final imagePath = await File('$selectedDirectory/minifigure_screenshot.png').writeAsBytes(image);

        // Notify the user that the image has been saved
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Screenshot saved to ${imagePath.path}')),
        );
      } else {
        // User canceled the directory selection
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save location not selected')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Screenshot(
          controller: _screenshotController,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 47.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text("Minifigure Creator",
                            style: Theme.of(context).textTheme.headlineLarge),
                      ),
                      SizedBox(height: 3.0),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Customize your minifigure.",
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // The buttons will go here, before the WebView
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _callExplodeMinifigure,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                            backgroundColor: Colors.redAccent,
                          ),
                          icon: Icon(FontAwesomeIcons.bomb, size: 14, color: Colors.white),
                          label: Text("Explode", style: TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                        ElevatedButton.icon(
                          onPressed: _callRandomizeInputs,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                            backgroundColor: Color.fromRGBO(33, 156, 144, 1),
                          ),
                          icon: Icon(FontAwesomeIcons.shuffle, size: 14, color: Colors.white),
                          label: Text("Randomize", style: TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                        ElevatedButton.icon(
                          onPressed: _captureScreenshot,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                            backgroundColor: Color.fromRGBO(239, 148, 28, 1),
                          ),
                          icon: Icon(FontAwesomeIcons.floppyDisk, size: 14, color: Colors.white),
                          label: Text("Capture", style: TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),

                  // WebView loading indicator
                  _isWebViewLoading
                      ? Expanded(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        height: MediaQuery.of(context).size.height / 2,
                      ),
                    ),
                  )
                      : Expanded(
                    child: WebViewWidget(controller: _webViewController!),
                  ),

                  // Show the "Customizations" title only if the customization section is NOT visible
                  if (!_isCustomizationVisible)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                      child: Text(
                        "Customizations",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),

                  // The collapsible customization section
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _isCustomizationVisible ? 120 : 0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TabBar(
                            controller: _tabController,
                            tabs: [
                              Tab(text: "Expression"),
                              Tab(text: "Upper Body"),
                              Tab(text: "Lower Body"),
                            ],
                            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            indicatorColor: Theme.of(context).primaryColor,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 35.0),
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildExpressionTab(),
                                _buildUpperBodyColorTab(),
                                _buildLowerBodyColorTab(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Icon to toggle the collapsible section
                  IconButton(
                    icon: Icon(_isCustomizationVisible ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        _isCustomizationVisible = !_isCustomizationVisible;
                      });
                    },
                  ),
                ],
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

  Widget _buildExpressionTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Text("Expression", style: TextStyle(fontSize: 12)),
            Slider(
              value: _expressionValue,
              min: 0,
              max: 4,
              divisions: 4,
              label: _expressionValue.toString(),
              onChanged: (value) async {
                setState(() {
                  _expressionValue = value;
                });
                _callSetExpression();
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildUpperBodyColorTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            _buildColorSliders("Hue", _upperHueValue, 360, (value) async {
              setState(() {
                _upperHueValue = value;
              });
              _callSetColors();
            }),
            _buildColorSliders("Saturation", _upperSaturationValue, 100, (value) async {
              setState(() {
                _upperSaturationValue = value;
              });
              _callSetColors();
            }),
            _buildColorSliders("Lightness", _upperLightnessValue, 90, (value) async {
              setState(() {
                _upperLightnessValue = value;
              });
              _callSetColors();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLowerBodyColorTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            _buildColorSliders("Hue", _lowerHueValue, 360, (value) async {
              setState(() {
                _lowerHueValue = value;
              });
              _callSetColors();
            }),
            _buildColorSliders("Saturation", _lowerSaturationValue, 100, (value) async {
              setState(() {
                _lowerSaturationValue = value;
              });
              _callSetColors();
            }),
            _buildColorSliders("Lightness", _lowerLightnessValue, 90, (value) async {
              setState(() {
                _lowerLightnessValue = value;
              });
              _callSetColors();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSliders(String label, double value, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12)),
        Slider(
          value: value,
          min: 0,
          max: max,
          label: value.toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
