import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class LocationService {
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;
  final Logger _logger = Logger();
  StreamSubscription<Position>? _positionStreamSubscription;

  // Check & Request Permissions
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled.
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }

  // Get Current Location Once
  Future<Position?> getCurrentLocation() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return null;
    return await Geolocator.getCurrentPosition();
  }

  // Start Tracking Driver Location (Pushes to Realtime DB)
  void startTrackingDriver(String driverId) async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        // Update Firebase Realtime Database
        _realtimeDb.ref('driver_locations/$driverId').set({
          'lat': position.latitude,
          'lng': position.longitude,
          'heading': position.heading,
          'timestamp': ServerValue.timestamp,
        });
      },
      onError: (e) {
        _logger.e("Location Stream Error: $e");
      }
    );
  }

  // Stop Tracking
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // Listen to nearby drivers (for Passenger)
  // Note: For production, use GeoFire or backend filtering. 
  // Here we just listen to the whole node for demo simplicity or assume limited scope.
  Stream<DatabaseEvent> getNearbyDriversStream() {
    return _realtimeDb.ref('driver_locations').onValue;
  }
}
