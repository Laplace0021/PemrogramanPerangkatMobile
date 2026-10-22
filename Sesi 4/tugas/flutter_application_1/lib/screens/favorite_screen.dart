import 'package:flutter/material.dart';
import '../services/app_state.dart';
import 'home_screen.dart' show tourPackages, TourCard;

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit')),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: AppState.favoriteIds,
        builder: (_, ids, __) {
          final favs = tourPackages.where((t) => ids.contains(t.id)).toList();
          if (favs.isEmpty) {
            return const Center(
                child: Text('Belum ada paket favorit.\nTekan ♥ pada paket wisata.',
                    textAlign: TextAlign.center));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [for (final t in favs) TourCard(tour: t)],
          );
        },
      ),
    );
  }
}