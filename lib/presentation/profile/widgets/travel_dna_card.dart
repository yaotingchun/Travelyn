import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/travel_dna_dimension.dart';

/// Travel DNA Card showing core travel tags and animated preference dimension bars.
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
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFEDE4DA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Subtitle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '✨',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Travel DNA',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkBrown,
                    ),
                  ),
                  Text(
                    'How you like to explore',
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Highlight Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.highlightTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF4EB),
                  borderRadius: BorderRadius.circular(14),
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
          const SizedBox(height: 20),

          // DNA Dimension Progress Bars
          Column(
            children: widget.dimensions.map((dim) {
              return _buildDimensionRow(dim);
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Bottom CTA: Edit Travel Preferences →
          Center(
            child: TextButton.icon(
              onPressed: widget.onEditPreferencesTap,
              icon: const SizedBox.shrink(),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Travel Preferences',
                    style: GoogleFonts.fredoka(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: brandOrange,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: brandOrange,
                  ),
                ],
              ),
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
                      tween: Tween<double>(begin: 0.0, end: dim.normalizedScore),
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

          // Score badge
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
