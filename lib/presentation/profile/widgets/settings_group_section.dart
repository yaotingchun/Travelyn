import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Grouped Settings section showing notifications, privacy, appearance, support, and logout.
class SettingsGroupSection extends StatelessWidget {
  final VoidCallback onNotificationsTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onLanguageCurrencyTap;
  final VoidCallback onAppearanceTap;
  final VoidCallback onHelpSupportTap;
  final VoidCallback onAboutTap;
  final VoidCallback onLogoutTap;

  const SettingsGroupSection({
    super.key,
    required this.onNotificationsTap,
    required this.onPrivacyTap,
    required this.onLanguageCurrencyTap,
    required this.onAppearanceTap,
    required this.onHelpSupportTap,
    required this.onAboutTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEDE4DA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1C14).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.settings_outlined,
                  size: 18,
                  color: Color(0xFF5D4037),
                ),
                const SizedBox(width: 8),
                Text(
                  'Settings',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: darkBrown,
                  ),
                ),
              ],
            ),
          ),
          _buildTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Trip alerts, morning briefing, reminders',
            onTap: onNotificationsTap,
          ),
          _buildTile(
            icon: Icons.language_rounded,
            title: 'Language & Currency',
            subtitle: 'English · MYR (RM)',
            onTap: onLanguageCurrencyTap,
          ),
          _buildTile(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy & Permissions',
            subtitle: 'Profile visibility & location sharing',
            onTap: onPrivacyTap,
          ),
          _buildTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'System default (Warm Cream)',
            onTap: onAppearanceTap,
          ),
          _buildTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'FAQs, contact team & feedback',
            onTap: onHelpSupportTap,
          ),
          _buildTile(
            icon: Icons.info_outline_rounded,
            title: 'About Travelyn',
            subtitle: 'Version 1.0.0 · Powered by Trippy AI',
            onTap: onAboutTap,
          ),
          _buildTile(
            icon: Icons.logout_rounded,
            iconColor: const Color(0xFFD32F2F),
            title: 'Log Out',
            subtitle: 'Sign out of your account',
            isDestructive: true,
            showDivider: false,
            onTap: onLogoutTap,
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    Color iconColor = const Color(0xFF7A6860),
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showDivider = true,
  }) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDestructive
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFF7F3EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isDestructive
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF5D4037),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.fredoka(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: isDestructive
                                ? const Color(0xFFD32F2F)
                                : darkBrown,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDestructive
                                ? const Color(0xFFE57373)
                                : textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDestructive
                        ? const Color(0xFFEF9A9A)
                        : const Color(0xFFBCAAA4),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: Color(0xFFF0EAE1),
            ),
          ),
      ],
    );
  }
}
