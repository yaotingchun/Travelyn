import 'package:flutter/material.dart';
import '../data/mock_profile_data.dart';
import '../models/travel_preference.dart';
import '../models/user_profile.dart';
import '../widgets/achievements_preview_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_identity_card.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/travel_dna_card.dart';
import '../widgets/trippy_insight_card.dart';
import 'achievements_page.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'travel_insights_page.dart';
import 'travel_preferences_page.dart';

/// The main "Me" (Travel Identity) bottom-navigation tab screen for Travelyn.
///
/// Features:
/// - Single gear icon in [ProfileHeader] to enter Settings.
/// - Single [ProfileIdentityCard] with prominent Edit Profile action.
/// - Single [TravelDnaCard] with "Edit Travel Preferences →" action.
/// - Single [TrippyInsightCard] with "See Travel Insights →" action.
/// - Single [AchievementsPreviewCard] with "View All →" action.
/// - Zero duplicate navigation paths across the screen.
class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> with SingleTickerProviderStateMixin {
  late UserProfile _profile;
  late List<TravelPreference> _preferences;
  String _appLanguage = 'English';
  String _appCurrency = 'MYR (RM)';

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _profile = MockProfileData.defaultProfile;
    _preferences = List.from(MockProfileData.preferences);
    _appLanguage = _profile.preferredLanguage;
    _appCurrency = '${_profile.currency} (RM)';

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          profile: _profile,
          currentLanguage: _appLanguage,
          currentCurrency: _appCurrency,
          onProfileUpdated: (updated) {
            setState(() {
              _profile = updated;
            });
          },
          onLanguageUpdated: (lang) {
            setState(() {
              _appLanguage = lang;
            });
          },
          onCurrencyUpdated: (curr) {
            setState(() {
              _appCurrency = curr;
            });
          },
        ),
      ),
    );
  }

  void _navigateToEditProfile() async {
    final updated = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          profile: _profile,
          onProfileSaved: (p) {
            setState(() {
              _profile = p;
            });
          },
        ),
      ),
    );

    if (updated != null) {
      setState(() {
        _profile = updated;
      });
    }
  }

  void _navigateToPreferences() async {
    final updated = await Navigator.push<List<TravelPreference>>(
      context,
      MaterialPageRoute(
        builder: (context) => TravelPreferencesPage(
          initialPreferences: _preferences,
          onPreferencesSaved: (newPrefs) {
            setState(() {
              _preferences = newPrefs;
            });
          },
        ),
      ),
    );

    if (updated != null) {
      setState(() {
        _preferences = updated;
      });
    }
  }

  void _navigateToInsights() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TravelInsightsPage(),
      ),
    );
  }

  void _navigateToAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AchievementsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section A: Header (Single Settings Gear Entry Point)
                  ProfileHeader(
                    onSettingsTap: _navigateToSettings,
                  ),
                  const SizedBox(height: 6),

                  // Section B: Profile Identity Card (Photo, Name, Username, Bio, Tags, and single Edit Profile button)
                  ProfileIdentityCard(
                    profile: _profile,
                    onEditProfileTap: _navigateToEditProfile,
                  ),
                  const SizedBox(height: 14),

                  // Section C: Personal Lifetime Travel Statistics
                  ProfileStatsRow(
                    profile: _profile,
                  ),
                  const SizedBox(height: 18),

                  // Section D: Travel DNA Card (with single "Edit Travel Preferences →" entry point)
                  TravelDnaCard(
                    dimensions: MockProfileData.dnaDimensions,
                    highlightTags: MockProfileData.dnaHighlightTags,
                    onEditPreferencesTap: _navigateToPreferences,
                  ),
                  const SizedBox(height: 18),

                  // Section E: Trippy Knows You (with single "See Travel Insights →" entry point)
                  TrippyInsightCard(
                    quote: MockProfileData.trippyQuote,
                    onSeeInsightsTap: _navigateToInsights,
                  ),
                  const SizedBox(height: 18),

                  // Section F: Achievements Preview (with single "View All →" entry point)
                  AchievementsPreviewCard(
                    achievements: MockProfileData.achievements,
                    onViewAllTap: _navigateToAchievements,
                  ),

                  // Generous bottom spacing so content doesn't get obscured by floating bottom nav bar
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
