import 'package:flutter/material.dart';
import '../models/tour_package.dart';
import '../routes/app_routes.dart';
import '../services/app_state.dart';
import 'favorite_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

const List<TourPackage> tourPackages = [
  TourPackage(
    id: '1',
    title: 'Raja Ampat',
    description:
        'Snorkeling dan diving di surga bawah laut Papua Barat dengan gugusan pulau karst yang memukau.',
    price: 8500000,
    imageUrl: 'https://picsum.photos/seed/rajaampat/800/500',
  ),
  TourPackage(
    id: '2',
    title: 'Bromo & Ijen',
    description:
        'Menikmati sunrise di Penanjakan, lautan pasir Bromo, dan blue fire kawah Ijen.',
    price: 2500000,
    imageUrl: 'https://picsum.photos/seed/bromo/800/500',
  ),
  TourPackage(
    id: '3',
    title: 'Labuan Bajo (Komodo)',
    description:
        'Sailing trip melihat komodo, Pink Beach, dan Pulau Padar di Nusa Tenggara Timur.',
    price: 5200000,
    imageUrl: 'https://picsum.photos/seed/komodo/800/500',
  ),
  TourPackage(
    id: '4',
    title: 'Ubud, Bali',
    description:
        'Sawah terasering Tegallalang, Monkey Forest, dan wisata budaya khas Ubud.',
    price: 3100000,
    imageUrl: 'https://picsum.photos/seed/ubud/800/500',
  ),
];

String formatRupiah(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

String formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

/// Shell dengan bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _pages = [
    HomeTab(),
    HistoryScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_index != 0) {
          // Riwayat / Favorit / Profil -> Beranda
          setState(() => _index = 0);
        } else {
          // Beranda -> Splash
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.splash,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Riwayat',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorit',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  Future<void> _logout(BuildContext context) async {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paket Wisata'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Halo, ${AppState.userName} 👋',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Mau jelajah ke mana hari ini?'),
          const SizedBox(height: 16),
          for (final tour in tourPackages) TourCard(tour: tour),
        ],
      ),
    );
  }
}

/// Kartu paket wisata, dipakai di Beranda dan Favorit.
class TourCard extends StatelessWidget {
  final TourPackage tour;
  const TourCard({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.detail, arguments: tour),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  tour.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: ValueListenableBuilder<Set<String>>(
                    valueListenable: AppState.favoriteIds,
                    builder: (_, ids, __) {
                      final fav = ids.contains(tour.id);
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 22,
                          icon: Icon(
                            fav ? Icons.favorite : Icons.favorite_border,
                            color: fav
                                ? const Color(0xFFDC2626)
                                : Colors.grey.shade700,
                          ),
                          onPressed: () => AppState.toggleFavorite(tour.id),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tour.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Mulai ${formatRupiah(tour.price)} / orang',
                      style: const TextStyle(color: Color(0xFF0D7C66))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}