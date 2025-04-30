import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../view_model/tasks/task_view_model.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/status_indicator.dart';
import '../../view_model/auth/login_view_model.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  int currentIndex = 2;

  void onTabTapped(int index) {
    setState(() => currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/sales');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushNamed(context, '/tickets');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.fromLTRB(25.w, 40.h, 25.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/stalwrites-logo.png', width: 122.11.w, height: 68.69.h),
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
                    _buildTaskList(tasks),
                    SizedBox(height: 6.h),
                    _buildBottomButtons(context, vm),
                  ],
                ),
              ),
              bottomNavigationBar: CustomBottomNavigation(
                currentIndex: currentIndex,
                onTap: onTabTapped,
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
      width: double.infinity,
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
            DateFilter.all: 'All Time'
          }[filter]!;
          return GestureDetector(
            onTap: () => vm.setFilter(filter),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: isSelected
                  ? BoxDecoration(
                      color: const Color.fromARGB(255, 252, 252, 252),
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(5),
                    )
                  : null,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color.fromARGB(255, 26, 26, 26) : Colors.white,
                  fontSize: 14,
                  fontFamily: 'Figtree',
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
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Most Productive Writer', style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w600,
            color: Colors.black.withAlpha(128),
          )),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(vm.topWriterName, style: TextStyle(
                fontSize: 24.sp,
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w600,
              )),
              Text('${vm.topWriterPercentage.toStringAsFixed(1)}%', style: TextStyle(
                fontSize: 24.sp,
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w600,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllTasksTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/all-tasks'),
          child: Text(
            'All Tasks',
            style: TextStyle(
              fontSize: 24.sp,
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
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

  Widget _buildTaskList(List tasks) {
    return Expanded(
      child: Align(
        alignment: Alignment.topCenter,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: tasks.length,
          itemBuilder: (_, index) {
            final task = tasks[index];
            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/edit-task', arguments: task),
              child: Container(
                width: double.infinity,
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
                    Text(task.taskName, style: TextStyle(fontSize: 14.sp), maxLines: null),
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

  Widget _buildBottomButtons(BuildContext context, TaskViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionButton(
          label: 'Analytics',
          color: const Color(0xFFEDEDED),
          onTap: () => Navigator.pushNamed(context, '/task-analytics'),
          textColor: const Color.fromARGB(255, 26, 26, 26),
        ),
        _ActionButton(
          label: 'Add Task',
          color: const Color.fromARGB(255, 26, 26, 26),
          onTap: () async {
            final result = await Navigator.pushNamed(context, '/add-task');
            if (result == true) {
              vm.fetchTasks();  // Refresh tasks after adding
            }
          },
        ),
      ],
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
        Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Figtree')),
        Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Figtree')),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Color textColor;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 161.w,
        height: 64.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black.withAlpha(128), width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            fontFamily: 'Figtree',
            color: textColor,
          ),
        ),
      ),
    );
  }
}
