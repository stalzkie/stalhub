import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:stalhub/view/sales/edit_invoice_screen.dart';
import 'package:stalhub/view_model/auth/login_view_model.dart';
import 'package:stalhub/view_model/sales/invoice_view_model.dart';
import 'package:stalhub/view/widgets/custom_bottom_navigation.dart';
import 'package:stalhub/view/widgets/status_indicator.dart';
import 'package:intl/intl.dart';
import 'package:stalhub/view/widgets/floating_global_menu.dart';

class AllInvoicesScreen extends StatefulWidget {
  const AllInvoicesScreen({super.key});

  @override
  State<AllInvoicesScreen> createState() => _AllInvoicesScreenState();
}

class _AllInvoicesScreenState extends State<AllInvoicesScreen> {
  late InvoiceViewModel invoiceViewModel;

  @override
  void initState() {
    super.initState();
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    invoiceViewModel = InvoiceViewModel(
      userId: loginVM.loggedInUser?.id ?? '',
      playerId: loginVM.loggedInUser?.playerId,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      invoiceViewModel.fetchInvoices(force: true);
    });
  }

  Future<void> _onRefresh() async {
    await invoiceViewModel.fetchInvoices(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: invoiceViewModel,
      child: Consumer<InvoiceViewModel>(
        builder: (context, vm, _) {
          final q = vm.searchQuery.toLowerCase();
          final invoices = vm.filteredInvoices.where((invoice) {
            final isExactStatusMatch = (q == 'paid' || q == 'unpaid') && invoice.status.toLowerCase() == q;
            final matchesOtherFields = invoice.id.toString().contains(q) ||
                invoice.clientName.toLowerCase().contains(q) ||
                invoice.platform.toLowerCase().contains(q);
            return isExactStatusMatch || matchesOtherFields;
          }).toList();

          return Scaffold(
            backgroundColor: const Color(0xFFF9F9F9),
            body: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(25.w, 40.h, 25.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      _buildFilterBar(vm),
                      SizedBox(height: 16.h),
                      Text(
                        'All Invoices',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Figtree',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _buildSearchBar(vm),
                      SizedBox(height: 10.h),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 20.h),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: invoices.length,
                            itemBuilder: (context, index) {
                              final invoice = invoices[index];
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditInvoiceScreen(invoice: invoice),
                                    ),
                                  );
                                  await invoiceViewModel.fetchInvoices(force: true);
                                },
                                child: _buildInvoiceCard(invoice),
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
              currentIndex: 1,
              onTap: (index) {
                final routes = ['/dashboard', '/invoices', '/tasks', '/tickets', '/profile'];
                if (index != 1) Navigator.pushNamed(context, routes[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvoiceCard(invoice) {
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
                  ? BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.r))
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

  Widget _buildSearchBar(InvoiceViewModel vm) {
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
