import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:stalhub/view/sales/edit_invoice_screen.dart';
import 'package:stalhub/view_model/auth/login_view_model.dart';
import 'package:stalhub/view_model/sales/invoice_view_model.dart';
import 'package:stalhub/view/widgets/custom_bottom_navigation.dart';
import 'package:stalhub/view/widgets/status_indicator.dart';

class AllInvoicesScreen extends StatelessWidget {
  const AllInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    final userId = loginViewModel.loggedInUser?.id ?? '';
    final playerId = loginViewModel.loggedInUser?.playerId;

    return ChangeNotifierProvider(
      create: (_) => InvoiceViewModel(userId: userId, playerId: playerId)..fetchInvoices(),
      child: Consumer<InvoiceViewModel>(
        builder: (context, vm, _) {
          final q = vm.searchQuery.toLowerCase();

          final invoices = vm.filteredInvoices.where((invoice) {
            final isExactStatusMatch = (q == 'paid' || q == 'unpaid') &&
                invoice.status.toLowerCase() == q;

            final matchesOtherFields = invoice.id.toString().contains(q) ||
                invoice.clientName.toLowerCase().contains(q) ||
                invoice.platform.toLowerCase().contains(q);

            return isExactStatusMatch || matchesOtherFields;
          }).toList();

          return ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, __) => Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: EdgeInsets.fromLTRB(25.w, 40.h, 25.w, 10.h),
                child: Column(
                  children: [
                    Image.asset('assets/images/stalwrites-logo.png', width: 122.w, height: 69.h),
                    SizedBox(height: 20.h),
                    _buildFilterBar(vm),
                    SizedBox(height: 16.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'All Invoices',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Figtree',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _buildSearchBar(vm),
                    SizedBox(height: 10.h),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: invoices.length,
                          itemBuilder: (_, index) {
                            final invoice = invoices[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditInvoiceScreen(invoice: invoice),
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
                                          'Transaction ID: ${invoice.id}',
                                          style: TextStyle(
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Figtree',
                                          ),
                                        ),
                                        StatusIndicator(status: invoice.status),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(invoice.clientName, style: TextStyle(fontSize: 14.sp)),
                                        Text('P${invoice.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 14.sp)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
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
                            onTap: () => Navigator.pushNamed(context, '/add-invoice'),
                            child: Container(
                              height: 64.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 26, 26, 26),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: const Text(
                                'Add Invoice',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Figtree',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              bottomNavigationBar: CustomBottomNavigation(
                currentIndex: 1,
                onTap: (index) {
                  final routes = ['/dashboard', '/sales', '/tasks', '/tickets', '/profile'];
                  if (index != 1) {
                    Navigator.pushNamed(context, routes[index]);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(InvoiceViewModel vm) {
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
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
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

  Widget _buildSearchBar(InvoiceViewModel vm) {
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
                hintText: 'Search invoices...',
                hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
