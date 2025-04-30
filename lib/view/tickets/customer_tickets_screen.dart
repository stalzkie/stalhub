import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:stalhub/view_model/tickets/ticket_view_model.dart';
import 'package:stalhub/view/widgets/status_indicator.dart';
import 'package:stalhub/view/widgets/custom_bottom_navigation.dart';
import 'package:stalhub/view/tickets/edit_ticket_screen.dart';
import '../../view_model/auth/login_view_model.dart'; // ✅ For userId & playerId

class CustomerTicketsScreen extends StatefulWidget {
  const CustomerTicketsScreen({super.key});

  @override
  State<CustomerTicketsScreen> createState() => _CustomerTicketsScreenState();
}

class _CustomerTicketsScreenState extends State<CustomerTicketsScreen> {
  @override
  Widget build(BuildContext context) {
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userId = loginVM.loggedInUser?.id ?? '';
    final playerId = loginVM.loggedInUser?.playerId ?? '';

    return ChangeNotifierProvider(
      create: (_) => TicketViewModel(userId: userId, playerId: playerId)..fetchTickets(), // ✅ Inject here
      child: Consumer<TicketViewModel>(
        builder: (context, vm, _) {
          final tickets = vm.searchResults;

          return ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, __) => Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: EdgeInsets.fromLTRB(25.w, 40.h, 25.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/stalwrites-logo.png', width: 122, height: 68),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pending Tickets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                          SizedBox(height: 10.h),
                          Text(
                            vm.pendingCount.toString(),
                            style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildFilterBar(vm),
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/all-tickets'),
                      child: Text(
                        'All Customer Tickets',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Figtree',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      height: 40.h,
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF525252),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: TextField(
                        onChanged: vm.updateSearchQuery,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search tickets...',
                          hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: tickets.length,
                          itemBuilder: (_, index) {
                            final ticket = tickets[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditTicketScreen(ticket: ticket),
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
                                    Text(ticket.clientName, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600)),
                                    SizedBox(height: 6.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Date Sent: ${ticket.createdAt.toLocal().toString().split(" ")[0]}'),
                                        StatusIndicator(status: ticket.status),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/add-ticket'),
                      child: Container(
                        width: double.infinity,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 26, 26, 26),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Text(
                          'Add Customer Ticket',
                          style: TextStyle(fontSize: 20, fontFamily: 'Figtree', fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: CustomBottomNavigation(
                currentIndex: 3,
                onTap: (index) {
                  final routes = ['/dashboard', '/sales', '/tasks', '/tickets', '/profile'];
                  if (index != 3) Navigator.pushNamed(context, routes[index]);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(TicketViewModel vm) {
    return Container(
      height: 42.h,
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
                  fontSize: 14,
                  fontFamily: 'Figtree',
                  color: isSelected ? const Color.fromARGB(255, 26, 26, 26) : Colors.white,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
