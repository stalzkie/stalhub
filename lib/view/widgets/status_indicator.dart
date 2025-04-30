import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final String status;

  const StatusIndicator({super.key, required this.status});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFFAEFFC5); // Green
      case 'working':
        return const Color(0xFFFCFF9E); // Yellow
      case 'quality checking':
        return const Color(0xFFA1D0FF); // Blue tint
      case 'postponed':
        return const Color(0xFFE0E0E0); // Gray
      case 'revision':
        return const Color(0xFFFFD6A1); // Orange-ish
      case 'discarded':
        return const Color(0xFFFFB4B4); // Red
      case 'to be assigned':
        return const Color(0xFFC1C1FF); // Lavender
      case 'to be delivered':
        return const Color(0xFFB3F1FF); // Aqua-light
      case 'paid':
        return const Color.fromARGB(255, 231, 255, 158); // ✅ Green for paid invoices
      case 'unpaid':
        return const Color.fromARGB(255, 255, 136, 103); // ✅ Pale red for unpaid invoices
      case 'not read':
        return const Color(0xFFFFD6A1);
      case 'ongoing':
        return const Color(0xFFFCFF9E);
      case 'resolved':
        return const Color.fromARGB(255, 231, 255, 158);
      case 'discarded':
        return const Color(0xFFFFB4B4);
      default:
        return const Color(0xFFDDDDDD); // Neutral fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: getStatusColor(status),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Color.fromARGB(255, 26, 26, 26),
          fontSize: 14,
          fontFamily: 'Figtree',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
