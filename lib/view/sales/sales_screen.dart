import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stalhub/view_model/dashboard/dashboard_view_model.dart';
import 'package:stalhub/view_model/sales/invoice_view_model.dart' as invoice_vm;
import 'package:stalhub/view/widgets/floating_global_menu.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DashboardViewModel()..fetchDashboardData()),
          ChangeNotifierProvider(create: (_) => invoice_vm.InvoiceViewModel(userId: '', playerId: '')..fetchInvoices()),
        ],
        child: Consumer2<DashboardViewModel, invoice_vm.InvoiceViewModel>(
          builder: (context, dashboardVM, invoiceVM, _) {
            final uniqueDays = dashboardVM.filteredInvoices
                .map((e) => '${e.createdAt.year}-${e.createdAt.month}-${e.createdAt.day}')
                .toSet()
                .length;
            final average = uniqueDays > 0 ? dashboardVM.totalSales / uniqueDays : 0.0;

            return Scaffold(
              backgroundColor: const Color(0xFFF9F9F9),
              body: SafeArea(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 24.h),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back button
                            Align(
                              alignment: Alignment.topLeft,
                              child: GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/invoices'),
                                child: Image.asset(
                                  'assets/images/back-button-icon.png',
                                  width: 32.w,
                                  height: 32.w,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            _buildFilterBar(dashboardVM),
                            SizedBox(height: 10.h),

                            _buildCard("Sales", 'P ${NumberFormat("#,##0.00", "en_US").format(dashboardVM.totalSales)}'),
                            SizedBox(height: 10.h),

                            _buildCard("Average Revenue Per Day", 'P ${NumberFormat("#,##0.00", "en_US").format(average)}'),
                            SizedBox(height: 10.h),

                            _buildSalesComparison(dashboardVM.salesComparison),
                            SizedBox(height: 10.h),

                            _buildBestMonth(dashboardVM),
                            SizedBox(height: 10.h),

                            _invoicesSection(dashboardVM.paidInvoices, dashboardVM.unpaidInvoices),
                            SizedBox(height: 10.h),

                            // Most Valuable Client Card (from invoiceVM)
                            _buildCard(
                              'Most Valuable Client',
                              '${dashboardVM.topClientName} - ${dashboardVM.topClientPercentage.toStringAsFixed(1)}%',
                            ),

                            SizedBox(height: 0.h),
                          ],
                        ),
                      ),
                    ),
                    const FloatingMenuButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar(DashboardViewModel vm) {
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
            onTap: () async {
              vm.setFilter(filter);
              await vm.fetchDashboardData();
            },
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
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard(String title, String content) {
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
          Text(
            content,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Figtree',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesComparison(double comparison) {
    final symbol = comparison >= 0 ? '+' : '–';
    return _buildCard(
      'Sales Comparison',
      '$symbol${NumberFormat("#,##0.00", "en_US").format(comparison.abs())}',
    );
  }

  Widget _buildBestMonth(DashboardViewModel vm) {
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
            'Best Month',
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
                '${vm.bestSalesMonth} ${vm.bestSalesYear}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Figtree',
                  color: Colors.black,
                ),
              ),
              Text(
                'P ${NumberFormat("#,##0.00", "en_US").format(vm.bestSalesAmount)}',
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

  Widget _invoicesSection(int paid, int unpaid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoices',
          style: TextStyle(
            color: const Color.fromARGB(255, 156, 156, 156),
            fontSize: 16.sp,
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _invoiceBox('Paid', paid),
            _invoiceBox('Unpaid', unpaid),
          ],
        ),
      ],
    );
  }

  Widget _invoiceBox(String label, int count) {
    return Container(
      width: 161.w,
      height: 80.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color.fromARGB(255, 173, 173, 173),
              fontSize: 16.sp,
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 20.w),
          Text(
            '$count',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.sp,
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
