class UserModel {
  final String uid;
  final String? phoneNumber;
  final String? email;
  final String displayName;
  final String role; // 'passenger', 'driver', 'admin'
  final DateTime createdAt;

  UserModel({
    required this.uid,
    this.phoneNumber,
    this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      email: map['email'] as String?,
      displayName: map['displayName'] as String? ?? 'User',
      role: map['role'] as String? ?? 'passenger',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
