import 'package:emmet/presentation/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavigationBarWidget({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _BottomNavigationBarWidgetState createState() => _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    double navItemSize = isLandscape ? 50.adaptSize : 50.adaptSize; // Adjust size for landscape

    return Container(
        color: Color.fromRGBO(255, 255, 182, 1),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isLandscape ? 200.h: 23.h, vertical: isLandscape ? 10.v: 10.v),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                ImageConstant.imgHomeOutlined,
                ImageConstant.imgHomeFilled,
                "Home",
                0,
                navItemSize,
                !isLandscape, // Show label only in portrait
              ),
              _buildNavItem(
                context,
                ImageConstant.imgCapturesOutlined,
                ImageConstant.imgCapturesFilled,
                "Recent Captures",
                1,
                navItemSize,
                !isLandscape, // Show label only in portrait
              ),
              _buildNavItem(
                context,
                ImageConstant.imgCreativeOutlined,
                ImageConstant.imgCreativeFilled,
                "Creative Mode",
                2,
                navItemSize,
                !isLandscape, // Show label only in portrait
              ),
              _buildNavItem(
                context,
                ImageConstant.imgMinifigureOutlined,
                ImageConstant.imgMinifigureFilled,
                "Minifigure Creator",
                3,
                navItemSize,
                !isLandscape, // Show label only in portrait
              ),
              _buildNavItem(
                context,
                ImageConstant.imgSettingsOutlined,
                ImageConstant.imgSettingsFilled,
                "Settings",
                4,
                navItemSize,
                !isLandscape, // Show label only in portrait
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildNavItem(
      BuildContext context, String imagePathOutlined, String imagePathFilled, String label, int index, double size, bool showLabel) {
    bool isActive = index == widget.currentIndex;

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          widget.onTap(index);
          _onTapNavItem(context, index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: size,
            width: size,
            padding: EdgeInsets.all(10.h),
            decoration: BoxDecoration(
              border: Border.all(color: isActive ? Color.fromRGBO(33, 156, 144, 1) : Colors.transparent),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1.0, end: isActive ? 1.2 : 1.0),
              duration: Duration(milliseconds: 300),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: CustomImageView(
                    imagePath: isActive ? imagePathFilled : imagePathOutlined,
                  ),
                );
              },
            ),
          ),
          if (showLabel)
            AnimatedOpacity(
              opacity: isActive ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Padding(
                padding: EdgeInsets.only(top: 5.v),
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onTapNavItem(BuildContext context, int index) {
    if (index == widget.currentIndex) return; // No need to animate to the current screen.

    String routeName;
    switch (index) {
      case 0:
        routeName = AppRoutes.homeScreen;
        break;
      case 1:
        routeName = AppRoutes.capturesScreen;
        break;
      case 2:
        routeName = AppRoutes.creativeScreen;
        break;
      case 3:
        routeName = AppRoutes.minifigureScreen;
        break;
      case 4:
        routeName = AppRoutes.settingsScreen;
        break;

      default:
        routeName = AppRoutes.homeScreen; // Default fallback.
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // Retrieve the WidgetBuilder from routes or fallback to HomeScreen.
          final WidgetBuilder? builder = AppRoutes.routes[routeName];
          return builder != null ? builder(context) : HomeScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = 0.0;
          var end = 1.0;
          var curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return FadeTransition(
            opacity: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

}

