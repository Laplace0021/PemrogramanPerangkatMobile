import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Logout',
                  style: TextStyle(color: Color(0xFFDC2626)))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.splash, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0D7C66);
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: primary,
              child: Icon(Icons.person, size: 56, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(AppState.userName,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          const ListTile(
            leading: Icon(Icons.email_outlined),
            title: Text(AppState.userEmail),
          ),
          const ListTile(
            leading: Icon(Icons.phone_outlined),
            title: Text(AppState.userPhone),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
                    const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () => Navigator.pushNamed(context, '/error'),
            icon: const Icon(Icons.error_outline),
            label: const Text('Uji Error 404'),
          ),
        ],
      ),
    );
  }
}