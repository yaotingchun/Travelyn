import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_profile_data.dart';
import '../models/travel_preference.dart';
import '../widgets/travel_preference_chip.dart';

/// Screen allowing the user to view and toggle their travel preferences across categories.
class TravelPreferencesPage extends StatefulWidget {
  final List<TravelPreference>? initialPreferences;
  final ValueChanged<List<TravelPreference>>? onPreferencesSaved;

  const TravelPreferencesPage({
    super.key,
    this.initialPreferences,
    this.onPreferencesSaved,
  });

  @override
  State<TravelPreferencesPage> createState() => _TravelPreferencesPageState();
}

class _TravelPreferencesPageState extends State<TravelPreferencesPage> {
  late List<TravelPreference> _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = List.from(widget.initialPreferences ?? MockProfileData.preferences);
  }

  void _togglePreference(String id) {
    setState(() {
      _preferences = _preferences.map((p) {
        if (p.id == id) {
          return p.copyWith(isSelected: !p.isSelected);
        }
        return p;
      }).toList();
    });
  }

  void _savePreferences() {
    widget.onPreferencesSaved?.call(_preferences);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Travel preferences updated! Trippy will adapt 🦊✨',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFE65100),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1600),
      ),
    );

    Navigator.of(context).pop(_preferences);
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    final categories = [
      {'name': 'Travel Style', 'icon': '🧭', 'desc': 'How you pace and approach trips'},
      {'name': 'Food', 'icon': '🍜', 'desc': 'Your culinary tastes & dietary choices'},
      {'name': 'Activities', 'icon': '📸', 'desc': 'Experiences you look for'},
      {'name': 'Schedule', 'icon': '⏰', 'desc': 'Your daily adventure rhythm'},
      {'name': 'Crowd', 'icon': '👥', 'desc': 'Your density & ambiance comfort'},
    ];

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
          'Travel Preferences',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: darkBrown,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _savePreferences,
            child: Text(
              'Save',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: brandOrange,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFCC80),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap the tags that best describe your travel vibe. Trippy uses these to tailor daily itineraries and recommendations!',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFBF360C),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Categories List
              ...categories.map((cat) {
                final catName = cat['name']!;
                final catIcon = cat['icon']!;
                final catDesc = cat['desc']!;
                final catPrefs = _preferences.where((p) => p.category == catName).toList();

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(18),
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
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(catIcon, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            catName,
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        catDesc,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: catPrefs.map((pref) {
                          return TravelPreferenceChip(
                            label: pref.name,
                            icon: pref.icon,
                            isSelected: pref.isSelected,
                            onTap: () => _togglePreference(pref.id),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Save CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandOrange,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Update Travel Preferences',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
