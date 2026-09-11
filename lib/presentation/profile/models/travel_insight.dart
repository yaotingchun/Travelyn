/// Model representing AI-generated personalization insights learned by Trippy.
class TravelInsight {
  final String title;
  final String description;
  final String icon;
  final String category; // 'preference', 'avoidance', 'pattern', 'habit'

  const TravelInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
  });
}
