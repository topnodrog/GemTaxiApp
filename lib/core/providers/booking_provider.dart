import 'package:flutter_riverpod/flutter_riverpod.dart';

class Booking {
  final String jobId;
  final String date;
  final List<Map<String, dynamic>> passengers;
  final Map<String, dynamic> routeContext;
  final bool waitForReturn;

  Booking({
    required this.jobId,
    required this.date,
    required this.passengers,
    required this.routeContext,
    required this.waitForReturn,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      jobId: json['job_id'] as String,
      date: json['date'] as String,
      passengers: List<Map<String, dynamic>>.from(json['passengers']),
      routeContext: Map<String, dynamic>.from(json['route_context']),
      waitForReturn: json['wait_for_return'] as bool? ?? false,
    );
  }
}

// For now, we use a mock provider that simulates fetching from the automation JSON
final bookingsProvider = FutureProvider<List<Booking>>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));
  
  // This is a mock implementation. In a production app, we'd use an API 
  // or Firebase to read the data updated by the Python script.
  return [
    Booking(
      jobId: "2104",
      date: "Sunday, January 4",
      waitForReturn: true,
      passengers: [
        {"type": "Joining", "name": "Dustin Gaulton", "phone": "(709) 325-6011", "flight_time": "AC603 0846"},
        {"type": "Departing", "name": "Ryan Pernites", "phone": "(905) 699-2864", "address": "262 Greenfield Lane, Chatham, ON"}
      ],
      routeContext: {
        "pickup_name": "Dustin",
        "pickup_loc": "Toronto airport",
        "drop_loc": "Lois M",
        "drop_city": "Hamilton"
      },
    )
  ];
});
