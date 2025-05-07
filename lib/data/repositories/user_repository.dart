import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch a single user profile by ID
  Future<UserModel?> fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ Error fetching user profile for $userId: $e');
      return null;
    }
  }

  /// Update a user by ID
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _client.from('users').update(data).eq('id', userId);
    } catch (e) {
      print('❌ Error updating user $userId: $e');
    }
  }

  /// ✅ Fetch all playerIds (excluding null or empty)
  Future<List<String>> fetchAllPlayerIds() async {
    try {
      final response = await _client
          .from('users')
          .select('player_id')
          .not('player_id', 'is', null);

      return response
          .map((row) => row['player_id'] as String?)
          .where((id) => id != null && id.trim().isNotEmpty)
          .map((id) => id!.trim())
          .toList();
    
      return [];
    } catch (e) {
      print('❌ Error fetching player IDs: $e');
      return [];
    }
  }
}
