import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gamified explorer progression card displaying current Rank, Level, animated XP bar,
/// vintage compass illustration, and tilted "Let's go!" postage stamp.
class ExplorerLevelCard extends StatefulWidget {
  final String rank;
  final int level;
  final int currentXp;
  final int maxXp;
  final String nextRank;
  final String compassAsset;
  final String stampAsset;
  final VoidCallback? onTap;

  const ExplorerLevelCard({
    super.key,
    required this.rank,
    required this.level,
    required this.currentXp,
    required this.maxXp,
    required this.nextRank,
    this.compassAsset = 'assets/profile/compass_vintage.jpg',
    this.stampAsset = 'assets/profile/stamp_lets_go.jpg',
    this.onTap,
  });

  @override
  State<ExplorerLevelCard> createState() => _ExplorerLevelCardState();
}

class _ExplorerLevelCardState extends State<ExplorerLevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    final targetProgress = (widget.currentXp / widget.maxXp).clamp(0.0, 1.0);
    _progressAnim = Tween<double>(begin: 0.0, end: targetProgress).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ),
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);
    const brandOrange = Color(0xFFE87516);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF7F0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEFE6D8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Left: Vintage Compass Emblem
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFFFD54F),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE87516).withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      widget.compassAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Text('🧭', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Center: Rank, Level, Progress Bar, XP
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rank Title & Level Badge
                      Row(
                        children: [
                          Text(
                            widget.rank,
                            style: GoogleFonts.fredoka(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1E8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFFCCBC),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'Level ${widget.level}',
                              style: GoogleFonts.fredoka(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: brandOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Progress Bar
                      AnimatedBuilder(
                        animation: _progressAnim,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              Container(
                                height: 7,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE2D5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: _progressAnim.value,
                                child: Container(
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: brandOrange,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 6),

                      // XP labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.currentXp} / ${widget.maxXp} XP',
                            style: GoogleFonts.nunito(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: textMuted,
                            ),
                          ),
                          Text(
                            'Next level: ${widget.nextRank}',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Right: Tilted "Let's go!" Postage Stamp
                Transform.rotate(
                  angle: 0.08,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF3E2723).withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        widget.stampAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          color: const Color(0xFFFFECB3),
                          child: const Center(
                            child: Text('✉️', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
