import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': 'assets/images/dashboard-icon.png', 'label': 'Dashboard'},
      {'icon': 'assets/images/wallet-icon.png', 'label': 'Invoices'},
      {'icon': 'assets/images/tasks-icon.png', 'label': 'Tasks'},
      {'icon': 'assets/images/client-icon.png', 'label': 'Tickets'},
      {'icon': 'assets/images/profile-icon.png', 'label': 'Profile'},
    ];

    return Container(
      height: 70.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      color: Colors.white, // Removed decoration
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = index == currentIndex;
          final color = isSelected ? const Color(0xFFFF7240) : Colors.grey;

          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                child: Image.asset(
                  items[index]['icon']!,
                  width: 28.w,
                  height: 28.w,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
