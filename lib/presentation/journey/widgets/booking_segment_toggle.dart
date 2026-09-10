import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/booking_models.dart';

/// 3-way animated pill segment toggle: Stays, Flights, and Bullet Trains.
class BookingSegmentToggle extends StatelessWidget {
  final BookingType activeType;
  final ValueChanged<BookingType> onTypeChanged;
  final bool hasStayBooked;
  final bool hasFlightBooked;
  final bool hasTrainBooked;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const BookingSegmentToggle({
    super.key,
    required this.activeType,
    required this.onTypeChanged,
    this.hasStayBooked = false,
    this.hasFlightBooked = false,
    this.hasTrainBooked = false,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF0E5D8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE4D5C5),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pillWidth = (constraints.maxWidth) / 3;
          double pillLeft = 0;
          if (activeType == BookingType.flights) {
            pillLeft = pillWidth;
          } else if (activeType == BookingType.trains) {
            pillLeft = pillWidth * 2;
          }

          return Stack(
            children: [
              // Animated sliding background pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: pillLeft,
                top: 0,
                bottom: 0,
                width: pillWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: brandOrange,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: brandOrange.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),

              // 3 Interactive buttons
              Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      label: '🏨 Stays',
                      isSelected: activeType == BookingType.stays,
                      isBooked: hasStayBooked,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTypeChanged(BookingType.stays);
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      label: '✈️ Flights',
                      isSelected: activeType == BookingType.flights,
                      isBooked: hasFlightBooked,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTypeChanged(BookingType.flights);
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      label: '🚄 Trains',
                      isSelected: activeType == BookingType.trains,
                      isBooked: hasTrainBooked,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTypeChanged(BookingType.trains);
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required bool isBooked,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.fredoka(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : darkBrown.withValues(alpha: 0.75),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Text(label),
                ),
              ),
              if (isBooked) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 9,
                    color: isSelected ? brandOrange : Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
