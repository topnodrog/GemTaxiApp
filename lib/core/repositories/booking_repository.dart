import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../providers/booking_provider.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'gemdb');

  Stream<List<Booking>> getBookingsStream() {
    return _firestore
        .collection('bookings')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Booking.fromFirestore(data);
      }).toList();
    });
  }

  Future<void> acceptJob(String jobId, String driverId) async {
    await _firestore.collection('bookings').doc(jobId).update({
      'status': 'accepted',
      'driver_id': driverId,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    await _firestore.collection('bookings').doc(jobId).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createBooking(Booking booking) async {
    await _firestore.collection('bookings').doc(booking.jobId).set({
      'job_id': booking.jobId,
      'date_string': booking.date,
      'passengers': booking.passengers,
      'route_context': booking.routeContext,
      'wait_for_return': booking.waitForReturn,
      'status': booking.status,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
