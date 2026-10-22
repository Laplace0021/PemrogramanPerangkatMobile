import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/app_state.dart';
import 'home_screen.dart' show formatRupiah, formatDate;

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pemesanan')),
      body: ValueListenableBuilder<List<Booking>>(
        valueListenable: AppState.bookings,
        builder: (_, list, __) {
          if (list.isEmpty) {
            return const Center(child: Text('Belum ada pemesanan'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final b = list[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      b.tour.imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                  title: Text(b.tour.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${b.name} • ${b.participants} orang\nBerangkat ${formatDate(b.date)}'),
                  isThreeLine: true,
                  trailing: Text(formatRupiah(b.total),
                      style: const TextStyle(
                          color: Color(0xFF0D7C66),
                          fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}