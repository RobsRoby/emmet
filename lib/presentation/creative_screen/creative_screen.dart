import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emmet/widgets/bottom_navigation_bar.dart';
import 'package:emmet/core/app_export.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreativeScreen extends StatefulWidget {
  CreativeScreen({Key? key}) : super(key: key);

  @override
  _CreativeScreenState createState() => _CreativeScreenState();
}

class _CreativeScreenState extends State<CreativeScreen> {
  int currentIndex = 2;
  bool _isBottomNavBarVisible = true;
  bool _isDKeyPressed = false;

  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  Future<void> _initializeWebViewController() async {
    _webViewController = WebViewController()
      ..loadRequest(Uri.parse('http://127.0.0.1:8080/brick_builder/index.html'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    setState(() {});
  }

  void _toggleBottomNavBar() {
    setState(() {
      _isBottomNavBarVisible = !_isBottomNavBarVisible;
    });
  }

  void _simulateDKeyPress() {
    _webViewController?.runJavaScript(
        "var eventDown = new KeyboardEvent('keydown', {key: 'd', code: 'KeyD', keyCode: 68, which: 68, bubbles: true});"
            "var eventUp = new KeyboardEvent('keyup', {key: 'd', code: 'KeyD', keyCode: 68, which: 68, bubbles: true});"
            "document.body.dispatchEvent(eventDown);"
    );
  }

  void _stopSimulatingDKey() {
    _webViewController?.runJavaScript(
        "var eventUp = new KeyboardEvent('keyup', {key: 'd', code: 'KeyD', keyCode: 68, which: 68, bubbles: true});"
            "document.body.dispatchEvent(eventUp);"
    );
  }

  void _startSimulatingDKey() {
    if (_isDKeyPressed) {
      _simulateDKeyPress();
      Future.delayed(Duration(milliseconds: 100), () {
        if (_isDKeyPressed) {
          _startSimulatingDKey();
        } else {
          _stopSimulatingDKey();
        }
      });
    }
  }

  void _simulateRKeyPress() {
    _webViewController?.runJavaScript(
        "var eventDown = new KeyboardEvent('keydown', {key: 'r', code: 'KeyR', keyCode: 82, which: 82, bubbles: true});"
            "var eventUp = new KeyboardEvent('keyup', {key: 'r', code: 'KeyR', keyCode: 82, which: 82, bubbles: true});"
            "document.body.dispatchEvent(eventDown);"
    );
    Future.delayed(Duration(milliseconds: 100), () {
      _webViewController?.runJavaScript(
          "var eventUp = new KeyboardEvent('keyup', {key: 'r', code: 'KeyR', keyCode: 82, which: 82, bubbles: true});"
              "document.body.dispatchEvent(eventUp);"
      );
    });
  }

  Widget _buildShimmerTile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _webViewController == null
                      ? Center(child: CircularProgressIndicator())
                      : WebViewWidget(controller: _webViewController!),
                ),
              ],
            ),

            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _toggleBottomNavBar,
                backgroundColor: Colors.transparent,
                elevation: 0,
                highlightElevation: 0,
                child: Icon(
                  _isBottomNavBarVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.red,
                ),
              ),
            ),

            // Positioned two floating buttons (Delete and Rotate) vertically centered
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 100, // Center vertically
              left: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Delete Switch with icon
                  Column(
                    children: [
                      Text(
                        'Delete',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: _isDKeyPressed,
                        onChanged: (bool value) {
                          setState(() {
                            _isDKeyPressed = value;
                          });
                          if (_isDKeyPressed) {
                            _startSimulatingDKey();
                          } else {
                            _stopSimulatingDKey();
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10), // Add space between the buttons
                  // Rotate button with FontAwesome icon
                  FloatingActionButton(
                    onPressed: () {
                      _simulateRKeyPress();
                    },
                    backgroundColor: Colors.red,
                    child: FaIcon(
                      FontAwesomeIcons.arrowRotateRight,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Visibility(
          visible: _isBottomNavBarVisible,
          child: BottomNavigationBarWidget(
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
