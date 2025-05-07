import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stalhub/main.dart';

class FloatingMenuButton extends StatefulWidget {
  const FloatingMenuButton({super.key});

  @override
  State<FloatingMenuButton> createState() => _FloatingMenuButtonState();
}

class _FloatingMenuButtonState extends State<FloatingMenuButton> {
  Offset position = const Offset(300, 600);

  void _openMenu() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => Center(
        child: Container(
          width: 320.w,
          height: 360.h,
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F1F),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // First row: Add Invoice
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _menuItem('Add Invoice', 'assets/images/add-invoice.png', '/add-invoice'),
                ],
              ),
              // Second row: Add Tickets - Add Tasks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _menuItem('Add Tickets', 'assets/images/add-tickets-icon.png', '/add-ticket'),
                  _menuItem('Add Tasks', 'assets/images/add-tasks-icon.png', '/add-task'),
                ],
              ),
              SizedBox(height: 12.h),
              // Third row: Sales - Task Analytics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _menuItem('Sales\nAnalytics', 'assets/images/invoices-icon.png', '/sales'),
                  _menuItem('Task\nAnalytics', 'assets/images/sales-analytics.png', '/task-analytics'),
                ],
              ),
              // Close Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Column(
                  children: [
                    Image.asset('assets/images/close-icon.png', width: 40.w),
                    SizedBox(height: 4.h),
                    Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(String label, String iconPath, String route) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);

        // Navigate and wait for result
        await navigatorKey.currentState?.pushNamed(route);

        // After return, refresh relevant screen if it’s active
        if (route == '/add-invoice' || route == '/add-ticket' || route == '/add-task') {
          navigatorKey.currentState?.context.findAncestorStateOfType<State>()?.setState(() {});
        }
      },
      child: Column(
        children: [
          Image.asset(iconPath, width: 45.w, height: 45.w),
          SizedBox(height: 1.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final navBarHeight = 78.h;
    final buttonHeight = 70.h;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
            position = Offset(
              position.dx.clamp(0.0, screen.width - 70.w),
              position.dy.clamp(0.0, screen.height - navBarHeight - safeBottom - buttonHeight),
            );
          });
        },
        onTap: _openMenu,
        child: Image.asset(
          'assets/images/menu-button.png',
          width: 56.w,
        ),
      ),
    );
  }
}
