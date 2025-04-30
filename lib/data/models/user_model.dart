class UserModel {
  final String id;
  final String name;
  final String role;
  final String email;
  final String phoneNumber;
  final String profilePic;
  final DateTime createdAt;
  final String? playerId; // ✅ OneSignal player ID (nullable)

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.phoneNumber,
    required this.profilePic,
    required this.createdAt,
    this.playerId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePic: json['profile_pic'] ?? '', // ✅ Prevent null crash
      createdAt: DateTime.parse(json['created_at']),
      playerId: json['onesignal_player_id'], // Nullable
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'phone_number': phoneNumber,
      'profile_pic': profilePic,
      'created_at': createdAt.toIso8601String(),
      'onesignal_player_id': playerId,
    };
  }
}
