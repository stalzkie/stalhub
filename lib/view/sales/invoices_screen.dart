import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stalhub/view/widgets/custom_bottom_navigation.dart';
import 'package:stalhub/view/widgets/status_indicator.dart';
import 'package:stalhub/view_model/sales/invoice_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<InvoiceViewModel>(context, listen: false);
      vm.fetchInvoices();
    });
  }

  void onTabTapped(int index) {
    final routes = ['/dashboard', '/sales', '/tasks', '/tickets', '/profile'];
    if (index != currentIndex) {
      Navigator.pushNamed(context, routes[index]);
      setState(() => currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceViewModel>(
      builder: (context, vm, _) {
        final invoices = vm.filteredInvoices.where((invoice) {
          final query = vm.searchQuery.toLowerCase();
          return invoice.id.toString().contains(query) ||
              invoice.clientName.toLowerCase().contains(query) ||
              invoice.platform.toLowerCase().contains(query) ||
              invoice.status.toLowerCase() == query;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.fromLTRB(25.w, 40.h, 25.w, 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/stalwrites-logo.png', width: 122.w, height: 69.h),
                SizedBox(height: 20.h),
                _buildFilterBar(vm),
                SizedBox(height: 16.h),
                _analyticsCard('Most Valuable Client', vm.topClientName, vm.topClientPercentage),
                SizedBox(height: 10.h),
                _analyticsCard('Most Popular Platform', vm.topPlatformName, vm.topPlatformPercentage),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/all-invoices'),
                      child: Text(
                        'All Invoices',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _searchBar(vm),
                SizedBox(height: 10.h),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 5.h),
                    itemCount: invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = invoices[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/edit-invoice',
                            arguments: invoice,
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(color: Colors.black.withAlpha(128), width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Transaction ID: ${invoice.id}',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Figtree',
                                      ),
                                    ),
                                  ),
                                  StatusIndicator(status: invoice.status),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      invoice.clientName,
                                      style: TextStyle(fontSize: 14.sp),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    'P${invoice.price.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10.h),
                const Buttons(),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: currentIndex,
            onTap: onTabTapped,
          ),
        );
      },
    );
  }

  Widget _buildFilterBar(InvoiceViewModel vm) {
    return Container(
      height: 42.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 26, 26),
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
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5.r),
                    )
                  : null,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color.fromARGB(255, 26, 26, 26) : Colors.white,
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

  Widget _analyticsCard(String title, String name, double percentage) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Figtree',
                color: Colors.black.withAlpha(128),
              )),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(name,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Figtree',
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
              Text('${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Figtree',
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchBar(InvoiceViewModel vm) {
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
                hintText: 'Search invoices...',
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

class Buttons extends StatelessWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        children: [
          SizedBox(
            width: 64.w,
            height: 64.h,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/sales'),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEDED),
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: Colors.black.withAlpha(128), width: 2),
                ),
                child: Text(
                  '←',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32.sp,
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w500,
                  ),
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
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w500,
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
