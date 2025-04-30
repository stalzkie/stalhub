import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice_model.dart';

class InvoiceRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Invoice>> fetchInvoices() async {
    final response = await _client
        .from('invoices')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Invoice.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addInvoice(Invoice invoice) async {
    await _client.from('invoices').insert(invoice.toMap());
  }

  Future<void> updateInvoice(int id, Map<String, dynamic> data) async {
    await _client.from('invoices').update(data).eq('id', id);
  }

  Future<void> deleteInvoice(int id) async {
    await _client.from('invoices').delete().eq('id', id);
  }
}