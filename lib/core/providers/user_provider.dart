import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { passenger, driver, admin }

class UserState {
  final String? uid;
  final UserRole role;
  final bool isAuthenticated;

  const UserState({
    this.uid,
    this.role = UserRole.passenger,
    this.isAuthenticated = false,
  });

  UserState copyWith({
    String? uid,
    UserRole? role,
    bool? isAuthenticated,
  }) {
    return UserState(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  void setRole(UserRole role) {
    state = state.copyWith(role: role);
  }

  void login(String uid, UserRole role) {
    state = state.copyWith(
      uid: uid,
      role: role,
      isAuthenticated: true,
    );
  }

  void logout() {
    state = const UserState();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
