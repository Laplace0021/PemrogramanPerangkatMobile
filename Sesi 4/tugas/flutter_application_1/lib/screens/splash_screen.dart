import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0D7C66);
    return Scaffold(
      backgroundColor: primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 56,
              backgroundColor: Colors.white,
              child: Icon(Icons.explore, size: 64, color: primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'NusaTravel',
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text('Jelajahi keindahan Nusantara',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8A838),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.home),
              child: const Text('Mulai Eksplorasi'),
            ),
          ],
        ),
      ),
    );
  }
}