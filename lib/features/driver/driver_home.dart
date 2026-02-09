import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/theme.dart';

// Driver Status State
final isDriverOnlineProvider = StateProvider<bool>((ref) => false);

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  
  // Burlington Coordinates
  static const CameraPosition _burlingtonKeys = CameraPosition(
    target: LatLng(43.3255, -79.7990),
    zoom: 14.4746,
  );

  Timer? _jobRequestSimulator;

  @override
  void dispose() {
    _jobRequestSimulator?.cancel();
    super.dispose();
  }

  void _listenForJobs(bool isOnline) {
    if (isOnline) {
      // Simulate an incoming job request after 3 seconds
      _jobRequestSimulator = Timer(const Duration(seconds: 3), () {
        if (mounted && ref.read(isDriverOnlineProvider)) {
          _showJobRequestModal();
        }
      });
      // In real app: _locationService.startTrackingDriver(uid);
    } else {
      _jobRequestSimulator?.cancel();
      // In real app: _locationService.stopTracking();
    }
  }

  void _showJobRequestModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => const JobRequestModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isDriverOnlineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gem Driver"),
        actions: [
          Switch(
            value: isOnline,
            activeThumbColor: Colors.white,
            inactiveThumbColor: Colors.grey,
            onChanged: (val) {
              ref.read(isDriverOnlineProvider.notifier).state = val;
              _listenForJobs(val);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _burlingtonKeys,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true,
          ),
          
          if (!isOnline)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 60, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text(
                      "You are Offline",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: GemTheme.primaryGreen),
                      onPressed: () {
                        ref.read(isDriverOnlineProvider.notifier).state = true;
                        _listenForJobs(true);
                      },
                      child: const Text("GO ONLINE"),
                    )
                  ],
                ),
              ),
            ),
            
          // Earnings Fab
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
              ),
              child: const Text(
                "\$145.50 Today",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class JobRequestModal extends StatefulWidget {
  const JobRequestModal({super.key});

  @override
  State<JobRequestModal> createState() => _JobRequestModalState();
}

class _JobRequestModalState extends State<JobRequestModal> {
  int _secondsRemaining = 15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
          Navigator.pop(context); // Auto decline
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("NEW RIDE REQUEST", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text("$_secondsRemaining s", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 16),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.person, size: 40),
            title: Text("4.8 ★  Alice M."),
            subtitle: Text("2.4 km away"),
          ),
          const Divider(),
          const Row(
            children: [
              Icon(Icons.location_on, color: GemTheme.primaryGreen),
              SizedBox(width: 8),
              Text("Pickup: Burlington GO Station", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.flag, color: Colors.red),
              SizedBox(width: 8),
              Text("Dropoff: Mapleview Mall", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("EST. FARE", style: TextStyle(color: Colors.grey)),
              Text("\$12.50", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text("DECLINE", style: TextStyle(color: Colors.red)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to navigation screen in real app
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ride Accepted!")));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GemTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("ACCEPT RIDE"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
