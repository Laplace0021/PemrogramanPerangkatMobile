import 'tour_package.dart';

class Booking {
  final TourPackage tour;
  final String name;
  final int participants;
  final DateTime date;

  const Booking({
    required this.tour,
    required this.name,
    required this.participants,
    required this.date,
  });

  int get total => tour.price * participants;
}