import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/booking_models.dart';

/// Realistic flight card with route timeline, concrete trade-off comparison,
/// match scoring breakdown, and RM pricing.
class FlightCard extends StatefulWidget {
  final FlightOption flight;
  final int travellerCount;
  final FlightSortOption activeSort;
  final bool isSelected;
  final VoidCallback onSelect;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const FlightCard({
    super.key,
    required this.flight,
    required this.travellerCount,
    required this.activeSort,
    required this.isSelected,
    required this.onSelect,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
  });

  @override
  State<FlightCard> createState() => _FlightCardState();
}

class _FlightCardState extends State<FlightCard> {
  bool _isExpanded = false;

  Color _getAirlineColor(String code) {
    switch (code) {
      case 'D7':
        return const Color(0xFFED1C24); // AirAsia Red
      case 'OD':
        return const Color(0xFFC0142A); // Batik Maroon
      case 'MH':
        return const Color(0xFF0B2F64); // MAS Navy
      case 'SQ':
        return const Color(0xFF13284C); // SIA Navy
      case 'JL':
        return const Color(0xFFCC0000); // JAL Red
      case 'NH':
        return const Color(0xFF002288); // ANA Blue
      default:
        return const Color(0xFFE65100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    final totalPrice = flight.calculateTotalPrice(widget.travellerCount);
    final airlineAccent = _getAirlineColor(flight.airlineCode);
    final badgeLabel = flight.getDynamicBadgeLabel(widget.activeSort);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: widget.isSelected
              ? widget.brandOrange
              : const Color(0xFFEDE3D7),
          width: widget.isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? widget.brandOrange.withValues(alpha: 0.12)
                : widget.darkBrown.withValues(alpha: 0.05),
            blurRadius: widget.isSelected ? 14 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Section: Comparative Badge + Trip Match Score
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.brandOrange.withValues(alpha: 0.12)
                  : const Color(0xFFFFF3E6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: const Border(
                bottom: BorderSide(
                  color: Color(0xFFFFE5CC),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    badgeLabel,
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: widget.brandOrange,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Trip Match Score Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: widget.brandOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${flight.matchScore}% Match',
                    style: GoogleFonts.fredoka(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Airline Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                // Airline Logo Badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: airlineAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: airlineAccent.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    flight.airlineCode,
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: airlineAccent,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Airline name & Flight #
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.airline,
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.darkBrown,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${flight.flightNumber} · ${flight.cabinClass}',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: widget.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Price Tag in RM
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'RM${flight.pricePerPersonRm}',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: widget.brandOrange,
                      ),
                    ),
                    Text(
                      '/ person',
                      style: GoogleFonts.fredoka(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: widget.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Flight Timeline (Departure → Transit → Arrival)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF6F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEBE0D2),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  // Departure
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.departureTime,
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: widget.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: widget.darkBrown.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              flight.departureAirport,
                              style: GoogleFonts.fredoka(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: widget.darkBrown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            flight.departureCity,
                            style: GoogleFonts.fredoka(
                              fontSize: 11.5,
                              color: widget.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Middle Timeline
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Text(
                            flight.duration,
                            style: GoogleFonts.fredoka(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: widget.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 1.5,
                                color: const Color(0xFFD9C9B8),
                              ),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFBF6F0),
                                  shape: BoxShape.circle,
                                ),
                                child: Transform.rotate(
                                  angle: 1.57,
                                  child: Icon(
                                    Icons.flight_rounded,
                                    size: 16,
                                    color: widget.brandOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            flight.stopsLabel,
                            style: GoogleFonts.fredoka(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: flight.stops == 0
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Arrival
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        flight.arrivalTime,
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: widget.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            flight.arrivalCity,
                            style: GoogleFonts.fredoka(
                              fontSize: 11.5,
                              color: widget.textMuted,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: widget.darkBrown.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              flight.arrivalAirport,
                              style: GoogleFonts.fredoka(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: widget.darkBrown,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 4. Concrete Trade-Off Callout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE7D6)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.compare_arrows_rounded,
                    size: 16,
                    color: widget.brandOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      flight.concreteTradeOff,
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                        color: widget.darkBrown.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 5. Perks Row (Baggage + Group Total)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3ECE3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.luggage_rounded,
                          size: 13,
                          color: widget.darkBrown.withValues(alpha: 0.75),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            flight.baggageAllowance,
                            style: GoogleFonts.fredoka(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: widget.darkBrown.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Flexible(
                  child: Text(
                    'RM$totalPrice total (${widget.travellerCount} pax)',
                    style: GoogleFonts.fredoka(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: widget.darkBrown,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 6. Expandable "Why? (Trip Match Breakdown)"
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5EA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFE7D1),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 16,
                    color: widget.brandOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Why? (Trip Match Breakdown)',
                    style: GoogleFonts.fredoka(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: widget.brandOrange,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: widget.brandOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Breakdown Section
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Factor Bars
                  ...flight.matchBreakdown.entries.map((entry) {
                    final factor = entry.key;
                    final score = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 85,
                            child: Text(
                              factor,
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: widget.textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: score / 100.0,
                                backgroundColor: const Color(0xFFEDE3D7),
                                color: widget.brandOrange,
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 32,
                            child: Text(
                              '$score%',
                              style: GoogleFonts.fredoka(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: widget.darkBrown,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(color: Color(0xFFEDE3D7), height: 16),

                  // Measurable Itinerary Reasons
                  ...flight.measurableReasons.map((reason) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              reason,
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.35,
                                color: widget.darkBrown.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),

          const SizedBox(height: 12),

          // 7. Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  widget.onSelect();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isSelected
                      ? const Color(0xFF2E7D32)
                      : widget.brandOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isSelected
                          ? Icons.check_circle_rounded
                          : Icons.flight_takeoff_rounded,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isSelected
                          ? 'Selected Flight  ✓'
                          : 'Select This Flight',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
