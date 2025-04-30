import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  final UserRepository _repository = UserRepository();

  UserModel? _user;

  UserModel? get user => _user;

  String? get name => _user?.name;
  String? get email => _user?.email;
  String? get phoneNumber => _user?.phoneNumber;
  String? get role => _user?.role;
  String? get profilePic => _user?.profilePic;

  /// Fetch user data using the custom user ID (from your LoginViewModel)
  Future<void> fetchUserData(String id) async {
    final profile = await _repository.fetchUserProfile(id);
    _user = profile;
    notifyListeners();
  }

  /// Update profile using custom Supabase users table (not Supabase Auth)
  Future<void> updateProfile({
    required String userId,
    required String updatedName,
    required String updatedEmail,
    required String updatedPhone,
  }) async {
    await _repository.updateUser(userId, {
      'name': updatedName,
      'email': updatedEmail,
      'phone_number': updatedPhone,
    });

    // Refresh state
    await fetchUserData(userId);
  }

  /// Change password stored in plain-text in the users table
  Future<String?> changePassword({
    required String userId,
    required String newPassword,
  }) async {
    try {
      await _repository.updateUser(userId, {'password': newPassword});
      return null; // success
    } catch (e) {
      return e.toString();
    }
  }
}
