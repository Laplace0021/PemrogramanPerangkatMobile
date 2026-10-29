import 'event_item.dart';

/// Tiket hasil pendaftaran seorang peserta pada satu [EventItem].
class RegistrationTicket {
  const RegistrationTicket({
    required this.id,
    required this.event,
    required this.name,
    required this.nim,
    required this.email,
    required this.whatsapp,
    required this.participantType,
    required this.attendanceDate,
    required this.kitPackage,
    required this.donation,
    required this.total,
    required this.createdAt,
  });

  final String id;
  final EventItem event;
  final String name;
  final String nim;
  final String email;
  final String whatsapp;
  final String participantType;
  final DateTime attendanceDate;
  final String kitPackage;

  /// Donasi sukarela dalam rupiah.
  final int donation;

  /// Total bayar = harga tiket + seminar kit + donasi.
  final int total;
  final DateTime createdAt;

  /// Kode tiket singkat, contoh: NEH-1234-E2.
  String get code =>
      'NEH-${nim.substring(nim.length - 4)}-${event.id.toUpperCase()}';
}
