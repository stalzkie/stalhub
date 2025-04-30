import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/ticket_model.dart';
import '../../core/services/notification_service.dart';

enum DateFilter { today, week, month, all }

class TicketViewModel extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  final String userId;
  final String? playerId;

  TicketViewModel({required this.userId, required this.playerId});

  List<Ticket> _allTickets = [];
  String _searchQuery = '';
  DateFilter _selectedFilter = DateFilter.today;

  List<Ticket> get allTickets => _allTickets;
  String get searchQuery => _searchQuery;
  DateFilter get selectedFilter => _selectedFilter;

  Future<void> fetchTickets() async {
    try {
      final response = await _client
          .from('tickets')
          .select()
          .order('created_at', ascending: false);

      _allTickets = response.map((e) => Ticket.fromJson(e)).toList();

      final now = DateTime.now();

      for (var ticket in _allTickets) {
        if (ticket.status == 'Not Read') {
          final lastUpdated = ticket.updatedAt ?? ticket.createdAt;
          final hoursSinceUpdate = now.difference(lastUpdated).inHours;

          final lastNotified = ticket.lastNotifiedAt;
          final shouldNotify = hoursSinceUpdate >= 2 &&
              (lastNotified == null || now.difference(lastNotified).inHours >= 2);

          if (shouldNotify && playerId != null && playerId!.isNotEmpty) {
            await NotificationService.sendNotification(
              title: '🔔 Unread Ticket Reminder',
              message:
                  'Client: ${ticket.clientName}\nPlatform: ${ticket.platform}\nStatus: ${ticket.status}\nContent: ${ticket.content}',
              playerId: playerId!,
            );

            await _client
                .from('tickets')
                .update({'last_notified_at': now.toIso8601String()})
                .eq('id', ticket.id);
          }
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error fetching tickets: $e');
    }
  }

  Future<void> addTicket(Ticket ticket) async {
    await _client.from('tickets').insert(ticket.toJson());
    await fetchTickets();

    if (playerId != null && playerId!.isNotEmpty) {
      await NotificationService.sendNotification(
        title: '📨 New Ticket Received',
        message:
            'Client: ${ticket.clientName}\nPlatform: ${ticket.platform}\nStatus: ${ticket.status}\nContent: ${ticket.content}',
        playerId: playerId!,
      );
    }
  }

  Future<void> updateTicket(int id, Map<String, dynamic> data) async {
    await _client.from('tickets').update(data).eq('id', id);
    await fetchTickets();

    final updatedTicket = _allTickets.firstWhere((t) => t.id == id);
    if (playerId != null && playerId!.isNotEmpty) {
      await NotificationService.sendNotification(
        title: '🛠️ Ticket Updated',
        message:
            'Client: ${updatedTicket.clientName}\nPlatform: ${updatedTicket.platform}\nStatus: ${updatedTicket.status}\nContent: ${updatedTicket.content}',
        playerId: playerId!,
      );
    }
  }

  Future<void> deleteTicket(int id) async {
    await _client.from('tickets').delete().eq('id', id);
    await fetchTickets();
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setFilter(DateFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  int get pendingCount => _allTickets.where((t) {
        final status = t.status.toLowerCase();
        return status != 'resolved' && status != 'discarded';
      }).length;

  List<Ticket> get filteredByDate {
    final now = DateTime.now();
    return _allTickets.where((ticket) {
      final created = ticket.createdAt;
      switch (_selectedFilter) {
        case DateFilter.today:
          return created.year == now.year &&
              created.month == now.month &&
              created.day == now.day;
        case DateFilter.week:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          return created.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              created.isBefore(endOfWeek.add(const Duration(days: 1)));
        case DateFilter.month:
          return created.year == now.year && created.month == now.month;
        case DateFilter.all:
          return true;
      }
    }).toList();
  }

  List<Ticket> get searchResults {
    final dateFiltered = filteredByDate;
    if (_searchQuery.isEmpty) return dateFiltered;

    final query = _searchQuery.toLowerCase();
    return dateFiltered.where((ticket) {
      return ticket.id.toString().contains(query) ||
          ticket.clientName.toLowerCase().contains(query) ||
          ticket.platform.toLowerCase().contains(query) ||
          ticket.status.toLowerCase() == query;
    }).toList();
  }
}