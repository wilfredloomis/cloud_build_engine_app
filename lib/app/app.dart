import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'routes.dart';
import '../controllers/home_controller.dart';
import '../controllers/new_build_controller.dart';
import '../controllers/build_details_controller.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class CloudBuildApp extends StatelessWidget {
  const CloudBuildApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<LocalStorageService>(create: (_) => LocalStorageService()),
        ChangeNotifierProvider<HomeController>(
          create: (ctx) => HomeController(
            apiService: ctx.read<ApiService>(),
            storageService: ctx.read<LocalStorageService>(),
          ),
        ),
        ChangeNotifierProvider<NewBuildController>(
          create: (ctx) => NewBuildController(
            apiService: ctx.read<ApiService>(),
            storageService: ctx.read<LocalStorageService>(),
          ),
        ),
        ChangeNotifierProvider<BuildDetailsController>(
          create: (ctx) => BuildDetailsController(
            apiService: ctx.read<ApiService>(),
            storageService: ctx.read<LocalStorageService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Cloud Build Engine',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
