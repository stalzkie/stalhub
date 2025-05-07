import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stalhub/view/widgets/status_indicator.dart';
import 'package:stalhub/view_model/auth/login_view_model.dart';
import 'package:stalhub/view_model/tasks/task_view_model.dart';
import 'package:stalhub/view/tasks/edit_task_screen.dart';
import 'package:stalhub/view/widgets/custom_bottom_navigation.dart';
import 'package:stalhub/view/widgets/floating_global_menu.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
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
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          'assets/images/back-button-icon.png',
                          width: 32.w,
                          height: 32.w,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildFilterBar(vm),
                      SizedBox(height: 16.h),
                      Text(
                        'All Tasks',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Figtree',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _buildSearchBar(vm),
                      SizedBox(height: 10.h),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 20.h),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return _buildTaskCard(task, context);
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
              currentIndex: 2,
              onTap: (index) {
                final routes = ['/dashboard', '/invoices', '/tasks', '/tickets', '/profile'];
                if (index != 2) {
                  Navigator.pushNamed(context, routes[index]);
                }
              },
            ),
          );
        },
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

  Widget _buildTaskCard(task, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
        );
        await taskViewModel.fetchTasks(force: true);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.taskName,
                    style: TextStyle(fontSize: 14.sp, fontFamily: 'Figtree'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Due: ${task.dueDate.toLocal().toString().split(" ")[0]}',
                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Figtree'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
