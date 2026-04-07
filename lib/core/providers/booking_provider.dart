import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/booking_repository.dart';

class Booking {
  final String jobId;
  final String date;
  final List<Map<String, dynamic>> passengers;
  final Map<String, dynamic> routeContext;
  final bool waitForReturn;
  final String status;
  final String? driverId;

  Booking({
    required this.jobId,
    required this.date,
    required this.passengers,
    required this.routeContext,
    required this.waitForReturn,
    this.status = 'pending',
    this.driverId,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      jobId: json['job_id'] as String,
      date: json['date'] as String,
      passengers: List<Map<String, dynamic>>.from(json['passengers']),
      routeContext: Map<String, dynamic>.from(json['route_context']),
      waitForReturn: json['wait_for_return'] as bool? ?? false,
      status: json['status'] as String? ?? 'pending',
      driverId: json['driver_id'] as String?,
    );
  }

  factory Booking.fromFirestore(Map<String, dynamic> data) {
    return Booking(
      jobId: data['job_id'] as String? ?? '',
      date: data['date_string'] as String? ?? '',
      passengers: List<Map<String, dynamic>>.from(data['passengers'] ?? []),
      routeContext: Map<String, dynamic>.from(data['route_context'] ?? {}),
      waitForReturn: data['wait_for_return'] as bool? ?? false,
      status: data['status'] as String? ?? 'pending',
      driverId: data['driver_id'] as String?,
    );
  }
}

final bookingRepositoryProvider = Provider((ref) => BookingRepository());

// StreamProvider for real-time bookings
final bookingsProvider = StreamProvider<List<Booking>>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getBookingsStream();
});
