import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/permission_screen/permission_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/camera_screen/camera_screen_mobile.dart'
if (dart.library.html) '../presentation/camera_screen/camera_screen_web.dart';
import '../presentation/explore_screen/explore_screen.dart';
import '../presentation/build_screen/build_screen.dart';
import '../presentation/captures_screen/captures_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';

class AppRoutes {
  static const String splashScreen = '/splash_screen';
  static const String permissionScreen = '/permission_screen';
  static const String homeScreen = '/home_screen';
  static const String cameraScreen = '/camera_screen';
  static const String exploreScreen = '/explore_screen';
  static const String buildScreen = '/build_screen';
  static const String capturesScreen = '/captures_screen';
  static const String settingsScreen = '/settings_screen';

  static Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => SplashScreen(),
    permissionScreen: (context) => PermissionScreen(),
    homeScreen: (context) => HomeScreen(),
    cameraScreen: (context) => CameraScreen(),
    capturesScreen: (context) => CapturesScreen(),
    settingsScreen: (context) => SettingsScreen(),
    // Remove buildScreen entry from here, it will be handled by onGenerateRoute
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case exploreScreen:
        final List<String> recognizedTags = settings.arguments as List<String>;
        return MaterialPageRoute(
          builder: (context) => ExploreScreen(recognizedTags: recognizedTags),
        );

      case buildScreen:
        final String setNum = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => BuildScreen(setNum: setNum),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => HomeScreen(),
        );
    }
  }
}
