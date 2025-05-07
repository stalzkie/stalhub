import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/user_repository.dart';

enum DateFilter { today, week, month, all }

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();
  final String userId;
  final String? playerId;

  TaskViewModel({required this.userId, required this.playerId});

  List<Task> _allTasks = [];
  List<Task> get allTasks => _allTasks;

  String _searchQuery = '';
  DateFilter _selectedFilter = DateFilter.today;
  bool _isLoading = false;

  String get searchQuery => _searchQuery;
  DateFilter get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks({bool force = false}) async {
    if (_allTasks.isNotEmpty && !force) return;

    _isLoading = true;
    notifyListeners();

    try {
      _allTasks = await _repository.fetchTasks();
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkTaskDueNotifications() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    for (var task in _allTasks) {
      if (task.status == 'Delivered') continue;

      final difference = task.dueDate.difference(now).inHours;

      if (difference <= 24 && difference > 0) {
        final key24 = 'task_${task.id}_24hr_notified';
        final lastNotified24 = prefs.getString(key24);

        if (difference > 12 && lastNotified24 != now.toIso8601String().split('T').first) {
          if (playerId != null && playerId!.isNotEmpty) {
            await NotificationService.sendNotification(
              title: '⏰ Task Due in 24 Hours!',
              message: _taskMessage(task),
              playerId: playerId!,
            );
            await prefs.setString(key24, now.toIso8601String().split('T').first);
          }
        }
      }

      if (difference <= 12 && difference > 0) {
        final key12 = 'task_${task.id}_12hr_notified';
        final lastNotified12 = prefs.getString(key12);

        if (lastNotified12 != now.toIso8601String().split('T').first) {
          if (playerId != null && playerId!.isNotEmpty) {
            await NotificationService.sendNotification(
              title: '⏰ Task Due in 12 Hours!',
              message: _taskMessage(task),
              playerId: playerId!,
            );
            await prefs.setString(key12, now.toIso8601String().split('T').first);
          }
        }
      }
    }
  }

  String _taskMessage(Task task) {
    return 'Task: ${task.taskName}\nClient: ${task.clientName}\nPrice: P${task.price}\nPlatform: ${task.platform}\nAssigned To: ${task.assignedTo}\nStatus: ${task.status}\nDue: ${task.dueDate.toLocal().toString().split(" ")[0]}';
  }

  List<Task> get filteredByDate {
    final now = DateTime.now();
    return _allTasks.where((task) {
      switch (_selectedFilter) {
        case DateFilter.today:
          return isSameDay(task.createdAt, now);
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

  List<Task> get searchedTasks {
    if (_searchQuery.isEmpty) return _allTasks;
    final q = _searchQuery.toLowerCase();
    return _allTasks.where((task) =>
        task.id.toString().contains(q) ||
        task.clientName.toLowerCase().contains(q) ||
        task.platform.toLowerCase().contains(q) ||
        task.assignedTo.toLowerCase().contains(q) ||
        task.status.toLowerCase().contains(q)).toList();
  }

  int get totalTasks => filteredByDate.length;
  int get workingTasks => filteredByDate.where((task) => task.status == 'Working').length;
  int get delayedTasks => filteredByDate.where((task) =>
      task.status != 'Delivered' &&
      task.dueDate.isBefore(DateTime.now())).length;

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

  void setFilter(DateFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _repository.addTask(task);
    await fetchTasks(force: true);

    final userRepo = UserRepository();
    final playerIds = await userRepo.fetchAllPlayerIds();

    await NotificationService.sendNotificationToMany(
      title: '✅ New Task Assigned',
      message: _taskMessage(task),
      playerIds: playerIds,
    );
  }

  Future<void> updateTask(int id, Map<String, dynamic> data) async {
    await _repository.updateTask(id, data);
    await fetchTasks(force: true);

    final updatedTask = _allTasks.firstWhere((task) => task.id == id);

    final userRepo = UserRepository();
    final playerIds = await userRepo.fetchAllPlayerIds();

    await NotificationService.sendNotificationToMany(
      title: '📝 Task Updated',
      message: _taskMessage(updatedTask),
      playerIds: playerIds,
    );
  }

  Future<void> deleteTask(int id) async {
    await _repository.deleteTask(id);
    await fetchTasks(force: true);
  }

  bool isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}
