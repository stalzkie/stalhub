import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/export_model.dart';

class ExportRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> addExportRecord(ExportRecord export) async {
    await _client.from('exports').insert(export.toJson());
  }

  Future<List<ExportRecord>> fetchExportsByUser(String userId) async {
    final response = await _client
        .from('exports')
        .select()
        .eq('user_id', userId)
        .order('exported_at', ascending: false);

    return (response as List)
        .map((e) => ExportRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}