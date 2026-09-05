/// Model representing a preference tag or category option.
class TravelPreference {
  final String id;
  final String category;
  final String name;
  final String icon;
  final bool isSelected;

  const TravelPreference({
    required this.id,
    required this.category,
    required this.name,
    required this.icon,
    this.isSelected = false,
  });

  TravelPreference copyWith({
    String? id,
    String? category,
    String? name,
    String? icon,
    bool? isSelected,
  }) {
    return TravelPreference(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
