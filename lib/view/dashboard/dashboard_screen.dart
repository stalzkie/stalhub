// START of DashboardScreen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../view_model/dashboard/dashboard_view_model.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/floating_global_menu.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..fetchDashboardData(),
          child: Consumer<DashboardViewModel>(
            builder: (context, vm, _) {
              final currencyFormatter = NumberFormat('#,##0.00', 'en_US');
              return Scaffold(
                backgroundColor: const Color(0xFFF9F9F9),
                body: SafeArea(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          top: 24.h,
                          bottom: 4.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Tasks Due Today
                            Container(
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
                                    'Tasks Due Today',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.sp,
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    vm.tasksDueToday.length.toString(),
                                    style: TextStyle(
                                      fontSize: 34.sp,
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            // 📈 Growth Graph (Line Chart Version)
                            Container(
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
                                    'Growth Graph',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.sp,
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Container(
                                    height: 200.h,
                                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15.r),
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: 12 * 40.w,
                                        child: LineChart(
                                          LineChartData(
                                            lineTouchData: LineTouchData(
                                              handleBuiltInTouches: true,
                                              touchTooltipData: LineTouchTooltipData(
                                              getTooltipColor: (LineBarSpot touchedSpot) => Colors.black,
                                              tooltipRoundedRadius: 8,
                                              tooltipPadding: const EdgeInsets.all(8),
                                              tooltipMargin: 8,
                                              fitInsideHorizontally: true,
                                              fitInsideVertically: true,
                                              getTooltipItems: (touchedSpots) {
                                                return touchedSpots.map((spot) {
                                                  final index = spot.x.toInt();
                                                  final month = [
                                                    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                                  ][index];
                                                  return LineTooltipItem(
                                                    '$month\nP${currencyFormatter.format(spot.y)}',
                                                    const TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Figtree',
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  );
                                                }).toList();
                                              },
                                            ),
                                              touchCallback: (event, response) {
                                                if (!_isDialogOpen &&
                                                    event is FlTapUpEvent &&
                                                    response != null &&
                                                    response.lineBarSpots != null &&
                                                    response.lineBarSpots!.isNotEmpty) {
                                                  _isDialogOpen = true;
                                                  final spot = response.lineBarSpots!.first;
                                                  final index = spot.x.toInt();
                                                  final amount = vm.monthlySales[index];
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                      contentPadding: const EdgeInsets.all(20),
                                                      backgroundColor: Colors.white,
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            'Sales in ${[
                                                              'January', 'February', 'March', 'April', 'May', 'June',
                                                              'July', 'August', 'September', 'October', 'November', 'December'
                                                            ][index]}',
                                                            style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w600,
                                                              fontFamily: 'Figtree',
                                                            ),
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Text(
                                                            'P ${currencyFormatter.format(amount)}',
                                                            style: const TextStyle(
                                                              fontSize: 24,
                                                              fontFamily: 'Figtree',
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ).then((_) => _isDialogOpen = false);
                                                }
                                              },
                                            ),
                                            minX: -0.2,
                                            maxX: 11.5,
                                            gridData: const FlGridData(show: false),
                                            borderData: FlBorderData(show: false),
                                            titlesData: FlTitlesData(
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (value, _) {
                                                    const months = [
                                                      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June',
                                                      'July', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                                    ];
                                                    if (value < 0 || value > 11) return const SizedBox.shrink();
                                                    return Padding(
                                                      padding: EdgeInsets.only(top: 4.h),
                                                      child: Text(
                                                        months[value.toInt()],
                                                        style: TextStyle(
                                                          fontSize: 10.sp,
                                                          fontFamily: 'Figtree',
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  reservedSize: 28,
                                                ),
                                              ),
                                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            ),
                                            minY: -0,
                                            maxY: (vm.monthlySales.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble(),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: List.generate(12, (i) => FlSpot(i.toDouble(), vm.monthlySales[i])),
                                                isCurved: true,
                                                dotData: const FlDotData(show: true),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      const Color(0xFFFF7240).withOpacity(0.3),
                                                      const Color(0xFFFF7240).withOpacity(0.0),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                                color: const Color(0xFFFF7240),
                                                barWidth: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            // 📅 Date Filter
                            Container(
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
                                          color: isSelected ? Colors.black : Colors.black.withAlpha(128),
                                          fontSize: 14.sp,
                                          fontFamily: 'Figtree',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // 📊 Task Stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _FigmaStat(label: 'Orders', value: vm.totalTasks),
                                _FigmaStat(label: 'Working', value: vm.workingTasks),
                                _FigmaStat(label: 'Delays', value: vm.delayedTasks),
                              ],
                            ),
                            SizedBox(height: 20.h),

                            // 💰 Sales Summary
                            Container(
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
                                    'Sales',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.sp,
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Row(
                                    children: [
                                      Text(
                                        'P',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 24.sp,
                                          fontFamily: 'Figtree',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        currencyFormatter.format(vm.totalSales),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 24.sp,
                                          fontFamily: 'Figtree',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 14.h),
                          ],
                        ),
                      ),
                      // 🧱 Invisible barrier behind the nav bar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Container(
                            height: 78.h,
                            color: Colors.transparent,
                          ),
                        ),
                      ),

                      // 🌐 Floating Menu Button
                      const FloatingMenuButton(),
                    ],
                  ),
                ),

                // 🧭 Bottom Navigation Bar
                bottomNavigationBar: Container(
                  height: 78.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 2, color: Colors.black12)],
                  ),
                  child: CustomBottomNavigation(
                    currentIndex: 0,
                    onTap: (index) {
                      switch (index) {
                        case 1:
                          Navigator.pushNamed(context, '/invoices');
                          break;
                        case 2:
                          Navigator.pushNamed(context, '/tasks');
                          break;
                        case 3:
                          Navigator.pushNamed(context, '/tickets');
                          break;
                        case 4:
                          Navigator.pushNamed(context, '/profile');
                          break;
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
class _FigmaStat extends StatelessWidget {
  final String label;
  final int value;

  const _FigmaStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84.w,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.sp,
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.sp,
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
