import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/explorer_badge.dart';

/// Circular passport achievement stamp badge widget displaying illustrated artwork or emoji icon,
/// title, and requirement subtitle with clean gesture handling that allows horizontal swiping.
class CircularAchievementBadge extends StatelessWidget {
  final ExplorerBadge badge;
  final VoidCallback? onTap;

  const CircularAchievementBadge({
    super.key,
    required this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);
    final isUnlocked = badge.isUnlocked;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Illustrated Badge
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E1C14).withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: badge.imageAsset != null
                    ? Image.asset(
                        badge.imageAsset!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildEmojiFallback(),
                      )
                    : _buildEmojiFallback(),
              ),
            ),
            const SizedBox(height: 7),

            // Badge Title
            Text(
              badge.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fredoka(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isUnlocked ? darkBrown : textMuted,
              ),
            ),
            const SizedBox(height: 1),

            // Requirement Subtitle
            Text(
              badge.requirement,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiFallback() {
    return Container(
      color: const Color(0xFFFFF8E7),
      child: Center(
        child: Text(
          badge.icon,
          style: const TextStyle(fontSize: 26),
        ),
      ),
    );
  }
}
