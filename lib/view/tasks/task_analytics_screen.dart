import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../view_model/tasks/task_analytics_view_model.dart';

class TaskAnalyticsScreen extends StatelessWidget {
  const TaskAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskAnalyticsViewModel()..fetchTasks(),
      child: Consumer<TaskAnalyticsViewModel>(
        builder: (context, vm, _) {
          final best = vm.bestMonth;
          return ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, __) => Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/stalwrites-logo.png',
                      width: 122.11.w,
                      height: 68.69.h,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20.h),

                    // Filter Bar
                    Container(
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
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      border: Border.all(color: Colors.black, width: 1),
                                      borderRadius: BorderRadius.circular(5),
                                    )
                                  : null,
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Figtree',
                                  color: isSelected ? const Color.fromARGB(255, 26, 26, 26) : const Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Orders, Working, Delays
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatBox(label: 'Orders', value: vm.totalTasks),
                        _StatBox(label: 'Working', value: vm.workingTasks),
                        _StatBox(label: 'Delays', value: vm.delayedTasks),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Most Productive Writer
                    _InfoBox(
                      title: 'Most Productive Writer',
                      left: vm.topWriterName,
                      right: '${vm.topWriterPercentage.toStringAsFixed(1)}%',
                    ),
                    SizedBox(height: 10.h),

                    // Most Popular Platform
                    _InfoBox(
                      title: 'Most Popular Platform',
                      left: vm.mostPopularPlatform,
                      right: '${vm.mostPopularPlatformPercentage.toStringAsFixed(1)}%',
                    ),
                    SizedBox(height: 10.h),

                    // Productivity Rate & Comparison
                    Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            title: 'Productivity Rate',
                            left: '+',
                            right: '${vm.productivityRate.toStringAsFixed(1)}%',
                            highlightLeft: Colors.green,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _InfoBox(
                            title: 'Tasks Comparison\nvs Previous',
                            left: vm.comparisonWithPrevious >= 0 ? '+' : '-',
                            right: '${vm.comparisonWithPrevious.abs().toStringAsFixed(1)}%',
                            highlightLeft: vm.comparisonWithPrevious >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Most Frequent Client
                    _InfoBox(
                      title: 'Most Frequent Client',
                      left: vm.frequentClientName,
                      right: '${vm.frequentClientOrderCount} Orders',
                    ),
                    SizedBox(height: 10.h),

                    // Best Month
                    _InfoBox(
                      title: 'Your Best Month',
                      left: best.isNotEmpty ? '${_monthName(int.parse(best['month']))} ${best['year']}' : '-',
                      right: best.isNotEmpty ? '${best['count']} Orders' : '',
                    ),
                    const Spacer(),

                    // Navigation
                    Row(
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
                                style: TextStyle(fontSize: 20, fontFamily: 'Figtree', color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
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

class _InfoBox extends StatelessWidget {
  final String title;
  final String left;
  final String right;
  final Color? highlightLeft;

  const _InfoBox({
    required this.title,
    required this.left,
    required this.right,
    this.highlightLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Figtree',
                  color: Colors.black.withAlpha(128))),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                left,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Figtree',
                  color: highlightLeft ?? Colors.black,
                ),
              ),
              Text(
                right,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Figtree',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
