import 'package:flutter/material.dart';

/// Tab 2: Bookings Tab (Flights, Hotels, Transport, Activities)
///
/// Dedicated file for teammate to implement the Bookings view.
class BookingsTab extends StatelessWidget {
  final String destination;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const BookingsTab({
    super.key,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Group Trip',
    this.startDate,
    this.endDate,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Teammate to implement the Bookings view here.
    return const SizedBox();
  }
}
