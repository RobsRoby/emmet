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

    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        color: Color.fromRGBO(255, 255, 182, 1),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isLandscape ? 200.h: 50.h, vertical: isLandscape ? 15.v: 26.v),
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
                ImageConstant.imgSettingsOutlined,
                ImageConstant.imgSettingsFilled,
                "Settings",
                2,
                navItemSize,
                !isLandscape, // Show label only in portrait
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, String imagePathOutlined, String imagePathFilled, String label, int index, double size, bool showLabel) {
    bool isActive = index == widget.currentIndex;

    return GestureDetector(
      onTap: () {
        widget.onTap(index);
        _onTapNavItem(context, index);
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
            child: CustomImageView(
              imagePath: isActive ? imagePathFilled : imagePathOutlined,
            ),
          ),
          if (showLabel) // Conditionally show label
            Padding(
              padding: EdgeInsets.only(top: 5.v),
              child: Text(
                label,
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  void _onTapNavItem(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.capturesScreen);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.settingsScreen);
        break;
    }
  }

}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0);
    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, 10);
    var secondControlPoint = Offset(size.width * 3 / 4, 20);
    var secondEndPoint = Offset(size.width, 10);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 60);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}



