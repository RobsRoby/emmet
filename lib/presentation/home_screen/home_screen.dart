import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:emmet/core/app_export.dart';
import 'package:emmet/widgets/bottom_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int currentIndex = 0;

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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () => _showOnboardingCarousel(context),
                  child: Icon(Icons.help_outline),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  highlightElevation: 0,
                  tooltip: 'Onboarding Guide',
                ),
              ),
            ],
          ),
        ),
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

  void _showOnboardingCarousel(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Disable dismiss on tap outside
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
          ),
          child: CarouselOnboarding(),
        );
      },
    );
  }

}

class CarouselOnboarding extends StatefulWidget {
  @override
  _CarouselOnboardingState createState() => _CarouselOnboardingState();
}

class _CarouselOnboardingState extends State<CarouselOnboarding> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> onboardingPages = [
    {
      'title': 'Welcome to EMMET!',
      'content': 'Point, Explore, Build! Navigate EMMET with ease using this quick guide.',
      'image': ImageConstant.imgLogo, // Assuming this is not SVG
    },
    {
      'title': 'Home',
      'content': 'Find the “EMMET” button to start brick detection and explore LEGO set suggestions.',
      'image': ImageConstant.imgLegoButton, // Assuming this is not SVG
    },
    {
      'title': 'Captures',
      'content': 'Access all your saved builds in one place. Save or delete any captured set.',
      'image': ImageConstant.imgCapturesFilled, // SVG Image
    },
    {
      'title': 'Creative Mode',
      'content': 'Enter Free Build mode by rotating your phone to Landscape. Build freely!',
      'image': ImageConstant.imgCreativeFilled, // SVG Image
    },
    {
      'title': 'Minifigure Maker',
      'content': 'Customize minifigures and save your creations for future reference.',
      'image': ImageConstant.imgMinifigureFilled, // SVG Image
    },
    {
      'title': 'Settings',
      'content': 'Adjust detection sensitivity and other preferences to personalize your EMMET experience.',
      'image': ImageConstant.imgSettingsFilled, // SVG Image
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 350, // Adjusted to fit image and text
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: onboardingPages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    onboardingPages[index]['image']?.endsWith('.svg') ?? false
                        ? SvgPicture.asset(
                      onboardingPages[index]['image'],
                      height: 80, // Adjust size as needed
                    )
                        : Image.asset(
                      onboardingPages[index]['image'],
                      height: 80, // Adjust size as needed
                    ),
                    SizedBox(height: 16),
                    Text(
                      onboardingPages[index]['title']!,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text(
                      onboardingPages[index]['content']!,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            onboardingPages.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index ? Color.fromRGBO(33, 156, 144, 1) : Colors.grey,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Skip", style: TextStyle(fontSize: 14)),
              ),
              ElevatedButton(
                onPressed: _currentIndex == onboardingPages.length - 1
                    ? () => Navigator.of(context).pop()
                    : () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(_currentIndex == onboardingPages.length - 1 ? "Done" : "Next", style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
