import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryItem {
  final String label;
  final Widget icon;

  const CategoryItem({
    required this.label,
    required this.icon,
  });
}

class ForumCategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const ForumCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static final List<CategoryItem> categories = [
    const CategoryItem(
      label: 'All',
      icon: Icon(Icons.explore_rounded, size: 16, color: Colors.white),
    ),
    const CategoryItem(
      label: 'Destinations',
      icon: Icon(Icons.map_outlined, size: 16, color: Color(0xFF6D5A50)),
    ),
    const CategoryItem(
      label: 'Tips & Guides',
      icon: Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFFB57D18)),
    ),
    const CategoryItem(
      label: 'Food',
      icon: Icon(Icons.restaurant_rounded, size: 16, color: Color(0xFFC8452D)),
    ),
    const CategoryItem(
      label: 'General',
      icon: Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF5E4EB5)),
    ),
    const CategoryItem(
      label: 'Solo Travel',
      icon: Icon(Icons.backpack_outlined, size: 16, color: Color(0xFF2E7D32)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const brandOrange = Color(0xFFE65100);

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length + 1, // +1 for the trailing chevron
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == categories.length) {
            // Trailing subtle chevron indicator matching design
            return Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3ECE4),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE8DFD5), width: 0.8),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFF8C7B73),
                ),
              ),
            );
          }

          final item = categories[index];
          final isSelected = selectedCategory == item.label;

          return GestureDetector(
            onTap: () => onCategorySelected(item.label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFFF7A00), Color(0xFFE65100)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFFEAE2D8),
                  width: 1.0,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: brandOrange.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  else
                    BoxShadow(
                      color: darkBrown.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    const Padding(
                      padding: EdgeInsets.only(right: 6.0),
                      child: Icon(Icons.flash_on_rounded, size: 15, color: Colors.white),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: item.icon,
                    ),
                  Text(
                    item.label,
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : darkBrown,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
