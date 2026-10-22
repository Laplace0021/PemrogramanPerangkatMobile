import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class NotFoundScreen extends StatelessWidget {
  final String routeName;
  const NotFoundScreen({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFDC2626);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('404',
                  style: TextStyle(
                      fontSize: 72, fontWeight: FontWeight.bold, color: red)),
              const SizedBox(height: 8),
              const Text('Halaman tidak ditemukan',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Rute "$routeName" tidak terdaftar.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.home, (route) => false),
                child: const Text('Kembali ke Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}