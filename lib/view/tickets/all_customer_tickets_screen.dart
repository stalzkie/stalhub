import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:stalhub/view/tickets/edit_ticket_screen.dart';
import 'package:stalhub/view/widgets/status_indicator.dart';
import 'package:stalhub/view/widgets/floating_global_menu.dart';
import 'package:stalhub/view/widgets/custom_bottom_navigation.dart';
import '../../view_model/tickets/ticket_view_model.dart';
import '../../view_model/auth/login_view_model.dart';

class AllCustomerTicketsScreen extends StatefulWidget {
  const AllCustomerTicketsScreen({super.key});

  @override
  State<AllCustomerTicketsScreen> createState() => _AllCustomerTicketsScreenState();
}

class _AllCustomerTicketsScreenState extends State<AllCustomerTicketsScreen> {
  late TicketViewModel ticketViewModel;

  @override
  void initState() {
    super.initState();
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    ticketViewModel = TicketViewModel(
      userId: loginVM.loggedInUser?.id ?? '',
      playerId: loginVM.loggedInUser?.playerId ?? '',
    );
    ticketViewModel.fetchTickets(force: true);
  }

  Future<void> _onRefresh() async {
    await ticketViewModel.fetchTickets(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ticketViewModel,
      child: Consumer<TicketViewModel>(
        builder: (context, vm, _) {
          final tickets = vm.filteredByDate.where((ticket) {
            final q = vm.searchQuery.toLowerCase();
            return ticket.id.toString().contains(q) ||
                ticket.clientName.toLowerCase().contains(q) ||
                ticket.platform.toLowerCase().contains(q) ||
                ticket.status.toLowerCase() == q;
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
                      SizedBox(height: 16.h),
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
                        'All Customer Tickets',
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
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 20.h),
                            itemCount: tickets.length,
                            itemBuilder: (context, index) {
                              final ticket = tickets[index];
                              return _buildTicketCard(ticket, context);
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
              currentIndex: 3,
              onTap: (index) {
                final routes = ['/dashboard', '/invoices', '/tasks', '/tickets', '/profile'];
                if (index != 3) Navigator.pushNamed(context, routes[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(TicketViewModel vm) {
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
            DateFilter.all: 'All Time',
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
                  fontSize: 14.sp,
                  fontFamily: 'Figtree',
                  color: isSelected ? Colors.black : Colors.black.withAlpha(128),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar(TicketViewModel vm) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: const Color(0xFF525252),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: TextField(
        onChanged: vm.updateSearchQuery,
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Search tickets...',
          hintStyle: TextStyle(color: Colors.white.withAlpha(128), fontSize: 14.sp),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTicketCard(ticket, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditTicketScreen(ticket: ticket)),
        );
        if (mounted) {
          await ticketViewModel.fetchTickets(force: true);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticket.clientName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Figtree',
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Updated: ${ticket.updatedAt?.toLocal().toString().split(" ")[0] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Figtree'),
                ),
                StatusIndicator(status: ticket.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
