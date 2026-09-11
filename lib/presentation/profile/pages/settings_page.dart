import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/login_screen.dart';
import '../models/user_profile.dart';
import 'achievements_page.dart';
import 'currency_screen.dart';
import 'edit_profile_page.dart';
import 'language_screen.dart';
import 'notification_settings_page.dart';
import 'privacy_settings_page.dart';
import 'travel_insights_page.dart';
import 'travel_preferences_page.dart';

/// Comprehensive Settings Screen with independent Language and Currency screens.
class SettingsPage extends StatefulWidget {
  final UserProfile profile;
  final String currentLanguage;
  final String currentCurrency;
  final ValueChanged<UserProfile>? onProfileUpdated;
  final ValueChanged<String>? onLanguageUpdated;
  final ValueChanged<String>? onCurrencyUpdated;

  const SettingsPage({
    super.key,
    required this.profile,
    this.currentLanguage = 'English',
    this.currentCurrency = 'MYR (RM)',
    this.onProfileUpdated,
    this.onLanguageUpdated,
    this.onCurrencyUpdated,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late UserProfile _profile;
  late String _selectedLanguage;
  late String _selectedCurrency;
  String _appearance = 'System'; // 'System', 'Light', 'Dark'

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _selectedLanguage = widget.currentLanguage;
    _selectedCurrency = widget.currentCurrency;
  }

  void _navigateToLanguage() async {
    final updated = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageScreen(
          currentLanguage: _selectedLanguage,
          onLanguageSelected: (lang) {
            setState(() {
              _selectedLanguage = lang;
            });
            widget.onLanguageUpdated?.call(lang);
          },
        ),
      ),
    );

    if (updated != null) {
      setState(() {
        _selectedLanguage = updated;
      });
      widget.onLanguageUpdated?.call(updated);
    }
  }

  void _navigateToCurrency() async {
    final updated = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CurrencyScreen(
          currentCurrency: _selectedCurrency,
          onCurrencySelected: (curr) {
            setState(() {
              _selectedCurrency = curr;
            });
            widget.onCurrencyUpdated?.call(curr);
          },
        ),
      ),
    );

    if (updated != null) {
      setState(() {
        _selectedCurrency = updated;
      });
      widget.onCurrencyUpdated?.call(updated);
    }
  }

  void _showAppearanceSelector() {
    final options = ['System (Warm Cream)', 'Light Theme', 'Dark Mode (Coming Soon)'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFFFDF7F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBC9B8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Select Appearance',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E1C14),
              ),
            ),
            const SizedBox(height: 12),
            ...options.map((opt) {
              final isSelected = opt.startsWith(_appearance);
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: isSelected ? const Color(0xFFFFEDE0) : null,
                title: Text(
                  opt,
                  style: GoogleFonts.fredoka(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFFE65100)
                        : const Color(0xFF2E1C14),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded,
                        color: Color(0xFFE65100))
                    : null,
                onTap: () {
                  setState(() {
                    _appearance = opt.split(' ')[0];
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showHelpSupportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
        decoration: const BoxDecoration(
          color: Color(0xFFFDF7F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBC9B8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Help & Support',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E1C14),
              ),
            ),
            const SizedBox(height: 16),
            _buildSupportTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chat with Trippy Assistant',
              subtitle: 'Instant help with trip planning & app guides',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Trippy Support is ready in your group chat! 🦊',
                      style: GoogleFonts.fredoka(),
                    ),
                    backgroundColor: const Color(0xFFE65100),
                  ),
                );
              },
            ),
            _buildSupportTile(
              icon: Icons.quiz_outlined,
              title: 'Frequently Asked Questions',
              subtitle: 'Voting, itineraries, and expense splitting',
              onTap: () => Navigator.pop(context),
            ),
            _buildSupportTile(
              icon: Icons.mail_outline_rounded,
              title: 'Contact Support Team',
              subtitle: 'support@travelyn.app',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFFE65100), size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.fredoka(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2E1C14),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunito(
          fontSize: 12.5,
          color: const Color(0xFF7A6860),
        ),
      ),
      onTap: onTap,
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDF7F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/mascot/avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Text('🦊')),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'About Travelyn',
              style: GoogleFonts.fredoka(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E1C14),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Travelyn is your personalized social travel platform with Trippy, your AI travel companion.',
              style: GoogleFonts.nunito(
                fontSize: 13.5,
                color: const Color(0xFF2E1C14),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Version 1.0.0 (Build 1)',
              style: GoogleFonts.fredoka(
                fontSize: 12.5,
                color: const Color(0xFF8D6E63),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.fredoka(
                color: const Color(0xFFE65100),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDF7F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Log Out?',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E1C14),
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of @${_profile.username}?',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: const Color(0xFF7A6860),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.fredoka(
                color: const Color(0xFF7A6860),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder: (context, anim, secAnim) => const LoginScreen(),
                  transitionsBuilder: (context, anim, secAnim, child) =>
                      FadeTransition(opacity: anim, child: child),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.fredoka(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7F0),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: darkBrown,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group 1: ACCOUNT
              _buildSectionHeader('ACCOUNT'),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.badge_outlined,
                      iconColor: const Color(0xFFE65100),
                      title: 'Edit Profile',
                      subtitle: _profile.name,
                      onTap: () async {
                        final updated = await Navigator.push<UserProfile>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                              profile: _profile,
                              onProfileSaved: (p) {
                                setState(() => _profile = p);
                                widget.onProfileUpdated?.call(p);
                              },
                            ),
                          ),
                        );
                        if (updated != null) {
                          setState(() => _profile = updated);
                          widget.onProfileUpdated?.call(updated);
                        }
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.tune_rounded,
                      iconColor: const Color(0xFF2E7D32),
                      title: 'Travel Preferences',
                      subtitle: 'Pace, styles, food & crowd choices',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TravelPreferencesPage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.auto_awesome_rounded,
                      iconColor: const Color(0xFFEF6C00),
                      title: 'Travel Insights',
                      subtitle: 'What Trippy has learned about you',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TravelInsightsPage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.military_tech_outlined,
                      iconColor: const Color(0xFFF9A825),
                      title: 'Travel Achievements',
                      subtitle: 'Milestones and unlocked badges',
                      showDivider: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AchievementsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Group 2: APP PREFERENCES (Language and Currency separated)
              _buildSectionHeader('APP PREFERENCES'),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'Trip alerts & reminders',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const NotificationSettingsPage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                      subtitle: '$_appearance theme',
                      onTap: _showAppearanceSelector,
                    ),
                    _buildSettingsTile(
                      icon: Icons.language_rounded,
                      iconColor: const Color(0xFF1976D2),
                      title: 'Language',
                      subtitle: _selectedLanguage,
                      onTap: _navigateToLanguage,
                    ),
                    _buildSettingsTile(
                      icon: Icons.payments_outlined,
                      iconColor: const Color(0xFF388E3C),
                      title: 'Currency',
                      subtitle: _selectedCurrency,
                      showDivider: false,
                      onTap: _navigateToCurrency,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Group 3: PRIVACY
              _buildSectionHeader('PRIVACY & SECURITY'),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Privacy & Permissions',
                      subtitle: 'Visibility, location & personalization',
                      showDivider: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacySettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Group 4: SUPPORT & ABOUT
              _buildSectionHeader('SUPPORT & ABOUT'),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'FAQs, Trippy assistant & contact',
                      onTap: _showHelpSupportSheet,
                    ),
                    _buildSettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About Travelyn',
                      subtitle: 'Version 1.0.0',
                      showDivider: false,
                      onTap: _showAboutDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Group 5: ACCOUNT ACTION
              _buildSectionHeader('ACCOUNT ACTION'),
              Container(
                decoration: _cardDecoration(),
                child: _buildSettingsTile(
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFFD32F2F),
                  title: 'Log Out',
                  subtitle: 'Sign out of @${_profile.username}',
                  isDestructive: true,
                  showDivider: false,
                  onTap: _confirmLogout,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.fredoka(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF8D6E63),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: const Color(0xFFEDE4DA),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2E1C14).withValues(alpha: 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    Color iconColor = const Color(0xFF5D4037),
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
                          : iconColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isDestructive
                          ? const Color(0xFFD32F2F)
                          : iconColor,
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
