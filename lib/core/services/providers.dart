import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import 'location_service.dart';

// Service Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

// Auth State Provider
final authStateProvider = StreamProvider((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// User Profile Provider
final userProfileProvider = FutureProvider((ref) async {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return null;
  return ref.watch(authServiceProvider).getUserProfile(authUser.uid);
});
