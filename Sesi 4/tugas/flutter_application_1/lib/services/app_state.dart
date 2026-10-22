import 'package:flutter/foundation.dart';
import '../models/booking.dart';

class AppState {
  // Data user di-hardcode, ubah di sini saja.
  static const String userName = 'Ahmad';
  static const String userEmail = 'ahmad@nusatravel.id';
  static const String userPhone = '0812-3456-7890';

  static final ValueNotifier<Set<String>> favoriteIds = ValueNotifier({});
  static final ValueNotifier<List<Booking>> bookings = ValueNotifier([]);

  static void toggleFavorite(String id) {
    final next = {...favoriteIds.value};
    if (!next.add(id)) next.remove(id);
    favoriteIds.value = next; // objek baru agar listener terpanggil
  }

  static void addBooking(Booking b) {
    bookings.value = [b, ...bookings.value];
  }
}