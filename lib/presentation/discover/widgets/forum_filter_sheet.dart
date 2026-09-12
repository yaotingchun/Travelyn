import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForumFilterSheet extends StatefulWidget {
  final String currentSort;
  final String currentCategory;
  final Function(String sort, String category) onApply;

  const ForumFilterSheet({
    super.key,
    required this.currentSort,
    required this.currentCategory,
    required this.onApply,
  });

  @override
  State<ForumFilterSheet> createState() => _ForumFilterSheetState();
}

class _ForumFilterSheetState extends State<ForumFilterSheet> {
  late String _selectedSort;
  late String _selectedCategory;

  final List<String> _sortOptions = ['Hot', 'Recent', 'Most Answered'];
  final List<String> _categoryOptions = [
    'All',
    'Destinations',
    'Tips & Guides',
    'Food',
    'General',
    'Solo Travel',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
    _selectedCategory = widget.currentCategory;
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const brandOrange = Color(0xFFE65100);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF7F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDCD2C6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title & Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Discussions',
                style: GoogleFonts.fredoka(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSort = 'Hot';
                    _selectedCategory = 'All';
                  });
                },
                child: Text(
                  'Reset',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: brandOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Sort by section
          Text(
            'Sort By',
            style: GoogleFonts.fredoka(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _sortOptions.map((opt) {
              final isSel = _selectedSort == opt;
              return ChoiceChip(
                label: Text(opt),
                selected: isSel,
                onSelected: (val) {
                  if (val) setState(() => _selectedSort = opt);
                },
                selectedColor: brandOrange,
                backgroundColor: const Color(0xFFF3ECE4),
                labelStyle: GoogleFonts.fredoka(
                  fontSize: 12.5,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel ? Colors.white : darkBrown,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSel ? brandOrange : const Color(0xFFE4DAD0),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Category section
          Text(
            'Category',
            style: GoogleFonts.fredoka(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categoryOptions.map((cat) {
              final isSel = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: isSel,
                onSelected: (val) {
                  if (val) setState(() => _selectedCategory = cat);
                },
                selectedColor: const Color(0xFF9E4822),
                backgroundColor: const Color(0xFFF3ECE4),
                labelStyle: GoogleFonts.fredoka(
                  fontSize: 12.5,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel ? Colors.white : darkBrown,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSel ? const Color(0xFF9E4822) : const Color(0xFFE4DAD0),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedSort, _selectedCategory);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brandOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.fredoka(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
