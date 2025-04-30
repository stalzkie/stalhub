import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stalhub/view_model/dashboard/dashboard_view_model.dart';
import 'package:stalhub/view/widgets/custom_bottom_navigation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final int _currentIndex = 1;

  void _onTap(int index) {
    final routes = ['/dashboard', '/sales', '/tasks', '/tickets', '/profile'];
    if (index != _currentIndex) {
      Navigator.pushNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel()..fetchDashboardData(),
      child: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          final sales = vm.totalSales;
          final paid = vm.paidInvoices;
          final unpaid = vm.unpaidInvoices;
          final diff = vm.salesComparison;
          final bestMonth = vm.bestSalesMonth;
          final bestMonthYear = vm.bestSalesYear;
          final bestMonthSales = vm.bestSalesAmount;

          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(25.w, 20.h, 25.w, 0),
                      child: Column(
                        children: [
                          Image.asset('assets/images/stalwrites-logo.png', width: 122.w, height: 69.h),
                          SizedBox(height: 20.h),
                          _buildFilterBar(vm),
                          SizedBox(height: 20.h),
                          _sectionTitle('Sales'),
                          _salesAmountCard(sales),
                          SizedBox(height: 20.h),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: TitleComparison(),
                          ),
                          _comparisonCard(diff),
                          SizedBox(height: 20.h),
                          YourBestMonth(month: bestMonth, year: bestMonthYear, amount: bestMonthSales),
                          SizedBox(height: 20.h),
                          _sectionTitle('Invoices'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _invoiceCountBox('Paid', paid),
                              _invoiceCountBox('Unpaid', unpaid),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          const Buttons(),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
                  ),
                ),
                CustomBottomNavigation(
                  currentIndex: _currentIndex,
                  onTap: _onTap,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(DashboardViewModel vm) {
    const filters = DateFilter.values;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 26, 26),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: filters.map((filter) {
          final isActive = vm.selectedFilter == filter;
          final label = filter.name[0].toUpperCase() + filter.name.substring(1);
          return GestureDetector(
            onTap: () async {
              vm.setFilter(filter);
              await vm.fetchDashboardData();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(5.r),
                border: isActive ? Border.all(color: Colors.black, width: 1) : null,
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? const Color.fromARGB(255, 26, 26, 26) : Colors.white,
                  fontSize: 14.sp,
                  fontFamily: 'Figtree',
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24.sp,
          fontFamily: 'Figtree',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _salesAmountCard(double amount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Text('P', style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w600)),
          SizedBox(width: 10.w),
          Text(
            NumberFormat("#,##0.00", "en_US").format(amount),
            style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _comparisonCard(double diff) {
    final isPositive = diff >= 0;
    final symbol = isPositive ? '+' : '–';
    final color = isPositive ? Colors.green : const Color(0xFFFF0000);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: _cardDecoration(),
      child: Text(
        '$symbol${NumberFormat("#,##0.00", "en_US").format(diff.abs())}',
        style: TextStyle(fontSize: 32.sp, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _invoiceCountBox(String label, int count) {
    return Container(
      width: 156.w,
      height: 126.h,
      padding: EdgeInsets.all(20.w),
      decoration: ShapeDecoration(
        color: const Color(0xFFEDEDED),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 2, color: Colors.black.withAlpha(128)),
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.sp,
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 10.h),
          Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black.withAlpha(128), width: 2),
      borderRadius: BorderRadius.circular(15.r),
    );
  }
}

class TitleComparison extends StatelessWidget {
  const TitleComparison({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 67.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Comparison',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.sp,
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'vs previous',
            style: TextStyle(
              color: Colors.black.withAlpha(128),
              fontSize: 15.sp,
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class YourBestMonth extends StatelessWidget {
  final String month;
  final int year;
  final double amount;

  const YourBestMonth({super.key, required this.month, required this.year, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: ShapeDecoration(
        color: const Color(0xFFEDEDED),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Best Month',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            children: [
              Text(month, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600)),
              SizedBox(width: 10.w),
              Text('$year', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600)),
              SizedBox(width: 20.w),
              Text(
                'P${NumberFormat("#,##0.00", "en_US").format(amount)}',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Buttons extends StatelessWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/invoices'),
              child: Container(
                height: 64.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEDED),
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: Colors.black.withAlpha(128), width: 2),
                ),
                child: Text(
                  'Invoice',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/add-invoice'),
              child: Container(
                height: 64.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 26, 26, 26),
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: Colors.black.withAlpha(128), width: 2),
                ),
                child: Text(
                  'Add Invoice',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
