/// Model representing personal travel milestones/achievements.
class AchievementItem {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final String? unlockedDate;
  final double progress; // 0.0 to 1.0

  const AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedDate,
    this.progress = 1.0,
  });
}
