import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/booking_models.dart';

/// Clean, realistic horizontal sort chips bar with Filter launcher,
/// supporting Stays, Flights, and Bullet Trains.
class BookingSortChips extends StatelessWidget {
  final BookingType bookingType;
  final HotelSortOption activeHotelSort;
  final FlightSortOption activeFlightSort;
  final TrainSortOption activeTrainSort;
  final ValueChanged<HotelSortOption> onHotelSortChanged;
  final ValueChanged<FlightSortOption> onFlightSortChanged;
  final ValueChanged<TrainSortOption> onTrainSortChanged;
  final VoidCallback onFilterTap;
  final int activeFilterCount;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const BookingSortChips({
    super.key,
    required this.bookingType,
    required this.activeHotelSort,
    required this.activeFlightSort,
    this.activeTrainSort = TrainSortOption.recommended,
    required this.onHotelSortChanged,
    required this.onFlightSortChanged,
    required this.onTrainSortChanged,
    required this.onFilterTap,
    this.activeFilterCount = 0,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Filter Button with Active Badge (Only for Stays and Flights)
          if (bookingType != BookingType.trains) ...[
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onFilterTap();
              },
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: activeFilterCount > 0
                      ? const Color(0xFFFFF1E6)
                      : const Color(0xFFFFFBF7),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: activeFilterCount > 0 ? brandOrange : const Color(0xFFEDE3D7),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: darkBrown.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: activeFilterCount > 0 ? brandOrange : darkBrown,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Filters',
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: activeFilterCount > 0 ? brandOrange : darkBrown,
                      ),
                    ),
                    if (activeFilterCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: brandOrange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$activeFilterCount',
                          style: GoogleFonts.fredoka(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Center(
              child: Container(
                width: 1,
                height: 18,
                color: const Color(0xFFE2D6C8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // 2. Realistic Sort Chips
          if (bookingType == BookingType.stays)
            ...HotelSortOption.values.map(
              (option) => _buildSortChip(
                label: option.label,
                isSelected: activeHotelSort == option,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onHotelSortChanged(option);
                },
              ),
            )
          else if (bookingType == BookingType.flights)
            ...FlightSortOption.values.map(
              (option) => _buildSortChip(
                label: option.label,
                isSelected: activeFlightSort == option,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onFlightSortChanged(option);
                },
              ),
            )
          else
            ...TrainSortOption.values.map(
              (option) => _buildSortChip(
                label: option.label,
                isSelected: activeTrainSort == option,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTrainSortChanged(option);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected ? brandOrange : const Color(0xFFFFFBF7),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: isSelected ? brandOrange : const Color(0xFFEDE3D7),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? brandOrange.withValues(alpha: 0.2)
                    : darkBrown.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.fredoka(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : darkBrown.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
