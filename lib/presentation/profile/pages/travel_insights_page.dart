import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_profile_data.dart';
import '../models/travel_insight.dart';

/// Screen presenting AI personalization insights and explaining how Trippy learns.
class TravelInsightsPage extends StatelessWidget {
  const TravelInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);

    final preferencesList = MockProfileData.insights
        .where((i) => i.category == 'preference' || i.category == 'habit')
        .toList();
    final avoidancesList = MockProfileData.insights
        .where((i) => i.category == 'avoidance')
        .toList();

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
          'Travel Insights',
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
              // Trippy Mascot Header Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFCC80),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: brandOrange.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/mascot/avatar.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Text('🦊', style: TextStyle(fontSize: 26))),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trippy\'s Personal Notes',
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFBF360C),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Here is what I\'ve learned from your 8 trips and voting habits! 🦊',
                            style: GoogleFonts.nunito(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: darkBrown,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Section: What You Love
              Text(
                '✨ What You Love & Tend to Enjoy',
                style: GoogleFonts.fredoka(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),
              const SizedBox(height: 12),
              ...preferencesList.map((insight) => _buildInsightCard(insight, isAvoidance: false)),

              const SizedBox(height: 20),

              // Section: What You Tend to Avoid
              Text(
                '🚫 Things You Tend to Avoid',
                style: GoogleFonts.fredoka(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),
              const SizedBox(height: 12),
              ...avoidancesList.map((insight) => _buildInsightCard(insight, isAvoidance: true)),

              const SizedBox(height: 24),

              // Section: How Trippy Learns (Visual Flow)
              _buildLearningFlowCard(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(TravelInsight insight, {required bool isAvoidance}) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvoidance ? const Color(0xFFFFCDD2) : const Color(0xFFEDE4DA),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1C14).withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isAvoidance
                  ? const Color(0xFFFFEBEE)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                insight.icon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: GoogleFonts.fredoka(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: darkBrown,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  insight.description,
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningFlowCard() {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);

    final steps = [
      {'icon': '🗳️', 'title': 'Preference votes', 'desc': 'When you vote in group trip polls'},
      {'icon': '📍', 'title': 'Places you visit', 'desc': 'Check-ins and locations in your itinerary'},
      {'icon': '⭐', 'title': 'Your ratings', 'desc': 'Reactions and reviews after experiencing a spot'},
      {'icon': '💬', 'title': 'Your conversations', 'desc': 'Group chat discussions and questions to Trippy'},
      {'icon': '✨', 'title': 'Your Travel DNA', 'desc': 'Gradually refines into your unique identity'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Trippy learns from your trips',
                style: GoogleFonts.fredoka(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'The more you plan and travel with Travelyn, the smarter and more personalized your recommendations become.',
            style: GoogleFonts.nunito(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7A6860),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),

          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isLast
                            ? const Color(0xFFFFF3E0)
                            : const Color(0xFFFAF7F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isLast ? brandOrange : const Color(0xFFEDE4DA),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          step['icon']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title']!,
                            style: GoogleFonts.fredoka(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isLast ? brandOrange : darkBrown,
                            ),
                          ),
                          Text(
                            step['desc']!,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF7A6860),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.only(left: 18, top: 4, bottom: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 2,
                        height: 14,
                        color: const Color(0xFFFFCC80),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
