import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/new_build_screen.dart';
import '../screens/build_details_screen.dart';
import '../screens/build_logs_screen.dart';
import '../screens/result_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String newBuild = '/new-build';
  static const String buildDetails = '/build-details';
  static const String buildLogs = '/build-logs';
  static const String result = '/result';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    home: (_) => const HomeScreen(),
    newBuild: (_) => const NewBuildScreen(),
    settings: (_) => const SettingsScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case buildDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BuildDetailsScreen(jobId: args['jobId'] as String),
        );
      case buildLogs:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BuildLogsScreen(
            runId: args['runId'] as String,
            jobId: args['jobId'] as String,
          ),
        );
      case result:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ResultScreen(
            jobId: args['jobId'] as String,
            apkPath: args['apkPath'] as String?,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
