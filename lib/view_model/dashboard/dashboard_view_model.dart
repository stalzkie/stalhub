import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../data/repositories/task_repository.dart';

enum DateFilter { today, week, month, all }

class DashboardViewModel extends ChangeNotifier {
  final InvoiceRepository _invoiceRepo = InvoiceRepository();
  final TaskRepository _taskRepo = TaskRepository();
  final SupabaseClient _client = Supabase.instance.client;

  List<Invoice> _invoices = [];
  List<Task> _tasks = [];

  DateFilter _selectedFilter = DateFilter.today;
  DateFilter get selectedFilter => _selectedFilter;

  List<Invoice> get invoices => _filteredInvoices;
  List<Task> get tasks => _filteredTasks;

  // Task metrics
  int get totalTasks => _filteredTasks.length;

  int get workingTasks =>
      _filteredTasks.where((t) => t.status.toLowerCase() == 'working').length;

  int get delayedTasks => _filteredTasks.where((task) =>
      task.status.toLowerCase() != 'delivered' &&
      task.dueDate.isBefore(DateTime.now())).length;

  // Invoice metrics
  int get paidInvoices =>
      _filteredInvoices.where((i) => (i.status ?? '').trim().toLowerCase() == 'paid').length;

  int get unpaidInvoices =>
      _filteredInvoices.where((i) => (i.status ?? '').trim().toLowerCase() == 'unpaid').length;

  double get totalSales =>
      _filteredInvoices
          .where((i) => (i.status ?? '').trim().toLowerCase() == 'paid')
          .fold(0.0, (sum, i) => sum + i.price);

  // Sales comparison
  double _currentPeriodSales = 0;
  double _previousPeriodSales = 0;

  double get salesComparison => _currentPeriodSales - _previousPeriodSales;

  // Best month sales
  String _bestSalesMonth = '-';
  int _bestSalesYear = 0;
  double _bestSalesAmount = 0;

  String get bestSalesMonth => _bestSalesMonth;
  int get bestSalesYear => _bestSalesYear;
  double get bestSalesAmount => _bestSalesAmount;

  // Tasks due today
  List<Task> get tasksDueToday {
    final today = DateTime.now();
    return _tasks.where((task) =>
      task.dueDate.year == today.year &&
      task.dueDate.month == today.month &&
      task.dueDate.day == today.day).toList();
  }

  // Private filtered tasks based on current date filter
  List<Task> get _filteredTasks {
    return _filterByDate(_tasks.map((e) => {'date': e.createdAt, 'object': e}).toList())
      .map((e) => e['object'] as Task)
      .toList();
  }

  // Private filtered invoices based on current date filter
  List<Invoice> get _filteredInvoices {
    return _filterByDate(_invoices.map((e) => {'date': e.createdAt, 'object': e}).toList())
      .map((e) => e['object'] as Invoice)
      .toList();
  }

  void setFilter(DateFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<Map<String, dynamic>> _filterByDate(List<Map<String, dynamic>> data) {
    final now = DateTime.now();

    return data.where((entry) {
      final date = entry['date'] as DateTime;

      switch (_selectedFilter) {
        case DateFilter.today:
          return date.year == now.year &&
                 date.month == now.month &&
                 date.day == now.day;
        case DateFilter.week:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                 date.isBefore(endOfWeek.add(const Duration(days: 1)));
        case DateFilter.month:
          return date.year == now.year && date.month == now.month;
        case DateFilter.all:
          return true;
      }
    }).toList();
  }

  Future<void> fetchDashboardData() async {
    final invoiceResponse = await _client.from('invoices').select().order('created_at');
    final taskResponse = await _client.from('tasks').select().order('created_at');

    _invoices = (invoiceResponse as List)
        .map((e) => Invoice.fromMap(e as Map<String, dynamic>))
        .toList();

    _tasks = (taskResponse as List)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();

    // Compute sales for current filtered invoices (Paid only)
    final currentFiltered = _filteredInvoices
        .where((i) => (i.status ?? '').toLowerCase() == 'paid')
        .toList();
    _currentPeriodSales = currentFiltered.fold(0.0, (sum, i) => sum + i.price);

    // Compute previous period sales (Paid only)
    final previousFiltered = _filterPreviousPeriod()
        .where((i) => (i.status ?? '').toLowerCase() == 'paid')
        .toList();
    _previousPeriodSales = previousFiltered.fold(0.0, (sum, i) => sum + i.price);

    _computeBestSalesMonth();

    notifyListeners();
  }

  List<Invoice> _filterPreviousPeriod() {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case DateFilter.today:
        final yesterday = now.subtract(const Duration(days: 1));
        return _invoices.where((i) =>
          i.createdAt.year == yesterday.year &&
          i.createdAt.month == yesterday.month &&
          i.createdAt.day == yesterday.day
        ).toList();

      case DateFilter.week:
        final start = now.subtract(Duration(days: now.weekday - 1 + 7));
        final end = start.add(const Duration(days: 6));
        return _invoices.where((i) =>
          i.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
          i.createdAt.isBefore(end.add(const Duration(days: 1)))
        ).toList();

      case DateFilter.month:
        final lastMonth = DateTime(now.year, now.month - 1);
        return _invoices.where((i) =>
          i.createdAt.year == lastMonth.year &&
          i.createdAt.month == lastMonth.month
        ).toList();

      case DateFilter.all:
        return [];
    }
  }

  void _computeBestSalesMonth() {
    final salesByMonth = <String, double>{};

    for (final invoice in _invoices.where((i) => (i.status ?? '').toLowerCase() == 'paid')) {
      final key = '${invoice.createdAt.year}-${invoice.createdAt.month.toString().padLeft(2, '0')}';
      salesByMonth.update(key, (value) => value + invoice.price, ifAbsent: () => invoice.price);
    }

    final best = salesByMonth.entries.fold<MapEntry<String, double>>(
      const MapEntry('', 0),
      (prev, e) => e.value > prev.value ? e : prev,
    );

    if (best.key.isNotEmpty) {
      final parts = best.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      _bestSalesYear = year;
      _bestSalesMonth = _monthName(month);
      _bestSalesAmount = best.value;
    }
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }
}
