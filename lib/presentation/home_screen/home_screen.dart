import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:emmet/core/app_export.dart';
import 'package:emmet/widgets/bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int currentIndex = 0; // Added to track the active screen

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(horizontal: 23.h, vertical: 33.v),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomImageView(
                  imagePath: ImageConstant.imgELogo,
                  height: 60.adaptSize,
                  width: 60.adaptSize,
                ),
                SizedBox(height: 2.v),
                Text(
                  "Start Detecting!",
                  style: theme.textTheme.headlineLarge,
                ),
                SizedBox(height: 3.v),
                Text(
                  "Point, Explore, and Build!",
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: 20.v),
                _buildDetectButton(context),
                SizedBox(height: 5.v),
              ],
            ),
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


  Widget _buildDetectButton(BuildContext context) {
    return SizedBox(
      height: 313.adaptSize,
      width: 313.adaptSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(21.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(156.h),
                    gradient: LinearGradient(
                      begin: Alignment(0.5, 0),
                      end: Alignment(0.5, 1),
                      colors: [
                        appTheme.teal400.withOpacity(0 + (_animation.value * 0.2)),
                        theme.colorScheme.primary.withOpacity(0 + (_animation.value * 0.2)),
                      ],
                    ),
                  ),
                  child: Container(
                    height: 271.adaptSize,
                    width: 271.adaptSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(135.h),
                      gradient: LinearGradient(
                        begin: Alignment(0.5, 0),
                        end: Alignment(0.5, 1),
                        colors: [
                          appTheme.teal400.withOpacity(0.1 + (_animation.value * 0.3)),
                          theme.colorScheme.primary.withOpacity(0.1 + (_animation.value * 0.3)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () async {
                await onTapDetect(context);
              },
              child: Container(
                height: 216.adaptSize,
                width: 216.adaptSize,
                padding: EdgeInsets.symmetric(vertical: 42.v),
                decoration: AppDecoration.gradientYellowToPrimary.copyWith(
                  borderRadius: BorderRadiusStyle.circleBorder108,
                ),
                child: CustomImageView(
                  imagePath: ImageConstant.imgLegoButton,
                  height: 131.v,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onTapDetect(BuildContext context) async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showCameraUnavailableDialog(context);
      } else {
        Navigator.pushNamed(context, AppRoutes.cameraScreen);
      }
    } catch (e) {
      _showCameraUnavailableDialog(context);
    }
  }

  void _showCameraUnavailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Camera Unavailable"),
          content: Text("No cameras are available on this device."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

}


