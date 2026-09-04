import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Independent Navbar lying between the cream sheet and the hero card.
/// Features 5 tabs with icons, labels, and consistent on-tab indicator lines.
class TripDetailsNavBar extends StatelessWidget {
  final int activeTabIndex;
  final ValueChanged<int> onTabSelected;
  final Color brandOrange;
  final Color textMuted;

  const TripDetailsNavBar({
    super.key,
    required this.activeTabIndex,
    required this.onTabSelected,
    this.brandOrange = const Color(0xFFE65100),
    this.textMuted = const Color(0xFF6B5A50),
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'label': 'Chat', 'type': 'chat'},
      {'label': 'Trip', 'icon': Icons.calendar_month_outlined},
      {'label': 'Bookings', 'icon': Icons.shopping_bag_outlined},
      {'label': 'Diary', 'icon': Icons.menu_book_rounded},
      {'label': 'Finance', 'icon': Icons.paid_outlined},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final isSelected = activeTabIndex == index;
          final tab = tabs[index];
          final label = tab['label'] as String;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                onTabSelected(index);
                HapticFeedback.selectionClick();
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 64.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Tab Icon (fixed 22px height)
                    SizedBox(
                      height: 22,
                      child: Center(
                        child: (tab['type'] == 'chat')
                            ? _buildChatPinIcon(
                                isSelected ? brandOrange : textMuted,
                                isSelected,
                              )
                            : Icon(
                                tab['icon'] as IconData,
                                size: 22,
                                color: isSelected ? brandOrange : textMuted,
                              ),
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Tab Label (fixed 14px height)
                    SizedBox(
                      height: 14,
                      child: Center(
                        child: Text(
                          label,
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected ? brandOrange : textMuted,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Consistent on-tab indicator line across all tabs
                    Container(
                      width: 34,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: isSelected ? brandOrange : Colors.transparent,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Speech bubble chat icon with white center dot matching the design
  Widget _buildChatPinIcon(Color color, bool isSelected) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            isSelected
                ? Icons.chat_bubble_rounded
                : Icons.chat_bubble_outline_rounded,
            size: 22,
            color: color,
          ),
          if (isSelected)
            Container(
              width: 6.0,
              height: 6.0,
              margin: const EdgeInsets.only(bottom: 2.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
