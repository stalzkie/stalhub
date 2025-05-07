import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/invoice_model.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/user_repository.dart'; // ✅ Import added

enum DateFilter { today, week, month, all }

class InvoiceViewModel extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  final String userId;
  final String? playerId;

  InvoiceViewModel({
    required this.userId,
    required this.playerId,
  });

  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  List<Invoice> _allInvoices = [];
  List<Invoice> get allInvoices => _allInvoices;

  List<Invoice> _filteredInvoices = [];
  List<Invoice> get filteredInvoices => _filteredInvoices;

  DateFilter _selectedFilter = DateFilter.all;
  DateFilter get selectedFilter => _selectedFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _topClientName = '-';
  double _topClientPercentage = 0.0;
  String get topClientName => _topClientName;
  double get topClientPercentage => _topClientPercentage;

  String _topPlatformName = '-';
  double _topPlatformPercentage = 0.0;
  String get topPlatformName => _topPlatformName;
  double get topPlatformPercentage => _topPlatformPercentage;

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setFilter(DateFilter filter) {
    _selectedFilter = filter;
    _applyFilter();
    _computeAnalytics();
    notifyListeners();
  }

  Future<void> fetchInvoices({bool force = false}) async {
    if (!force && _hasLoaded) return;

    final response = await _client
        .from('invoices')
        .select()
        .order('created_at', ascending: false);

    _allInvoices = (response as List).map((map) => Invoice.fromMap(map)).toList();

    _applyFilter();
    _computeAnalytics();
    _hasLoaded = true;
    notifyListeners();
  }

  Future<void> addInvoice(Invoice invoice) async {
    await _client.from('invoices').insert(invoice.toMap());

    _allInvoices.insert(0, invoice);
    _applyFilter();
    _computeAnalytics();
    notifyListeners();

    print('[DEBUG] Sending NEW invoice notification...');
    final userRepo = UserRepository();
    final playerIds = await userRepo.fetchAllPlayerIds(); // ✅ Fetch all

    await NotificationService.sendNotificationToMany(
      title: '💸 New Invoice Created',
      message:
          'Amount: P${invoice.price.toStringAsFixed(2)}\nClient: ${invoice.clientName}\nDeadline: ${invoice.dueDate.toLocal().toString().split(" ")[0]}\nStatus: ${invoice.status}\nPlatform: ${invoice.platform}',
      playerIds: playerIds,
    );
  }

  Future<void> updateInvoice(int id, Map<String, dynamic> map) async {
    await _client.from('invoices').update(map).eq('id', id);

    final index = _allInvoices.indexWhere((i) => i.id == id);
    if (index != -1) {
      _allInvoices[index] = Invoice.fromMap({...map, 'id': id});
    }

    _applyFilter();
    _computeAnalytics();
    notifyListeners();

    final updatedInvoice = _allInvoices.firstWhere(
      (i) => i.id == id,
      orElse: () {
        print('[DEBUG] Invoice not found in _allInvoices after update. Using map data.');
        return Invoice.fromMap({...map, 'id': id});
      },
    );

    print('[DEBUG] Sending UPDATE invoice notification...');
    final userRepo = UserRepository();
    final playerIds = await userRepo.fetchAllPlayerIds(); // ✅ Fetch all

    await NotificationService.sendNotificationToMany(
      title: '🧾 Invoice Updated',
      message:
          'Amount: P${updatedInvoice.price.toStringAsFixed(2)}\nClient: ${updatedInvoice.clientName}\nDeadline: ${updatedInvoice.dueDate.toLocal().toString().split(" ")[0]}\nStatus: ${updatedInvoice.status}\nPlatform: ${updatedInvoice.platform}',
      playerIds: playerIds,
    );
  }

  Future<void> deleteInvoice(int id) async {
    await _client.from('invoices').delete().eq('id', id);
    _allInvoices.removeWhere((i) => i.id == id);
    _applyFilter();
    _computeAnalytics();
    notifyListeners();
  }

  void _applyFilter() {
    final now = DateTime.now();
    _filteredInvoices = switch (_selectedFilter) {
      DateFilter.today => _allInvoices.where((i) =>
          i.createdAt.year == now.year &&
          i.createdAt.month == now.month &&
          i.createdAt.day == now.day).toList(),
      DateFilter.week => _allInvoices.where((i) =>
          i.createdAt.isAfter(now.subtract(Duration(days: now.weekday - 1)))).toList(),
      DateFilter.month => _allInvoices.where((i) =>
          i.createdAt.year == now.year && i.createdAt.month == now.month).toList(),
      DateFilter.all => List.from(_allInvoices),
    };
  }

  void _computeAnalytics() {
    final paidInvoices = _filteredInvoices.where((i) => i.status.toLowerCase() == 'paid').toList();
    final totalPaid = paidInvoices.fold(0.0, (sum, i) => sum + i.price);

    final clientTotals = <String, double>{};
    for (var i in paidInvoices) {
      clientTotals[i.clientName] = (clientTotals[i.clientName] ?? 0) + i.price;
    }

    if (clientTotals.isNotEmpty) {
      final best = clientTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      _topClientName = best.key;
      _topClientPercentage = totalPaid == 0 ? 0 : (best.value / totalPaid) * 100;
    }

    final platformCounts = <String, int>{};
    for (var i in _filteredInvoices) {
      platformCounts[i.platform] = (platformCounts[i.platform] ?? 0) + 1;
    }

    final totalPlatforms = _filteredInvoices.length;
    if (platformCounts.isNotEmpty) {
      final best = platformCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      _topPlatformName = best.key;
      _topPlatformPercentage = totalPlatforms == 0 ? 0 : (best.value / totalPlatforms) * 100;
    }
  }
}
