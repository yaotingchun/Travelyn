import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Model representing an @mentionable entity in the chat
class MentionItem {
  final String id;
  final String name;
  final String tag;
  final String? subtitle;
  final String? avatarPath;
  final IconData? icon;
  final bool isAI;
  final bool isAll;

  const MentionItem({
    required this.id,
    required this.name,
    required this.tag,
    this.subtitle,
    this.avatarPath,
    this.icon,
    this.isAI = false,
    this.isAll = false,
  });
}

/// Floating popup card showing mention suggestions (@all, @Travelyn, @members)
class TripMentionPopup extends StatelessWidget {
  final String query;
  final ValueChanged<MentionItem> onSelected;

  const TripMentionPopup({
    super.key,
    required this.query,
    required this.onSelected,
  });

  static const List<MentionItem> allMentions = [
    MentionItem(
      id: 'all',
      name: 'all',
      tag: '@all',
      subtitle: 'Mention all members in this chat',
      icon: Icons.groups_rounded,
      isAll: true,
    ),
    MentionItem(
      id: 'travelyn',
      name: 'Travelyn',
      tag: '@Travelyn',
      avatarPath: 'assets/mascot/avatar.png',
      isAI: true,
    ),
    MentionItem(
      id: 'alex',
      name: 'Alex',
      tag: '@Alex',
      avatarPath: 'assets/journey/member_avatar_1.jpg',
    ),
    MentionItem(
      id: 'brenda',
      name: 'Brenda',
      tag: '@Brenda',
      avatarPath: 'assets/journey/member_avatar_2.jpg',
    ),
    MentionItem(
      id: 'charlie',
      name: 'Charlie',
      tag: '@Charlie',
      avatarPath: 'assets/journey/member_avatar_3.jpg',
    ),
    MentionItem(
      id: 'diana',
      name: 'Diana',
      tag: '@Diana',
      avatarPath: 'assets/journey/member_avatar_4.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cleanQuery = query.toLowerCase().trim();
    final filtered = allMentions.where((item) {
      if (cleanQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(cleanQuery) ||
          item.tag.toLowerCase().contains(cleanQuery);
    }).toList();

    if (filtered.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEDE3D7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1C14).withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: const Color(0xFF2E1C14).withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            thickness: 0.7,
            indent: 64,
            endIndent: 16,
            color: Color(0xFFF3ECE4),
          ),
          itemBuilder: (context, index) {
            final item = filtered[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      // Avatar or Icon
                      _buildAvatar(item),
                      const SizedBox(width: 12),

                      // Name and optional subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2E1C14),
                                  ),
                                ),
                                if (item.isAI) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF8A00),
                                          Color(0xFFE55100),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'AI',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.fredoka(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF8C7A6B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar(MentionItem item) {
    if (item.isAll) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3EAE0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE4D5C7),
            width: 1,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.groups_rounded,
            size: 23,
            color: Color(0xFF6B4226),
          ),
        ),
      );
    }

    if (item.avatarPath != null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isAI
                ? const Color(0xFFFF9E3D)
                : const Color(0xFFE5DACF),
            width: item.isAI ? 1.6 : 1,
          ),
          boxShadow: [
            if (item.isAI)
              BoxShadow(
                color: const Color(0xFFFF8A00).withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Image.asset(
            item.avatarPath!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFEDE3D7),
              child: const Icon(Icons.person, color: Color(0xFF8C7A6B)),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF3EAE0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Icon(Icons.person, color: Color(0xFF6B4226)),
      ),
    );
  }
}
