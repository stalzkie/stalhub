import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stalhub/view/widgets/custom_bottom_navigation.dart';
import 'package:stalhub/view/widgets/status_indicator.dart';
import 'package:stalhub/view_model/sales/invoice_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stalhub/view/widgets/floating_global_menu.dart';

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
      vm.fetchInvoices(force: true);
    });
  }

  void onTabTapped(int index) {
    final routes = ['/dashboard', '/invoices', '/tasks', '/tickets', '/profile'];
    if (index != currentIndex) {
      Navigator.pushNamed(context, routes[index]);
      setState(() => currentIndex = index);
    }
  }

  Future<void> _onRefresh(BuildContext context) async {
    final vm = Provider.of<InvoiceViewModel>(context, listen: false);
    await vm.fetchInvoices(force: true);
  }

  Widget _buildFilterBar(InvoiceViewModel vm) {
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

  Widget _invoiceCard(invoice) {
    return Container(
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
                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Figtree'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'P${NumberFormat("#,##0.00", "en_US").format(invoice.price)}',
                style: TextStyle(fontSize: 14.sp, fontFamily: 'Figtree'),
              ),
            ],
          ),
        ],
      ),
    );
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
          backgroundColor: const Color(0xFFF9F9F9),
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(25.w, 40.h, 25.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    _buildFilterBar(vm),
                    SizedBox(height: 10.h),
                    _buildCard('Most Valuable Client', '${vm.topClientName} - ${vm.topClientPercentage.toStringAsFixed(1)}%'),
                    SizedBox(height: 10.h),
                    _buildCard('Most Popular Platform', '${vm.topPlatformName} - ${vm.topPlatformPercentage.toStringAsFixed(1)}%'),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/all-invoices'),
                      child: Text(
                        'All Invoices',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Figtree',
                          decoration: TextDecoration.underline,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _searchBar(vm),
                    SizedBox(height: 10.h),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => _onRefresh(context),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 20.h),
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
                              child: _invoiceCard(invoice),
                            );
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
            currentIndex: currentIndex,
            onTap: onTabTapped,
          ),
        );
      },
    );
  }
}
