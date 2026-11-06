import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/post_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: const NusaInfoApp(),
    ),
  );
}

class NusaInfoApp extends StatelessWidget {
  const NusaInfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nusa Info',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000), // True Pitch Black khas X
        primaryColor: const Color(0xFF1D9BF0), // X Accent Blue
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1D9BF0),
          secondary: Color(0xFF1D9BF0),
          surface: Color(0xFF000000),
          surfaceContainerHighest: Color(0xFF16181C),
          onSurface: Color(0xFFE7E9EA),
          outline: Color(0xFF2F3336),
        ),
        dividerColor: const Color(0xFF2F3336),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000000),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFFE7E9EA)),
          titleTextStyle: TextStyle(
            color: Color(0xFFE7E9EA),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
