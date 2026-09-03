import 'package:flutter/material.dart';

/// Segmented tab pill switcher for the Finance Tab.
class FinanceSubNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const FinanceSubNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.brandOrange,
    required this.darkBrown,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'icon': Icons.pie_chart_outline_rounded, 'label': 'Overview'},
      {'icon': Icons.receipt_long_rounded, 'label': 'Expenses'},
      {'icon': Icons.handshake_outlined, 'label': 'Who Owes'},
      {'icon': Icons.currency_exchange_rounded, 'label': 'Converter'},
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3ECE3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5DACD),
          width: 1.0,
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          final tab = tabs[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: darkBrown.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        size: 15,
                        color: isSelected ? brandOrange : textMuted,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          tab['label'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? darkBrown : textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
