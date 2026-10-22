import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/tour_package.dart';
import '../services/app_state.dart';
import 'booking_screen.dart';
import 'home_screen.dart' show formatRupiah;

class DetailScreen extends StatelessWidget {
  final TourPackage tour;
  const DetailScreen({super.key, required this.tour});

  Future<void> _book(BuildContext context) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => BookingScreen(tour: tour)),
    );

    if (result != null && context.mounted) {
      AppState.addBooking(Booking(
        tour: tour,
        name: result['name'] as String,
        participants: result['participants'] as int,
        date: result['date'] as DateTime,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0D7C66),
          content: Text(
              'Pemesanan berhasil! ${result['name']} (${result['participants']} orang)'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tour.title),
        actions: [
          ValueListenableBuilder<Set<String>>(
            valueListenable: AppState.favoriteIds,
            builder: (_, ids, __) {
              final fav = ids.contains(tour.id);
              return IconButton(
                icon: Icon(
                  fav ? Icons.favorite : Icons.favorite_border,
                  color: fav ? const Color(0xFFDC2626) : null,
                ),
                onPressed: () => AppState.toggleFavorite(tour.id),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              tour.imageUrl,
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 240,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tour.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${formatRupiah(tour.price)} / orang',
                      style: const TextStyle(
                          fontSize: 18, color: Color(0xFF0D7C66))),
                  const SizedBox(height: 16),
                  Text(tour.description,
                      style: const TextStyle(fontSize: 15, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            onPressed: () => _book(context),
            child: const Text('Pesan Sekarang'),
          ),
        ),
      ),
    );
  }
}