import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  String email = '';
  String password = '';
  String? errorMessage;
  bool isLoading = false;
  int failedAttempts = 0;

  UserModel? _loggedInUser;
  UserModel? get loggedInUser => _loggedInUser;

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    notifyListeners();
  }

  /// Custom login using plain-text password stored in Supabase `users` table
  Future<bool> login() async {
    isLoading = true;
    notifyListeners();

    try {
      final userData = await _authRepository.loginCustom(email, password);
      if (userData != null) {
        _loggedInUser = UserModel.fromJson({
          'id': userData['id'],
          'name': userData['name'],
          'email': userData['email'],
          'phone_number': userData['phone_number'],
          'role': userData['role'],
          'profile_pic': userData['profile_pic'] ?? '', // Optional/default
          'created_at': userData['created_at'],
          'onesignal_player_id': userData['onesignal_player_id'],
        });

        await _saveOneSignalPlayerId(_loggedInUser!.id);

        failedAttempts = 0;
        errorMessage = null;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        failedAttempts++;
        errorMessage = failedAttempts >= 5
            ? 'Too many failed attempts. Try again in 30 minutes.'
            : 'Invalid email or password.';
      }
    } catch (e) {
      errorMessage = 'Login failed. Please try again.';
      debugPrint('Login error: $e');
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  /// Save OneSignal Player ID to Supabase (OneSignal v5.x.x)
  Future<void> _saveOneSignalPlayerId(String userId) async {
    try {
      await OneSignal.User.pushSubscription.optIn();
      await Future.delayed(const Duration(seconds: 1));

      final playerId = OneSignal.User.pushSubscription.id;
      debugPrint('OneSignal Player ID: $playerId');

      if (playerId != null && playerId.isNotEmpty && userId.isNotEmpty) {
        await Supabase.instance.client
            .from('users')
            .update({'onesignal_player_id': playerId})
            .eq('id', userId);

        debugPrint('✅ Player ID saved to Supabase.');
      } else {
        debugPrint('❌ Player ID is null or empty.');
      }
    } catch (e) {
      debugPrint('❌ Failed to save Player ID: $e');
    }
  }
}
