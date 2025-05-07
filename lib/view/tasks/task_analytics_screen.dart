import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stalhub/view_model/tasks/task_analytics_view_model.dart';
import 'package:stalhub/view/widgets/floating_global_menu.dart';

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
              backgroundColor: const Color(0xFFF9F9F9),
              body: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.w, 40.h, 25.w, 30.h),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back Button
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

                          // Filter Bar
                          Container(
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
                                  DateFilter.all: 'All Time',
                                }[filter]!;
                                return GestureDetector(
                                  onTap: () => vm.setFilter(filter),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                    decoration: isSelected
                                        ? BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5.r),
                                          )
                                        : null,
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Figtree',
                                        fontWeight: FontWeight.w400,
                                        color: isSelected ? Colors.black : Colors.black.withAlpha(128),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Orders, Working, Delays
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatBox(label: 'Orders', value: vm.totalTasks),
                              _StatBox(label: 'Working', value: vm.workingTasks),
                              _StatBox(label: 'Delays', value: vm.delayedTasks),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          _InfoCard(
                            title: 'Most Productive Writer',
                            left: vm.topWriterName,
                            right: '${vm.topWriterPercentage.toStringAsFixed(1)}%',
                          ),
                          SizedBox(height: 16.h),

                          _InfoCard(
                            title: 'Most Popular Platform',
                            left: vm.mostPopularPlatform,
                            right: '${vm.mostPopularPlatformPercentage.toStringAsFixed(1)}%',
                          ),
                          SizedBox(height: 16.h),

                          Row(
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  title: 'Productivity Rate',
                                  left: '+',
                                  right: '${vm.productivityRate.toStringAsFixed(1)}%',
                                  highlightLeft: Colors.green,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: _InfoCard(
                                  title: 'Tasks Comparison\nvs Previous',
                                  left: vm.comparisonWithPrevious >= 0 ? '+' : '-',
                                  right: '${vm.comparisonWithPrevious.abs().toStringAsFixed(1)}%',
                                  highlightLeft: vm.comparisonWithPrevious >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          _InfoCard(
                            title: 'Most Frequent Client',
                            left: vm.frequentClientName,
                            right: '${vm.frequentClientOrderCount} Orders',
                          ),
                          SizedBox(height: 16.h),

                          _InfoCard(
                            title: 'Your Best Month',
                            left: best.isNotEmpty
                                ? '${_monthName(int.parse(best['month']))} ${best['year']}'
                                : '-',
                            right: best.isNotEmpty ? '${best['count']} Orders' : '',
                          ),
                          SizedBox(height: 0.h),
                        ],
                      ),
                    ),
                  ),
                  const FloatingMenuButton(), // ✅ Floating Assistive Menu
                ],
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
        Text(
          label,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500, fontFamily: 'Figtree'),
        ),
        Text(
          value.toString(),
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500, fontFamily: 'Figtree'),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String left;
  final String right;
  final Color? highlightLeft;

  const _InfoCard({
    required this.title,
    required this.left,
    required this.right,
    this.highlightLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Figtree',
              color: const Color.fromARGB(255, 173, 173, 173),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                left,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Figtree',
                  color: highlightLeft ?? Colors.black,
                ),
              ),
              Text(
                right,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Figtree',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
