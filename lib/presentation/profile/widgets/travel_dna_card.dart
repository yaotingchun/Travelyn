import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/travel_dna_dimension.dart';

/// Travel DNA Section showing core travel tags and animated preference dimension bars.
class TravelDnaCard extends StatefulWidget {
  final List<TravelDnaDimension> dimensions;
  final List<String> highlightTags;
  final VoidCallback onEditPreferencesTap;

  const TravelDnaCard({
    super.key,
    required this.dimensions,
    required this.highlightTags,
    required this.onEditPreferencesTap,
  });

  @override
  State<TravelDnaCard> createState() => _TravelDnaCardState();
}

class _TravelDnaCardState extends State<TravelDnaCard> {
  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE87516);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Row: "✦ Your Travel DNA" and "Edit >"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Text(
                    '✦',
                    style: TextStyle(
                      color: brandOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Your Travel DNA',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkBrown,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: widget.onEditPreferencesTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Edit',
                        style: GoogleFonts.fredoka(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content Card
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFEDE4DA),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highlight Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.highlightTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 5.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF4EB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEFE2D3),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // DNA Dimension Progress Bars
                Column(
                  children: widget.dimensions.map((dim) {
                    return _buildDimensionRow(dim);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionRow(TravelDnaDimension dim) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          // Icon & Name
          SizedBox(
            width: 90,
            child: Row(
              children: [
                Text(dim.icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dim.name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: darkBrown,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Progress Bar
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Background track
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EBE1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    // Animated bar
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                          begin: 0.0, end: dim.normalizedScore),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Container(
                          height: 10,
                          width: constraints.maxWidth * value,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                dim.barColor.withValues(alpha: 0.85),
                                dim.barColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: dim.barColor.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Score percentage
          SizedBox(
            width: 32,
            child: Text(
              '${dim.score.toInt()}%',
              textAlign: TextAlign.right,
              style: GoogleFonts.fredoka(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
