import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:emmet/widgets/app_bar/custom_app_bar.dart';
import 'package:emmet/widgets/app_bar/appbar_leading_image.dart';
import 'package:emmet/widgets/app_bar/appbar_title.dart';
import 'package:emmet/widgets/app_bar/appbar_subtitle.dart';
import 'package:emmet/widgets/custom_outlined_button.dart';
import 'package:emmet/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';
import 'package:flutter/rendering.dart';
import 'package:shimmer/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'lego_brick_code_generator.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ExploreScreen extends StatefulWidget {
  final List<String> recognizedTags;

  const ExploreScreen({Key? key, required this.recognizedTags}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();

}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Map<String, dynamic>> _sets = [];
  bool _isLoading = true; // Track loading state
  bool _isWebViewLoaded = false; // Track if WebView is loaded
  bool _isWebViewLoading = true; // Track WebView loading state
  int _currentIndex = 0; // To keep track of the selected tab

  String _modelName = ""; // Add this to store the model name
  String ldrawCodeFile = "";
  String setNum = "";
  String? geminiApiKey;

  late PageController _pageController;
  late WebViewController _webViewController; // Controller for the WebView
  late LegoBrickCodeGenerator _legoBrickCodeGenerator; // Controller instance

  GlobalKey _webViewKey = GlobalKey();
  bool _hasShownMissingApiKeyMessage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadSets();
    _getGeminiKey();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _getGeminiKey() async {
    final settings = await UserDatabaseHelper().getSettings();
    setState(() {
      geminiApiKey = settings['GeminiApiKey'];
    });

    // Initialize WebView controller after fetching the key
    if (geminiApiKey != null && geminiApiKey!.isNotEmpty) {
      _initializeWebViewController();
      _legoBrickCodeGenerator = LegoBrickCodeGenerator(geminiApiKey!);
    }
  }

  Future<void> _loadSets() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> sets = await dbHelper.fetchSetsByParts(widget.recognizedTags);

    setState(() {
      _sets = sets;
      _isLoading = false; // Stop loading when data is fetched
    });
  }

  void _initializeWebViewController() {
    // Ensure WebViewController is initialized only once
    if (!_isWebViewLoaded) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isWebViewLoading = false; // Stop loading when the page finishes loading
              _isWebViewLoaded = true; // Mark WebView as loaded
            });
          },
        ));
    }
  }

  // Helper method to handle code generation or modification
  Future<void> _handleLegoCode({
    required Future<Map<String, dynamic>> Function() codeOperation,
  }) async {
    if (_isWebViewLoaded) {
      // Skip regeneration if already loaded
      return;
    }

    setState(() {
      _isWebViewLoading = true; // Start WebView loading
    });

    try {
      // Await the response from the passed code operation (generate or modify)
      final response = await codeOperation();

      if (response['success']) {
        // Handle success response
        String generatedCode = response['generatedCode'];
        print('Generated Code: $generatedCode');

        // Define regex to capture everything between the first '0' and the last '.dat' before the closing backticks.
        final ldrRegex = RegExp(r"0(?:\s+.*\n)*(?:1\s+.*?\.(?:DAT|dat)\n?)*", dotAll: true);
        final ldrMatch = ldrRegex.firstMatch(generatedCode);

        if (ldrMatch != null) {
          ldrawCodeFile = ldrMatch.group(0)?.trim() ?? '';
          ldrawCodeFile = ldrawCodeFile.replaceAll('```', '');
          print('LDraw Code File: $ldrawCodeFile');
        } else {
          throw Exception("LDraw code file not found in the generated code.");
        }

        final nameRegex = RegExp(r"^0\s+Name:\s*(.*?)\s*$", multiLine: true);
        final nameMatch = nameRegex.firstMatch(generatedCode);
        String modelName = nameMatch?.group(1)?.trim() ?? '';

        // Remove the .ldr extension and convert to title case
        modelName = modelName.replaceAll('.ldr', '').split(' ').map((word) {
          return word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '';
        }).join(' ');

        setState(() {
          _modelName = modelName;
          setNum = 'SET${Random().nextInt(10000).toString().padLeft(5, '0')}';
        });

        // Load the WebView only if it hasn't been loaded
        if (!_isWebViewLoaded) {
          _webViewController
            ..loadRequest(Uri.parse('http://127.0.0.1:8080/buildinginstructions/preview.html'))
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageFinished: (url) {
                  // This is called when the page is fully loaded
                  _webViewController.runJavaScript('updateLDrawCode(`$ldrawCodeFile`);');
                },
              ),
            );
        }
      } else {
        // Handle failure response
        throw Exception(response['error']);
      }
    } catch (error) {
      print("Error generating/updating LEGO code: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating/updating LEGO code: $error")),
      );
    } finally {
      setState(() {
        _isWebViewLoading = false; // Stop WebView loading regardless of success or failure
      });
    }
  }

  // Modify LEGO code method using the helper function
  Future<void> _modifyLegoCode(String inputText) async {
    await _handleLegoCode(
      codeOperation: () => _legoBrickCodeGenerator.modifyCode(inputText, ldrawCodeFile),
    );
  }

  // Generate LEGO code method using the helper function
  Future<void> _generateOrUpdateLegoCode() async {
    await _handleLegoCode(
      codeOperation: () => _legoBrickCodeGenerator.generateCode(widget.recognizedTags),
    );
  }

  Future<void> _generateLegoCode() async {
    // Only generate code if the WebView has not been loaded yet
    if (!_isWebViewLoaded) {
      await _generateOrUpdateLegoCode();
    }
  }

  Future<void> _regenerateLegoCode() async {
    await _generateOrUpdateLegoCode();
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.all(5.h),
        height: 220.0,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }

  Widget _buildOfficialLEGOSetCard() {
    return _isLoading
        ? Column(
      children: List.generate(
        5, // Number of shimmer cards to display while loading
            (index) => Padding(
          padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
          child: _buildShimmerCard(),
        ),
      ),
    )
        : _sets.isEmpty
        ? Center(
      child: Text(
        "No LEGO sets found for the detected bricks.",
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    )
        : SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.h),
      child: Column(
        children: _sets
            .map((set) => Padding(
          padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
          child: _buildCard(context, set),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildGenerateSection() {
    return Stack(
      children: [
        // WebView or Shimmer loading widget
        _isWebViewLoading
            ? Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: MediaQuery.of(context).size.height, // Height of the WebView area
            width: double.infinity,
            color: Colors.grey[300],
          ),
        )
            : RepaintBoundary( // Wrap the WebView in a RepaintBoundary
          key: _webViewKey, // Assign the GlobalKey here
          child: ClipRRect(
            child: WebViewWidget(controller: _webViewController),
          ),
        ),

        // Floating model name box with loading text or actual model name
        Positioned(
          top: 40.0, // Adjust this value for vertical positioning
          left: 20.0, // Center horizontally by calculating offset
          right: 20.0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(238, 147, 34, 1),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Center(
              child: Text(
                _isWebViewLoading ? "Building Your LEGO Model, Please Hold..." : _modelName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(context),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            if (index == 1 && (geminiApiKey == null || geminiApiKey!.isEmpty)) {
              _pageController.jumpToPage(0); // Force back to the LEGO sets page
              if (!_hasShownMissingApiKeyMessage) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Generate tab is disabled because the Gemini API key is missing.'),
                  ),
                );
                _hasShownMissingApiKeyMessage = true; // Set the flag to true
              }
            } else {
              setState(() {
                _currentIndex = index;
                if (index == 1) {
                  _generateLegoCode(); // Generate code when switching to the "Generate" tab
                }
              });
            }
          },
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildOfficialLEGOSetCard(),
            _buildGenerateSection(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1 && (geminiApiKey == null || geminiApiKey!.isEmpty)) {
              if (!_hasShownMissingApiKeyMessage) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Generate tab is disabled because the Gemini API key is missing.'),
                  ),
                );
                _hasShownMissingApiKeyMessage = true; // Set the flag to true
              }
            } else {
              setState(() {
                _currentIndex = index;
                _pageController.jumpToPage(index);
              });
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.cube),
              label: 'LEGO Sets',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.wandMagicSparkles,
                color: _currentIndex == 1 ? Colors.red : null, // Disable color if current index is 1
              ),
              label: 'Generate',
            ),
          ],
        ),
        floatingActionButton: _currentIndex == 1 && geminiApiKey != null
            ? SpeedDial(
          backgroundColor: Color.fromRGBO(216, 63, 49, 1),
          foregroundColor: Colors.white,
          icon: Icons.menu,
          activeIcon: Icons.close,
          spacing: 10,
          children: [
            SpeedDialChild(
              child: FaIcon(FontAwesomeIcons.arrowsRotate),
              label: 'Regenerate',
              onTap: _regenerateLegoCode,
            ),
            SpeedDialChild(
              child: FaIcon(FontAwesomeIcons.pencil),
              label: 'Modify',
              onTap: _showModifyDialog,
            ),
            SpeedDialChild(
              child: FaIcon(FontAwesomeIcons.cube),
              label: 'Save',
              onTap: _saveGeneratedSet,
            ),
            SpeedDialChild(
              child: FaIcon(FontAwesomeIcons.solidCirclePlay),
              label: 'Build',
              onTap: () {
                buildGeneratedSet(context, setNum);
              },
            ),
          ],
        )
            : null,
      ),
    );
  }

  void _showModifyDialog() {
    TextEditingController inputController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modify LEGO Code'),
          content: TextField(
            controller: inputController,
            decoration: InputDecoration(
              hintText: 'Enter modification details',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String inputText = inputController.text.trim();
                if (inputText.isNotEmpty) {
                  _modifyLegoCode(inputText);
                  Navigator.of(context).pop(); // Dismiss the dialog after modifying
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> buildGeneratedSet(BuildContext context, String setNum) async {
    await _saveGeneratedSet();
    Navigator.pushNamed(context, AppRoutes.buildScreen, arguments: setNum);
  }

  Future<void> _saveGeneratedSet() async {
    // Capture the image from the WebView
    RenderRepaintBoundary boundary = _webViewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List imgData = byteData!.buffer.asUint8List();

    // Save to the database
    await UserDatabaseHelper().saveGeneratedSet(setNum, imgData, _modelName, ldrawCodeFile);

    // Provide feedback to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Set saved successfully: $setNum")),
    );
  }

  /// Top Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    int ideasCount = _sets.length;

    return CustomAppBar(
      leadingWidth: 54.h,
      leading: AppbarLeadingImage(
        imagePath: ImageConstant.imgArrowLeft,
        margin: EdgeInsets.only(left: 20.h, top: 20.v, bottom: 20.v),
        onTap: () {
          onTapArrowLeft(context);
        },
      ),
      centerTitle: true,
      title: Column(
        children: [
          AppbarTitle(text: "Explore"),
          AppbarSubtitle(
            text: "$ideasCount ideas found",
            margin: EdgeInsets.symmetric(horizontal: 3.h),
          ),
        ],
      ),
      styleType: Style.bgShadow,
    );
  }

  /// Save Button
  Widget _buildSave(BuildContext context, String setNum, String imgUrl) {
    return CustomOutlinedButton(
      width: 100.h,
      text: "Save",
      leftIcon: Container(
        margin: EdgeInsets.only(right: 7.h),
        child: CustomImageView(
          imagePath: ImageConstant.imgSave,
          height: 24.adaptSize,
          width: 24.adaptSize,
        ),
      ),
      onPressed: _currentIndex == 0 ? () {
        onTapSave(context, setNum, imgUrl); // Pass the imgUrl here
      } : null, // Disable if not in the current tab
    );
  }

  /// Build Button
  Widget _buildBuild(BuildContext context, String setNum) {
    return CustomElevatedButton(
      width: 103.h,
      text: "Build",
      margin: EdgeInsets.only(left: 7.h),
      leftIcon: Container(
        margin: EdgeInsets.only(right: 8.h),
        child: CustomImageView(
          imagePath: ImageConstant.imgBuild,
          height: 24.adaptSize,
          width: 24.adaptSize,
        ),
      ),
      onPressed: _currentIndex == 0 ? () {
        onTapBuild(context, setNum);
      } : null, // Disable if not in the current tab
    );
  }

  /// LEGO Set Card
  Widget _buildCard(BuildContext context, Map<String, dynamic> set) {
    return Container(
      margin: EdgeInsets.all(5.h),
      decoration: AppDecoration.outlineBlack9001
          .copyWith(borderRadius: BorderRadiusStyle.roundedBorder11),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              set['img_url'],
              height: 189.0,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
            ),
            SizedBox(height: 17.v),
            Padding(
              padding: EdgeInsets.only(left: 15.h),
              child: Text(
                set['name'],
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            SizedBox(height: 10.v),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 15.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSave(context, set['set_num'], set['img_url']),
                    SizedBox(width: 10), // Add some spacing
                    _buildBuild(context, set['set_num']),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15.v),
          ],
        ),
      ),
    );
  }

  void onTapBuild(BuildContext context, String setNum) {
    Navigator.pushNamed(context, AppRoutes.buildScreen, arguments: setNum);
  }

  void onTapSave(BuildContext context, String setNum, String imgUrl) async {
    UserDatabaseHelper dbHelper = UserDatabaseHelper();
    bool exists = await dbHelper.doesSetExist(setNum);

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('LEGO set $setNum already saved!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      await dbHelper.saveSet(setNum, imgUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('LEGO set $setNum saved!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void onTapArrowLeft(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Go back home or capture bricks?"),
          actions: <Widget>[
            TextButton(
              child: Text("Go Home"),
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
              },
            ),
            TextButton(
              child: Text("Capture Another"),
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.cameraScreen);
              },
            ),
          ],
        );
      },
    );
  }

}
