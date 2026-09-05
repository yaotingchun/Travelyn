import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen allowing the user to configure privacy, visibility, and data personalization controls.
class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  String _profileVisibility = 'Friends'; // 'Everyone', 'Friends', 'Private'
  String _locationSharing = 'While travelling'; // 'While travelling', 'Never'
  bool _personalizedRecommendations = true;
  bool _shareTripMemories = true;

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
          'Privacy & Permissions',
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Visibility
              _buildSectionTitle('PROFILE VISIBILITY'),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildRadioTile(
                      title: 'Everyone',
                      subtitle: 'Any traveler on Travelyn can view your travel profile',
                      value: 'Everyone',
                      groupValue: _profileVisibility,
                      onChanged: (val) => setState(() => _profileVisibility = val!),
                      showDivider: true,
                    ),
                    _buildRadioTile(
                      title: 'Friends & Travel Buddies',
                      subtitle: 'Only people in your shared trips and contacts',
                      value: 'Friends',
                      groupValue: _profileVisibility,
                      onChanged: (val) => setState(() => _profileVisibility = val!),
                      showDivider: true,
                    ),
                    _buildRadioTile(
                      title: 'Private',
                      subtitle: 'Only you can view your Travel DNA and statistics',
                      value: 'Private',
                      groupValue: _profileVisibility,
                      onChanged: (val) => setState(() => _profileVisibility = val!),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Location Sharing
              _buildSectionTitle('LOCATION SHARING'),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildRadioTile(
                      title: 'While travelling',
                      subtitle: 'Trippy suggests nearby stops and syncs with group members',
                      value: 'While travelling',
                      groupValue: _locationSharing,
                      onChanged: (val) => setState(() => _locationSharing = val!),
                      showDivider: true,
                    ),
                    _buildRadioTile(
                      title: 'Never',
                      subtitle: 'Disable real-time location detection across all trips',
                      value: 'Never',
                      groupValue: _locationSharing,
                      onChanged: (val) => setState(() => _locationSharing = val!),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // AI Personalization & Data
              _buildSectionTitle('DATA & PERSONALIZATION'),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Personalized recommendations',
                      subtitle: 'Allow Trippy to learn from ratings & poll votes to tailor trips',
                      value: _personalizedRecommendations,
                      onChanged: (val) =>
                          setState(() => _personalizedRecommendations = val),
                      showDivider: true,
                    ),
                    _buildSwitchTile(
                      title: 'Share memories to Discover',
                      subtitle: 'Allow public photo memories in community trip guides',
                      value: _shareTripMemories,
                      onChanged: (val) =>
                          setState(() => _shareTripMemories = val),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
    required bool showDivider,
  }) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);
    final isSelected = value == groupValue;

    return Column(
      children: [
        InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.fredoka(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFFBF360C) : darkBrown,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? brandOrange : const Color(0xFFBCAAA4),
                  size: 22,
                ),
              ],
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool showDivider,
  }) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.fredoka(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: darkBrown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeTrackColor: brandOrange,
                activeThumbColor: Colors.white,
                inactiveThumbColor: const Color(0xFFBCAAA4),
                inactiveTrackColor: const Color(0xFFEFEBE7),
              ),
            ],
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
