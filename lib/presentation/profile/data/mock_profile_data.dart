import 'package:flutter/material.dart';
import '../models/achievement_item.dart';
import '../models/travel_dna_dimension.dart';
import '../models/travel_insight.dart';
import '../models/travel_preference.dart';
import '../models/user_profile.dart';

/// Single source of mock data for Explorer (@explorer, explorer@travelyn.com).
class MockProfileData {
  static final UserProfile defaultProfile = UserProfile(
    name: 'Diana',
    username: '@explorer',
    email: 'explorer@travelyn.com',
    bio: 'Always looking for good food & hidden places ✨',
    avatarPath: 'assets/mascot/avatar.png',
    homeCity: 'Kuala Lumpur',
    preferredLanguage: 'English',
    currency: 'MYR',
    travelIdentities: const [
      '✨ Explorer',
      '🍜 Foodie',
      '🏮 Local Lover',
    ],
    tripsCount: 8,
    placesCount: 27,
    countriesCount: 4,
    memoriesCount: 19,
  );

  static const List<TravelDnaDimension> dnaDimensions = [
    TravelDnaDimension(
      name: 'Food',
      icon: '🍜',
      score: 92,
      barColor: Color(0xFFE65100),
    ),
    TravelDnaDimension(
      name: 'Culture',
      icon: '🏮',
      score: 88,
      barColor: Color(0xFFD84315),
    ),
    TravelDnaDimension(
      name: 'Photos',
      icon: '📸',
      score: 82,
      barColor: Color(0xFFF57C00),
    ),
    TravelDnaDimension(
      name: 'Adventure',
      icon: '🧗',
      score: 70,
      barColor: Color(0xFFFF8F00),
    ),
    TravelDnaDimension(
      name: 'Nature',
      icon: '🌿',
      score: 62,
      barColor: Color(0xFF43A047),
    ),
    TravelDnaDimension(
      name: 'Relaxing',
      icon: '🏖',
      score: 55,
      barColor: Color(0xFF00ACC1),
    ),
    TravelDnaDimension(
      name: 'Shopping',
      icon: '🛍',
      score: 35,
      barColor: Color(0xFF8E24AA),
    ),
  ];

  static const List<String> dnaHighlightTags = [
    '🏮 Local Immersion',
    '🍜 Foodie',
    '📸 Photo Hunter',
    '🌿 Slow Travel',
  ];

  static const String trippyQuote =
      'You usually prefer local food, hidden neighbourhoods, and relaxed schedules.\n\nI\'ll keep that in mind for your next adventure! ✨';

  static const List<TravelInsight> insights = [
    TravelInsight(
      title: 'Your favorite travel style',
      description: 'Local experiences & hidden alleyway finds',
      icon: '🏮',
      category: 'preference',
    ),
    TravelInsight(
      title: 'Your favorite activity',
      description: 'Food hunting & neighborhood cafes',
      icon: '🍜',
      category: 'preference',
    ),
    TravelInsight(
      title: 'Your preferred pace',
      description: 'Relaxed & immersive (no rush)',
      icon: '🌿',
      category: 'habit',
    ),
    TravelInsight(
      title: 'Your usual trip rhythm',
      description: '2–3 main quality activities per day',
      icon: '⏳',
      category: 'habit',
    ),
    TravelInsight(
      title: 'Very crowded mega-attractions',
      description: 'You prefer quieter time slots or off-peak hours',
      icon: '🚫',
      category: 'avoidance',
    ),
    TravelInsight(
      title: 'Extremely early morning starts',
      description: 'You prefer late mornings starting past 9:30 AM',
      icon: '⏰',
      category: 'avoidance',
    ),
    TravelInsight(
      title: 'Overpacked 10-item itineraries',
      description: 'Trippy gives you buffer time to explore freely',
      icon: '📋',
      category: 'avoidance',
    ),
  ];

  static const List<TravelPreference> preferences = [
    // Travel Style
    TravelPreference(id: 's1', category: 'Travel Style', name: 'Local Immersion', icon: '🏮', isSelected: true),
    TravelPreference(id: 's2', category: 'Travel Style', name: 'Slow Travel', icon: '🌿', isSelected: true),
    TravelPreference(id: 's3', category: 'Travel Style', name: 'Adventure', icon: '🧗', isSelected: true),
    TravelPreference(id: 's4', category: 'Travel Style', name: 'Chill', icon: '🏖', isSelected: false),
    TravelPreference(id: 's5', category: 'Travel Style', name: 'Luxury', icon: '✨', isSelected: false),
    TravelPreference(id: 's6', category: 'Travel Style', name: 'Budget', icon: '🪙', isSelected: false),
    TravelPreference(id: 's7', category: 'Travel Style', name: 'Fast-paced', icon: '⚡', isSelected: false),

    // Food
    TravelPreference(id: 'f1', category: 'Food', name: 'Local Food', icon: '🍜', isSelected: true),
    TravelPreference(id: 'f2', category: 'Food', name: 'Street Food', icon: '🍢', isSelected: true),
    TravelPreference(id: 'f3', category: 'Food', name: 'Cafes', icon: '☕', isSelected: true),
    TravelPreference(id: 'f4', category: 'Food', name: 'Fine Dining', icon: '🍷', isSelected: false),
    TravelPreference(id: 'f5', category: 'Food', name: 'Vegetarian', icon: '🥗', isSelected: false),

    // Activities
    TravelPreference(id: 'a1', category: 'Activities', name: 'Photography', icon: '📸', isSelected: true),
    TravelPreference(id: 'a2', category: 'Activities', name: 'Culture', icon: '🏛', isSelected: true),
    TravelPreference(id: 'a3', category: 'Activities', name: 'Nature', icon: '🌲', isSelected: true),
    TravelPreference(id: 'a4', category: 'Activities', name: 'Museums', icon: '🎨', isSelected: false),
    TravelPreference(id: 'a5', category: 'Activities', name: 'Shopping', icon: '🛍', isSelected: false),
    TravelPreference(id: 'a6', category: 'Activities', name: 'Nightlife', icon: '🍸', isSelected: false),

    // Schedule
    TravelPreference(id: 'sc1', category: 'Schedule', name: 'Flexible', icon: '⏳', isSelected: true),
    TravelPreference(id: 'sc2', category: 'Schedule', name: 'Late Start', icon: '☕', isSelected: true),
    TravelPreference(id: 'sc3', category: 'Schedule', name: 'Early Bird', icon: '🌅', isSelected: false),

    // Crowd
    TravelPreference(id: 'c1', category: 'Crowd', name: 'Avoid Crowds', icon: '🌿', isSelected: true),
    TravelPreference(id: 'c2', category: 'Crowd', name: 'Neutral', icon: '👌', isSelected: false),
    TravelPreference(id: 'c3', category: 'Crowd', name: 'Love Popular Attractions', icon: '🎆', isSelected: false),
  ];

  static const List<AchievementItem> achievements = [
    AchievementItem(
      id: 'ach_1',
      title: 'First Adventure',
      description: 'Completed your very first Travelyn trip',
      icon: '✈️',
      isUnlocked: true,
      unlockedDate: 'Oct 2025',
    ),
    AchievementItem(
      id: 'ach_2',
      title: 'Food Hunter',
      description: 'Checked into 15+ authentic local culinary spots',
      icon: '🍜',
      isUnlocked: true,
      unlockedDate: 'Dec 2025',
    ),
    AchievementItem(
      id: 'ach_3',
      title: '3 Countries',
      description: 'Explored and created memories across 3+ countries',
      icon: '🌏',
      isUnlocked: true,
      unlockedDate: 'Jan 2026',
    ),
    AchievementItem(
      id: 'ach_4',
      title: 'Local Explorer',
      description: 'Found 10+ hidden neighborhood gems off the beaten path',
      icon: '🏮',
      isUnlocked: true,
      unlockedDate: 'Feb 2026',
    ),
    AchievementItem(
      id: 'ach_5',
      title: 'Memory Maker',
      description: 'Logged 20+ photo journal moments in your travel diary',
      icon: '📸',
      isUnlocked: false,
      progress: 0.85,
    ),
    AchievementItem(
      id: 'ach_6',
      title: 'Group Explorer',
      description: 'Organized a collaborative group trip with 3+ friends',
      icon: '👥',
      isUnlocked: false,
      progress: 0.60,
    ),
  ];
}
