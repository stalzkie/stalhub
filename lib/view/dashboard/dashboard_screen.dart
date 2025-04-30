import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../view_model/dashboard/dashboard_view_model.dart';
import '../widgets/custom_bottom_navigation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  void onTabTapped(int index) {
    setState(() => currentIndex = index);
    // You can replace this switch with real route navigation
    switch (index) {
      case 0:
        break; // Current dashboard
      case 1:
        Navigator.pushNamed(context, '/sales');
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
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel()..fetchDashboardData(),
      child: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          return ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (context, child) => Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/stalwrites-logo.png',
                        width: 122.11.w,
                        height: 68.69.h,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 5.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tasks Due Today',
                              style: TextStyle(fontSize: 20, fontFamily: 'Figtree', fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              vm.tasksDueToday.length.toString(),
                              style: const TextStyle(fontSize: 96, fontFamily: 'Figtree', fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 5.h),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/tasks'),
                              child: Container(
                                height: 33.h,
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 34, 34, 34),
                                  border: Border.all(color: const Color.fromARGB(255, 26, 26, 26), width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('Go to tasks →', style: TextStyle(fontSize: 14, fontFamily: 'Figtree', color: Colors.white)),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
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
                                        color: const Color.fromARGB(255, 255, 255, 255),
                                        border: Border.all(color: Colors.black, width: 1),
                                        borderRadius: BorderRadius.circular(5),
                                      )
                                    : null,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: isSelected ? const Color.fromARGB(255, 26, 26, 26) : const Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 14,
                                    fontFamily: 'Figtree',
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sales',
                          style: TextStyle(fontSize: 24, fontFamily: 'Figtree', fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 56.h,
                        width: double.infinity,
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black.withAlpha(128), width: 2),
                        ),
                        child: Row(
                          children: [
                            const Text('P ', style: TextStyle(fontSize: 24, fontFamily: 'Figtree', fontWeight: FontWeight.w600)),
                            Expanded(
                              child: Text(
                              vm.totalSales.toStringAsFixed(2),
                                style: const TextStyle(fontSize: 24, fontFamily: 'Figtree', fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatBox(label: 'Orders', value: vm.totalTasks),
                          _StatBox(label: 'Working', value: vm.workingTasks),
                          _StatBox(label: 'Delays', value: vm.delayedTasks),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Invoices',
                          style: TextStyle(fontSize: 24, fontFamily: 'Figtree', fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _InvoiceBox(title: 'Paid', count: vm.paidInvoices),
                          _InvoiceBox(title: 'Unpaid', count: vm.unpaidInvoices),
                        ],
                      ),
                    ],
                  ),
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
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 20, fontFamily: 'Figtree')),
        Text(value.toString(), style: const TextStyle(fontSize: 20, fontFamily: 'Figtree')),
      ],
    );
  }
}

class _InvoiceBox extends StatelessWidget {
  final String title;
  final int count;

  const _InvoiceBox({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156.w,
      height: 126.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withAlpha(128), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300)),
          const Spacer(),
          Center(
            child: Text(count.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400)),
          )
        ],
      ),
    );
  }
}