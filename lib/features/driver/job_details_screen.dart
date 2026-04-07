import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/booking_provider.dart';

class JobDetailsScreen extends StatelessWidget {
  final Booking booking;

  const JobDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final joining = booking.passengers.where((p) => p['type'] == 'Joining').firstOrNull;
    final departing = booking.passengers.where((p) => p['type'] == 'Departing').firstOrNull;
    final passengerName = joining?['name'] ?? departing?['name'] ?? "Unknown Passenger";
    final flightTime = joining?['flight_time'] ?? departing?['flight_time'] ?? "N/A";
    final isWaitAndReturn = booking.waitForReturn;

    return Scaffold(
      appBar: AppBar(
        title: Text("Job #${booking.jobId}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader("Passenger Details"),
            _buildDetailRow(Icons.person, "Name", passengerName),
            _buildDetailRow(Icons.phone, "Contact", joining?['phone'] ?? departing?['phone'] ?? "N/A"),
            const SizedBox(height: 24),

            _buildSectionHeader("Trip Details"),
            _buildDetailRow(Icons.my_location, "Pickup", booking.routeContext['pickup_loc'] ?? "Unknown"),
            _buildDetailRow(Icons.location_on, "Drop-off", booking.routeContext['drop_loc'] ?? "Unknown"),
            _buildDetailRow(Icons.access_time, "Flight Time", flightTime),
            if (isWaitAndReturn)
              _buildDetailRow(Icons.loop, "Type", "Wait and Return"),
            const SizedBox(height: 24),
            
            _buildSectionHeader("Status & Actions"),
            _buildStatusChip(booking.status),
            const SizedBox(height: 32),

            // Mock Actions
            ElevatedButton.icon(
              onPressed: () {
                // Future expansion: Launch Maps intent here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigation starting soon...')),
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text("Navigate to Pickup"),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 12),
            if (booking.status != 'completed')
              Consumer(
                builder: (context, ref, child) {
                  return OutlinedButton(
                    onPressed: () async {
                        final repository = ref.read(bookingRepositoryProvider);
                        final newStatus = booking.status == 'accepted' ? 'picked_up' : 'completed';
                        
                        try {
                          await repository.updateJobStatus(booking.jobId, newStatus);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Status updated to $newStatus')),
                            );
                          }
                        } catch (e) {
                           if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                    },
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    child: Text(booking.status == 'accepted' ? "Mark as Picked Up" : "Mark as Completed"),
                  );
                }
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
     Color bgColor;
     Color textColor;
     
     switch (status) {
      case 'pending': 
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[800]!;
        break;
      case 'accepted': 
        bgColor = Colors.green[100]!;
        textColor = Colors.green[900]!;
        break;
      case 'completed': 
        bgColor = Colors.blue[100]!;
        textColor = Colors.blue[900]!;
        break;
      default: 
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
    }
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(
          status.toUpperCase(),
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: bgColor,
      ),
    );
  }
}
