import 'package:flutter/material.dart';

import 'screens/home_events_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NusaEventApp());
}

class NusaEventApp extends StatelessWidget {
  const NusaEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NusaEvent Hub',
      debugShowCheckedModeBanner: false,
      theme: NusaEventTheme.lightTheme,
      darkTheme: NusaEventTheme.darkTheme,
      home: const HomeEventsScreen(),
    );
  }
}
