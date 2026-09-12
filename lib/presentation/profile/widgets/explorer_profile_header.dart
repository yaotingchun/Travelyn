import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Immersive profile header matching the target Travelyn explorer design:
/// 1. Top Japanese pagoda hero banner bleeding edge-to-edge.
/// 2. Top-right circular notification & settings icons matching the exact frosted glass transparency of Home.
/// 3. Curved profile card layered ON TOP of the hero banner.
/// 4. Circular Shiba avatar overlapping the card's top edge (half above, half inside).
/// 5. Traveler name, edit icon, and tagline to the right of the avatar.
/// 6. Integrated 3-stat explorer row (Trips, Saved, Countries) at the bottom of the card.
class ExplorerProfileHeader extends StatelessWidget {
  final String name;
  final String tagline;
  final String avatarAsset;
  final String heroBannerAsset;
  final int tripsCount;
  final int savedCount;
  final int countriesCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onEditProfileTap;
  final VoidCallback? onTripsTap;
  final VoidCallback? onSavedTap;
  final VoidCallback? onCountriesTap;

  const ExplorerProfileHeader({
    super.key,
    required this.name,
    required this.tagline,
    required this.avatarAsset,
    required this.heroBannerAsset,
    required this.tripsCount,
    required this.savedCount,
    required this.countriesCount,
    required this.onNotificationTap,
    required this.onSettingsTap,
    required this.onEditProfileTap,
    this.onTripsTap,
    this.onSavedTap,
    this.onCountriesTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    final statusBarHeight = MediaQuery.of(context).padding.top;
    final heroHeight = statusBarHeight + 155.0; // Ample height for pagoda scenery & top icons
    const avatarSize = 74.0;
    final cardTop = heroHeight - 40.0; // Card overlaps bottom 40px of hero banner

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // LAYER 1 (Bottom-most): Full-bleed Hero Banner at Top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: heroHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                heroBannerAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFFFD180),
                ),
              ),
              // Soft warm gradient vignette
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.12),
                      Colors.transparent,
                      const Color(0xFFFDF7F0).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),

        // LAYER 2: Profile Card (Painted ON TOP of hero banner so it is never hidden!)
        Padding(
          padding: EdgeInsets.only(top: cardTop),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF7F0),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: const Color(0xFFEFE6D8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3E2723).withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Upper Section: Reserved space for avatar + Name & Tagline
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Reserved space for overlapping avatar on the left
                    const SizedBox(width: avatarSize + 8),

                    // Name, Edit Icon, Tagline
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: darkBrown,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: onEditProfileTap,
                                child: Container(
                                  padding: const EdgeInsets.all(3.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4ECE1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFE5D8CA),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    size: 13,
                                    color: Color(0xFF7A6860),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tagline,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Divider
                Container(
                  height: 1,
                  color: const Color(0xFFEFE5D8),
                ),
                const SizedBox(height: 12),

                // Lower Section: 3-Stat Explorer Row (Trips / Saved / Countries)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      iconWidget: const Text('🧳', style: TextStyle(fontSize: 18)),
                      value: '$tripsCount',
                      label: 'Trips',
                      onTap: onTripsTap,
                      darkBrown: darkBrown,
                      textMuted: textMuted,
                    ),
                    _buildStatDivider(),
                    _buildStatItem(
                      iconWidget: const Text('🔖', style: TextStyle(fontSize: 18)),
                      value: '$savedCount',
                      label: 'Saved',
                      onTap: onSavedTap,
                      darkBrown: darkBrown,
                      textMuted: textMuted,
                    ),
                    _buildStatDivider(),
                    _buildStatItem(
                      iconWidget: const Text('🌐', style: TextStyle(fontSize: 18)),
                      value: '$countriesCount',
                      label: 'Countries',
                      onTap: onCountriesTap,
                      darkBrown: darkBrown,
                      textMuted: textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // LAYER 3: Overlapping Avatar (Half sits above the card top edge, half inside)
        Positioned(
          top: cardTop - (avatarSize / 2),
          left: 28,
          child: Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFFFE0B2),
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3E2723).withValues(alpha: 0.16),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                avatarAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text('🦊', style: TextStyle(fontSize: 34)),
                ),
              ),
            ),
          ),
        ),

        // LAYER 4 (Top-most): Frosted Glass Notification 🔔 and Settings ⚙️ Buttons
        Positioned(
          top: statusBarHeight + 10,
          right: 18,
          child: Row(
            children: [
              _buildFrostedButton(
                icon: Icons.notifications_none_rounded,
                hasDot: true,
                onTap: onNotificationTap,
              ),
              const SizedBox(width: 8),
              _buildFrostedButton(
                icon: Icons.settings_outlined,
                hasDot: false,
                onTap: onSettingsTap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrostedButton({
    required IconData icon,
    required bool hasDot,
    required VoidCallback onTap,
  }) {
    const darkBrown = Color(0xFF2E1C14);
    const brandOrange = Color(0xFFE65100);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: darkBrown.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: darkBrown,
                ),
                if (hasDot)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: brandOrange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.0,
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

  Widget _buildStatItem({
    required Widget iconWidget,
    required String value,
    required String label,
    VoidCallback? onTap,
    required Color darkBrown,
    required Color textMuted,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: darkBrown,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 28,
      color: const Color(0xFFEAE0D2),
    );
  }
}
