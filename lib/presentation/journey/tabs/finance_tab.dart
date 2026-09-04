import 'package:flutter/material.dart';

/// Tab 4: Finance Tab (Budget Tracker & Split Expenses)
///
/// Dedicated file for teammate to implement the Finance view.
class FinanceTab extends StatelessWidget {
  final String destination;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const FinanceTab({
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
    // TODO: Teammate to implement the Finance view here.
    return const SizedBox();
  }
}
