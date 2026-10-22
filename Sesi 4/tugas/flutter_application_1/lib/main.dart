import 'package:flutter/material.dart';
import 'models/tour_package.dart';
import 'routes/app_routes.dart';
import 'screens/detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const NusaTravelApp());

class NusaTravelApp extends StatelessWidget {
  const NusaTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NusaTravel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D7C66)),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
      },
      // Detail needs arguments, so it is handled here.
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.detail) {
          final args = settings.arguments;
          if (args is TourPackage) {
            return MaterialPageRoute(
              builder: (_) => DetailScreen(tour: args),
              settings: settings,
            );
          }
        }
        return null; // falls through to onUnknownRoute
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => NotFoundScreen(routeName: settings.name ?? '-'),
        settings: const RouteSettings(name: AppRoutes.notFound),
      ),
    );
  }
}