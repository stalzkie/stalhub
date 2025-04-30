import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserModel?> fetchUserProfile(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return UserModel.fromJson(response);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _client.from('users').update(data).eq('id', userId);
  }
}