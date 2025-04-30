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
    final iconPaths = [
      'assets/images/dashboard-icon.png',
      'assets/images/wallet-icon.png',
      'assets/images/tasks-icon.png',
      'assets/images/client-icon.png',
      'assets/images/profile-icon.png',
    ];

    final highlightColors = [
      const Color.fromARGB(255, 100, 100, 100),
      const Color.fromARGB(255, 100, 100, 100),
      const Color.fromARGB(255, 100, 100, 100),
      const Color.fromARGB(255, 100, 100, 100),
      const Color.fromARGB(255, 100, 100, 100),
    ];

    return Container(
      width: 1.sw,
      height: 78.h,
      padding: EdgeInsets.all(10.h),
      decoration: const BoxDecoration(color: Colors.black),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(iconPaths.length, (index) {
          final isSelected = currentIndex == index;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: isSelected ? highlightColors[index] : Colors.transparent,
              ),
              padding: EdgeInsets.all(6.w),
              child: Image.asset(
                iconPaths[index],
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
          );
        }),
      ),
    );
  }
}