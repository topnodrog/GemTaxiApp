import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/theme.dart';
import '../../core/services/location_service.dart';
import '../../core/providers/booking_provider.dart';

// Simple State Provider for Booking Status
// In a real app, this would be a full NotifierProvider
enum BookingStage { idle, pickingLocation, confirming, searching, onRide }

final bookingStageProvider = StateProvider<BookingStage>((ref) => BookingStage.idle);

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationService _locationService = LocationService();
  
  // Burlington Coordinates
  static const CameraPosition _burlingtonKeys = CameraPosition(
    target: LatLng(43.3255, -79.7990),
    zoom: 14.4746,
  );

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  
  String? _currentJobId;

  Future<void> _myLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ));
      
      setState(() {
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));
        _pickupController.text = "Current Location";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingStage = ref.watch(bookingStageProvider);
    final bookingsAsync = ref.watch(bookingsProvider);

    if (bookingStage == BookingStage.searching && _currentJobId != null) {
      bookingsAsync.whenData((bookings) {
        final myJob = bookings.where((b) => b.jobId == _currentJobId).firstOrNull;
        if (myJob != null && myJob.status == 'accepted') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ref.read(bookingStageProvider.notifier).state != BookingStage.onRide) {
              ref.read(bookingStageProvider.notifier).state = BookingStage.onRide;
            }
          });
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map Background
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _burlingtonKeys,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Custom button below
          ),

          // 2. Booking UI Overlay
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: _buildLocationInputCard(),
          ),

          // 3. Bottom Sheet / Action Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(bookingStage),
          ),
          
          // My Location Button
          Positioned(
            bottom: bookingStage == BookingStage.idle ? 250 : 200, // Adjust based on panel height
            right: 16,
            child: FloatingActionButton(
              onPressed: _myLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInputCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pickupController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.circle, color: GemTheme.primaryGreen, size: 12),
                hintText: "Pickup Location",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const Divider(height: 1),
            TextField(
              controller: _dropoffController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.square, color: Colors.black, size: 12),
                hintText: "Where to?",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onTap: () {
                ref.read(bookingStageProvider.notifier).state = BookingStage.pickingLocation;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(BookingStage stage) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (stage == BookingStage.idle) ...[
             const Text(
              "Recent Places",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _recentPlaceTile(Icons.home, "Home", "123 Maple Ave"),
            _recentPlaceTile(Icons.work, "Work", "Tech Park Blvd"),
          ] else if (stage == BookingStage.pickingLocation || stage == BookingStage.confirming) ...[
             // Fare Estimation View
             const Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text("UberX", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                 Text("CA\$ 18.25", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
               ],
             ),
             const SizedBox(height: 8),
             const Text("4 mins away • 7.2 km", style: TextStyle(color: Colors.grey)),
             const SizedBox(height: 24),
             ElevatedButton(
               onPressed: () async {
                 final newJobId = DateTime.now().millisecondsSinceEpoch.toString();
                 setState(() {
                   _currentJobId = newJobId;
                 });
                 final newBooking = Booking(
                   jobId: newJobId,
                   date: DateTime.now().toIso8601String(),
                   waitForReturn: false,
                   passengers: [{"type": "Passenger", "name": "Gem User"}],
                   routeContext: {
                     "pickup_loc": _pickupController.text.isEmpty ? "Current Location" : _pickupController.text,
                     "drop_loc": _dropoffController.text,
                   },
                   status: 'pending',
                 );
                 
                 await ref.read(bookingRepositoryProvider).createBooking(newBooking);
                 if (mounted) {
                   ref.read(bookingStageProvider.notifier).state = BookingStage.searching;
                 }
               },
               child: const Text("Confirm Booking"),
             ),
          ] else if (stage == BookingStage.searching) ...[
             const Column(
               children: [
                 CircularProgressIndicator(),
                 SizedBox(height: 16),
                 Text("Finding a driver..."),
               ],
             )
          ] else if (stage == BookingStage.onRide) ...[
             const Column(
               children: [
                 Icon(Icons.check_circle, color: Colors.green, size: 48),
                 SizedBox(height: 16),
                 Text("Driver is on the way!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               ],
             )
          ]
        ],
      ),
    );
  }

  Widget _recentPlaceTile(IconData icon, String title, String address) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.grey[200], child: Icon(icon, color: Colors.black)),
      title: Text(title),
      subtitle: Text(address),
      onTap: () {
        // Mock selection
        _dropoffController.text = address;
        ref.read(bookingStageProvider.notifier).state = BookingStage.confirming;
      },
    );
  }
}
