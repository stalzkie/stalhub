import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

enum DateFilter { today, week, month, all }

class TaskAnalyticsViewModel extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();
  List<Task> _allTasks = [];
  bool _isLoading = false;

  DateFilter _selectedFilter = DateFilter.today;
  DateFilter get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  List<Task> get filteredByDate => _filterTasksByDate(_selectedFilter);

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allTasks = await _repository.fetchTasks();
    } catch (e) {
      debugPrint("Failed to fetch tasks: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void setFilter(DateFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<Task> _filterTasksByDate(DateFilter filter) {
    final now = DateTime.now();
    return _allTasks.where((task) {
      switch (filter) {
        case DateFilter.today:
          return _isSameDay(task.createdAt, now);
        case DateFilter.week:
          final last7 = now.subtract(const Duration(days: 7));
          return task.createdAt.isAfter(last7);
        case DateFilter.month:
          return task.createdAt.month == now.month && task.createdAt.year == now.year;
        case DateFilter.all:
        default:
          return true;
      }
    }).toList();
  }

  int get totalTasks => filteredByDate.length;
  int get workingTasks => filteredByDate.where((task) => task.status == 'Working').length;
  int get delayedTasks =>
      filteredByDate.where((task) => task.status != 'Delivered' && task.dueDate.isBefore(DateTime.now())).length;

  String get topWriterName {
    final completed = filteredByDate.where((task) => task.status == 'Delivered');
    if (completed.isEmpty) return '-';

    final counter = <String, int>{};
    for (var task in completed) {
      counter[task.assignedTo] = (counter[task.assignedTo] ?? 0) + 1;
    }

    return counter.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double get topWriterPercentage {
    final completed = filteredByDate.where((task) => task.status == 'Delivered');
    if (completed.isEmpty || filteredByDate.isEmpty) return 0;

    final counter = <String, int>{};
    for (var task in completed) {
      counter[task.assignedTo] = (counter[task.assignedTo] ?? 0) + 1;
    }

    final topCount = counter.values.reduce((a, b) => a > b ? a : b);
    return (topCount / filteredByDate.length) * 100;
  }

  double get productivityRate {
    final delivered = filteredByDate.where((task) => task.status == 'Delivered');
    if (delivered.isEmpty) return 0;

    final onTime = delivered.where((task) =>
      task.createdAt.isBefore(task.dueDate) || task.createdAt.isAtSameMomentAs(task.dueDate)
    ).length;

    return (onTime / delivered.length) * 100;
  }

  double get comparisonWithPrevious {
    final current = filteredByDate.length.toDouble();
    final previous = _getPreviousPeriodTasks().length.toDouble();

    if (previous == 0) return current == 0 ? 0 : 100;
    return ((current - previous) / previous) * 100;
  }

  String get mostPopularPlatform {
    if (filteredByDate.isEmpty) return '-';

    final counter = <String, int>{};
    for (var task in filteredByDate) {
      counter[task.platform] = (counter[task.platform] ?? 0) + 1;
    }

    return counter.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double get mostPopularPlatformPercentage {
    if (filteredByDate.isEmpty) return 0;

    final counter = <String, int>{};
    for (var task in filteredByDate) {
      counter[task.platform] = (counter[task.platform] ?? 0) + 1;
    }

    final topCount = counter.values.reduce((a, b) => a > b ? a : b);
    return (topCount / filteredByDate.length) * 100;
  }

  String get frequentClientName {
    if (filteredByDate.isEmpty) return '-';

    final counter = <String, int>{};
    for (var task in filteredByDate) {
      counter[task.clientName] = (counter[task.clientName] ?? 0) + 1;
    }

    return counter.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int get frequentClientOrderCount {
    if (filteredByDate.isEmpty) return 0;

    final counter = <String, int>{};
    for (var task in filteredByDate) {
      counter[task.clientName] = (counter[task.clientName] ?? 0) + 1;
    }

    return counter.values.reduce((a, b) => a > b ? a : b);
  }

  Map<String, dynamic> get bestMonth {
    if (_allTasks.isEmpty) return {};

    final counter = <String, int>{};
    for (var task in _allTasks) {
      final key = '${task.createdAt.month}-${task.createdAt.year}';
      counter[key] = (counter[key] ?? 0) + 1;
    }

    final best = counter.entries.reduce((a, b) => a.value > b.value ? a : b);
    final split = best.key.split('-');

    return {
      'month': split[0],
      'year': split[1],
      'count': best.value,
    };
  }

  List<Task> _getPreviousPeriodTasks() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case DateFilter.today:
        final yesterday = now.subtract(const Duration(days: 1));
        return _allTasks.where((task) => _isSameDay(task.createdAt, yesterday)).toList();
      case DateFilter.week:
        final start = now.subtract(const Duration(days: 14));
        final mid = now.subtract(const Duration(days: 7));
        return _allTasks.where((task) =>
            task.createdAt.isAfter(start) && task.createdAt.isBefore(mid)).toList();
      case DateFilter.month:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return _allTasks
            .where((task) =>
                task.createdAt.month == lastMonth.month &&
                task.createdAt.year == lastMonth.year)
            .toList();
      case DateFilter.all:
        return [];
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}
