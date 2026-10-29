import 'package:flutter/material.dart';

/// Kategori seminar beserta label, ikon, dan warna identitasnya.
enum EventCategory {
  ai('AI', Icons.psychology, Color(0xFF6366F1)),
  mobile('Mobile', Icons.smartphone, Color(0xFF0D9488)),
  iot('IoT', Icons.sensors, Color(0xFFEA580C)),
  cybersecurity('Cybersecurity', Icons.security, Color(0xFFDC2626));

  const EventCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// Data satu seminar / workshop.
class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.speaker,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.time,
    required this.location,
    required this.quota,
    required this.registered,
    required this.price,
    required this.description,
    this.skp = 2,
    this.posterAsset,
  });

  final String id;
  final String title;
  final String speaker;
  final EventCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final String time;
  final String location;

  /// Total kursi yang tersedia untuk acara ini.
  final int quota;

  /// Jumlah kursi yang sudah terisi sebelum pendaftaran dari aplikasi ini.
  final int registered;

  /// Harga tiket dalam rupiah (0 = gratis).
  final int price;
  final String description;

  /// Poin SKP Mandiri untuk peserta.
  final int skp;

  /// Path asset poster acara (jika ada).
  final String? posterAsset;

  bool get isFree => price == 0;

  String get skpLabel => '$skp SKP Mandiri';

  String get dateLabel => startDate == endDate
      ? formatDate(startDate)
      : '${formatDate(startDate)} – ${formatDate(endDate)}';

  String get priceLabel => isFree ? 'Gratis' : formatRupiah(price);
}

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Contoh: 12 Nov 2026.
String formatDate(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

/// Contoh: Rp75.000.
String formatRupiah(int value) {
  if (value == 0) return 'Rp 0';
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return 'Rp $buffer';
}
