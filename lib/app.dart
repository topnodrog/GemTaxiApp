import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gem_taxi/core/services/providers.dart';
import 'package:gem_taxi/features/passenger/booking_screen.dart';
import 'package:gem_taxi/features/driver/driver_dashboard.dart';
import 'features/auth/login_screen.dart';
import 'core/constants/theme.dart';

class GemTaxiApp extends ConsumerWidget {
  const GemTaxiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userProfile = ref.watch(userProfileProvider);

    return MaterialApp(
      title: 'Gem Taxi',
      theme: GemTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return userProfile.when(
              data: (profile) {
                if (profile != null && profile.role == 'driver') {
                  return const DriverDashboard();
                }
                return const BookingScreen();
              },
              loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
              error: (err, stack) => const BookingScreen(), // Fallback
            );
          }
          return const LoginScreen();
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text("Error: $err"))),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/passenger': (context) => const BookingScreen(),
        '/driver': (context) => const DriverDashboard(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
