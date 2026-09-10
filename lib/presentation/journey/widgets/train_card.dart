import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/booking_models.dart';

/// Card displaying Shinkansen bullet train or intercity transit recommendations.
class TrainCard extends StatefulWidget {
  final TrainOption train;
  final int travellerCount;
  final TrainSortOption activeSort;
  final bool isSelected;
  final VoidCallback onSelect;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const TrainCard({
    super.key,
    required this.train,
    required this.travellerCount,
    required this.activeSort,
    required this.isSelected,
    required this.onSelect,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
  });

  @override
  State<TrainCard> createState() => _TrainCardState();
}

class _TrainCardState extends State<TrainCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final train = widget.train;
    final totalPrice = train.calculateTotalPrice(widget.travellerCount);
    final badgeLabel = train.getDynamicBadgeLabel(widget.activeSort);

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: widget.brandOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${train.matchScore}% Match',
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

          // 2. Train Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                // Shinkansen Icon Badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.brandOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.brandOrange.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.train_rounded,
                    color: Color(0xFFE65100),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 10),

                // Train Name & Speed Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        train.trainName,
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.darkBrown,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${train.speed} · ${train.trainOperator}',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: widget.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Price Tag in RM
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'RM${train.priceRm}',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: widget.brandOrange,
                      ),
                    ),
                    Text(
                      '/ ticket',
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

          // 3. High-Speed Route Visualizer
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
                  // Departure Station
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          train.departureStation,
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: widget.darkBrown,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Departure',
                          style: GoogleFonts.fredoka(
                            fontSize: 11,
                            color: widget.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Middle Timeline with Speed Icon
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Text(
                          train.duration,
                          style: GoogleFonts.fredoka(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: widget.brandOrange,
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
                              child: Icon(
                                Icons.bolt_rounded,
                                size: 16,
                                color: widget.brandOrange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          train.frequency,
                          style: GoogleFonts.fredoka(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: widget.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Arrival Station
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          train.arrivalStation,
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: widget.darkBrown,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Destination',
                          style: GoogleFonts.fredoka(
                            fontSize: 11,
                            color: widget.textMuted,
                          ),
                        ),
                      ],
                    ),
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
                    Icons.speed_rounded,
                    size: 16,
                    color: widget.brandOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      train.concreteTradeOff,
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

          // 5. Total Price Tag
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3ECE3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    train.route,
                    style: GoogleFonts.fredoka(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: widget.darkBrown.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'RM$totalPrice total (${widget.travellerCount} pax)',
                  style: GoogleFonts.fredoka(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: widget.darkBrown,
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
                  ...train.matchBreakdown.entries.map((entry) {
                    final factor = entry.key;
                    final score = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
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

                  ...train.measurableReasons.map((reason) {
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
                          : Icons.bookmark_added_rounded,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isSelected
                          ? 'Selected Transit  ✓'
                          : 'Select This Option',
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
