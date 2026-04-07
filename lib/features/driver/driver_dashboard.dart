import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/booking_provider.dart';
import 'job_details_screen.dart';

class DriverDashboard extends ConsumerWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(userProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Active Jobs",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: bookingsAsync.when(
                data: (bookings) => ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    
                    return _jobCard(
                      context,
                      ref: ref,
                      booking: booking,
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error loading bookings: $err")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _jobCard(
    BuildContext context, {
    required WidgetRef ref,
    required Booking booking,
  }) {
    final user = ref.watch(userProvider);
    final isMyJob = booking.driverId == user.uid;
    final isPending = booking.status == 'pending';
    
    final joining = booking.passengers.where((p) => p['type'] == 'Joining').firstOrNull;
    final departing = booking.passengers.where((p) => p['type'] == 'Departing').firstOrNull;
    final passenger = joining?['name'] ?? departing?['name'] ?? "Unknown";
    final route = "${booking.routeContext['pickup_loc']} -> ${booking.routeContext['drop_loc']}";
    final tripType = booking.waitForReturn ? "Wait and Return" : "Single Trip";
    final time = joining?['flight_time'] ?? "N/A";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Job #${booking.jobId}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusTextColor(booking.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(passenger),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.map, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(route),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(tripType),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(time),
              ],
            ),
            const SizedBox(height: 16),
            if (isPending)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (user.uid == null) return;
                    await ref.read(bookingRepositoryProvider).acceptJob(booking.jobId, user.uid!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Job #${booking.jobId} Accepted!")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text("Accept Job"),
                ),
              )
            else if (isMyJob)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailsScreen(booking: booking),
                      ),
                    );
                  },
                  child: const Text("View Details / Navigate"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.grey[200]!;
      case 'accepted': return Colors.green[100]!;
      case 'completed': return Colors.blue[100]!;
      default: return Colors.orange[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'pending': return Colors.grey[800]!;
      case 'accepted': return Colors.green[900]!;
      case 'completed': return Colors.blue[900]!;
      default: return Colors.orange[900]!;
    }
  }
}
