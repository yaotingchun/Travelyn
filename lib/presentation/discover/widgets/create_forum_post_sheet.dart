import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/forum_service.dart';

class CreateForumPostSheet extends StatefulWidget {
  const CreateForumPostSheet({super.key});

  @override
  State<CreateForumPostSheet> createState() => _CreateForumPostSheetState();
}

class _CreateForumPostSheetState extends State<CreateForumPostSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _destinationController = TextEditingController();

  String _selectedCategory = 'Tips & Guides';
  final List<String> _categories = [
    'Tips & Guides',
    'Destinations',
    'Food',
    'General',
    'Solo Travel',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _submitPost() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final destination = _destinationController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a title and question/story!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    ForumService().addPost(
      title: title,
      content: content,
      category: _selectedCategory,
      destination: destination.isEmpty ? 'Global' : destination,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Your question was posted to the Travel Forum! 🎉'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
      child: SingleChildScrollView(
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

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECE0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.forum_outlined,
                    color: brandOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask Travellers',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                      ),
                    ),
                    Text(
                      'Share questions, advice, or trip recommendations',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFF8F7F77),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category choice
            Text(
              'Select Topic',
              style: GoogleFonts.fredoka(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _categories.map((cat) {
                  final isSel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                      selectedColor: brandOrange,
                      backgroundColor: const Color(0xFFF3ECE4),
                      labelStyle: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? Colors.white : darkBrown,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSel ? brandOrange : const Color(0xFFE4DAD0),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Destination input
            Text(
              'Destination (Optional)',
              style: GoogleFonts.fredoka(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: darkBrown,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _destinationController,
              style: GoogleFonts.nunito(fontSize: 13.5, color: darkBrown),
              decoration: InputDecoration(
                hintText: 'e.g. Tokyo, Kyoto, Seoul, Paris...',
                hintStyle: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF9E8E86)),
                filled: true,
                fillColor: const Color(0xFFF3ECE4),
                prefixIcon: const Icon(Icons.place_outlined, size: 18, color: Color(0xFF9E8E86)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              'Question or Discussion Title',
              style: GoogleFonts.fredoka(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: darkBrown,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: darkBrown),
              decoration: InputDecoration(
                hintText: 'e.g. Best time for Mt Fuji views?',
                hintStyle: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF9E8E86)),
                filled: true,
                fillColor: const Color(0xFFF3ECE4),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Content
            Text(
              'Details & Context',
              style: GoogleFonts.fredoka(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: darkBrown,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _contentController,
              maxLines: 4,
              style: GoogleFonts.nunito(fontSize: 13.5, color: darkBrown),
              decoration: InputDecoration(
                hintText: 'Share more context, what you have researched, dates, preferences...',
                hintStyle: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF9E8E86)),
                filled: true,
                fillColor: const Color(0xFFF3ECE4),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Post Discussion',
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
