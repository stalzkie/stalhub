import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> loginCustom(String email, String password) async {
    final response = await _client
        .from('users')
        .select()
        .eq('email', email)
        .eq('password', password) 
        .maybeSingle();

    return response;
  }
}
