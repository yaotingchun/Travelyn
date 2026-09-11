import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen allowing the user to configure push and in-app notification toggles.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _tripReminders = true;
  bool _morningBriefing = true;
  bool _trippySuggestions = true;
  bool _locationCheckIn = true;
  bool _diaryReminders = false;
  bool _flightAlerts = true;
  bool _dynamicTripChanges = true;

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
          'Notifications',
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
              // Trip & Routine Notifications
              _buildSectionTitle('TRIP & ROUTINE'),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Trip reminders',
                      subtitle: 'Upcoming departures & packing countdowns',
                      value: _tripReminders,
                      onChanged: (val) => setState(() => _tripReminders = val),
                      showDivider: true,
                    ),
                    _buildSwitchTile(
                      title: 'Morning briefing',
                      subtitle: 'Daily weather, agenda & first stop reminder',
                      value: _morningBriefing,
                      onChanged: (val) => setState(() => _morningBriefing = val),
                      showDivider: true,
                    ),
                    _buildSwitchTile(
                      title: 'Location check-in',
                      subtitle: 'Prompts to record memories at visited spots',
                      value: _locationCheckIn,
                      onChanged: (val) => setState(() => _locationCheckIn = val),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // AI & Dynamic Updates
              _buildSectionTitle('AI & DYNAMIC UPDATES'),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Trippy suggestions',
                      subtitle: 'Proactive tips for nearby hidden cafes & stops',
                      value: _trippySuggestions,
                      onChanged: (val) => setState(() => _trippySuggestions = val),
                      showDivider: true,
                    ),
                    _buildSwitchTile(
                      title: 'Dynamic trip changes',
                      subtitle: 'Alerts when itinerary adjusts due to rain/traffic',
                      value: _dynamicTripChanges,
                      onChanged: (val) => setState(() => _dynamicTripChanges = val),
                      showDivider: true,
                    ),
                    _buildSwitchTile(
                      title: 'Flight & transit alerts',
                      subtitle: 'Gate changes, delays, and departure boarding',
                      value: _flightAlerts,
                      onChanged: (val) => setState(() => _flightAlerts = val),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Diary & Memories
              _buildSectionTitle('DIARY & MEMORIES'),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Diary reminders',
                      subtitle: 'Evening reflection prompts to journal the day',
                      value: _diaryReminders,
                      onChanged: (val) => setState(() => _diaryReminders = val),
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
