import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../view_model/tasks/task_view_model.dart';
import '../../view_model/auth/login_view_model.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/floating_global_menu.dart';
import '../widgets/status_indicator.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  int currentIndex = 2;
  late TaskViewModel taskViewModel;

  @override
  void initState() {
    super.initState();
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    taskViewModel = TaskViewModel(
      userId: loginVM.loggedInUser?.id ?? '',
      playerId: loginVM.loggedInUser?.playerId ?? '',
    );
    taskViewModel.fetchTasks(force: true);
  }

  void onTabTapped(int index) {
    if (index != currentIndex) {
      final routes = ['/dashboard', '/invoices', '/tasks', '/tickets', '/profile'];
      Navigator.pushNamed(context, routes[index]);
      setState(() => currentIndex = index);
    }
  }

  Future<void> _onRefresh() async {
    await taskViewModel.fetchTasks(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: taskViewModel,
      child: Consumer<TaskViewModel>(
        builder: (context, vm, _) {
          final tasks = vm.filteredByDate.where((task) {
            final q = vm.searchQuery.toLowerCase();
            return task.id.toString().contains(q) ||
                task.taskName.toLowerCase().contains(q) ||
                task.clientName.toLowerCase().contains(q) ||
                task.platform.toLowerCase().contains(q) ||
                task.assignedTo.toLowerCase().contains(q) ||
                task.status.toLowerCase().contains(q);
          }).toList();

          return Scaffold(
            backgroundColor: const Color(0xFFF9F9F9),
            body: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(25.w, 40.h, 25.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      _buildFilterBar(vm),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatBox(label: 'Orders', value: vm.totalTasks),
                          _StatBox(label: 'Working', value: vm.workingTasks),
                          _StatBox(label: 'Delays', value: vm.delayedTasks),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      _buildWriterBox(vm),
                      SizedBox(height: 10.h),
                      _buildAllTasksTitle(context),
                      SizedBox(height: 10.h),
                      _buildSearchBar(vm),
                      SizedBox(height: 10.h),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: tasks.length,
                            padding: EdgeInsets.only(bottom: 20.h),
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return _buildTaskCard(task);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const FloatingMenuButton(),
              ],
            ),
            bottomNavigationBar: CustomBottomNavigation(
              currentIndex: currentIndex,
              onTap: onTabTapped,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(task) {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, '/edit-task', arguments: task);
        if (mounted) {
          await taskViewModel.fetchTasks(force: true);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Task ID: ${task.id}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Figtree',
                    ),
                  ),
                ),
                StatusIndicator(status: task.status),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              task.taskName,
              style: TextStyle(fontSize: 14.sp, fontFamily: 'Figtree'),
            ),
            SizedBox(height: 6.h),
            Text(
              'Due: ${DateFormat.yMMMd().format(task.dueDate)}',
              style: TextStyle(fontSize: 14.sp, fontFamily: 'Figtree'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(TaskViewModel vm) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E2E2),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: DateFilter.values.map((filter) {
          final isSelected = vm.selectedFilter == filter;
          final label = {
            DateFilter.today: 'Today',
            DateFilter.week: 'Week',
            DateFilter.month: 'Month',
            DateFilter.all: 'All Time'
          }[filter]!;

          return GestureDetector(
            onTap: () => vm.setFilter(filter),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: isSelected
                  ? BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.r))
                  : null,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.black.withAlpha(128),
                  fontSize: 14.sp,
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWriterBox(TaskViewModel vm) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Most Productive Writer',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 173, 173, 173))),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(vm.topWriterName,
                  style: TextStyle(fontSize: 20.sp, fontFamily: 'Figtree', fontWeight: FontWeight.w600)),
              Text('${vm.topWriterPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 20.sp, fontFamily: 'Figtree', fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllTasksTitle(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/all-tasks'),
      child: Text(
        'All Tasks',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Figtree',
          decoration: TextDecoration.underline,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSearchBar(TaskViewModel vm) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: const Color(0xFF525252),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: vm.updateSearchQuery,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: TextStyle(color: Colors.white.withAlpha(128), fontSize: 14.sp),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 18.sp, fontFamily: 'Figtree', color: Colors.black.withAlpha(180))),
        Text(value.toString(),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500, fontFamily: 'Figtree')),
      ],
    );
  }
}
