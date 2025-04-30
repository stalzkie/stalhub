import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stalhub/view/tasks/edit_task_screen.dart';
import 'package:stalhub/view/widgets/status_indicator.dart';
import '../../view_model/tasks/task_view_model.dart';
import '../../view_model/auth/login_view_model.dart'; // ✅ Add this for userId & playerId

class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get userId and playerId from LoginViewModel
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userId = loginVM.loggedInUser?.id ?? '';
    final playerId = loginVM.loggedInUser?.playerId ?? '';

    return ChangeNotifierProvider(
      create: (_) => TaskViewModel(userId: userId, playerId: playerId)..fetchTasks(),
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

          return ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, __) => Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/stalwrites-logo.png',
                      width: 122.11.w,
                      height: 68.69.h,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20.h),
                    _buildFilterBar(vm),
                    SizedBox(height: 16.h),
                    _buildHeader(),
                    SizedBox(height: 10.h),
                    _buildSearchBar(vm),
                    SizedBox(height: 10.h),
                    _buildTaskList(tasks, context),
                    SizedBox(height: 10.h),
                    _buildBottomButtons(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(TaskViewModel vm) {
    return Container(
      height: 42.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 26, 26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: DateFilter.values.map((filter) {
          final isSelected = vm.selectedFilter == filter;
          final label = {
            DateFilter.today: 'Today',
            DateFilter.week: 'Week',
            DateFilter.month: 'Month',
            DateFilter.all: 'All Time',
          }[filter]!;
          return GestureDetector(
            onTap: () => vm.setFilter(filter),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                    )
                  : null,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Figtree',
                  color: isSelected ? const Color.fromARGB(255, 26, 26, 26) : Colors.white,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'All Tasks',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Figtree',
          decoration: TextDecoration.underline,
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
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: vm.updateSearchQuery,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List tasks, BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.topCenter,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: tasks.length,
          itemBuilder: (_, index) {
            final task = tasks[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTaskScreen(task: task),
                ),
              ),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 6.h),
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black.withAlpha(128), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Task ID: ${task.id}',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Figtree',
                          ),
                        ),
                        StatusIndicator(status: task.status),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(task.taskName, style: TextStyle(fontSize: 14.sp)),
                    SizedBox(height: 4.h),
                    Text('Due: ${task.dueDate.toLocal().toString().split(" ")[0]}', style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 64.w,
            height: 64.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black.withAlpha(128), width: 2),
            ),
            child: const Text('←', style: TextStyle(fontSize: 32)),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/add-task'),
            child: Container(
              height: 64.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 26, 26, 26),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Text(
                'Add Task',
                style: TextStyle(fontSize: 20, fontFamily: 'Figtree', color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
