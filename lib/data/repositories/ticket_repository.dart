import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';

class TicketRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch tickets from Supabase
  Future<List<Ticket>> fetchTickets() async {
    final response = await _client
        .from('tickets')
        .select()
        .order('created_at', ascending: false);

    return response.map((e) => Ticket.fromJson(e)).toList();
  }

  /// Add a new ticket
  Future<void> addTicket(Ticket ticket) async {
    await _client.from('tickets').insert(ticket.toJson());
  }

  /// Update ticket by ID
  Future<void> updateTicket(int id, Map<String, dynamic> data) async {
    await _client.from('tickets').update(data).eq('id', id);
  }

  /// Delete ticket by ID
  Future<void> deleteTicket(int id) async {
    await _client.from('tickets').delete().eq('id', id);
  }
}
