import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_profile.dart';

/// Screen allowing the user to view and edit their core identity details:
/// Photo, Full Name, Username, Email, Bio, and Home City.
class EditProfilePage extends StatefulWidget {
  final UserProfile profile;
  final ValueChanged<UserProfile>? onProfileSaved;

  const EditProfilePage({
    super.key,
    required this.profile,
    this.onProfileSaved,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _homeCityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Diana');
    _usernameController = TextEditingController(text: widget.profile.username);
    _emailController = TextEditingController(text: widget.profile.email);
    _bioController = TextEditingController(text: widget.profile.bio);
    _homeCityController = TextEditingController(text: widget.profile.homeCity);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _homeCityController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final updated = widget.profile.copyWith(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      bio: _bioController.text.trim(),
      homeCity: _homeCityController.text.trim(),
    );

    widget.onProfileSaved?.call(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile updated successfully! ✨',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFE65100),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1500),
      ),
    );

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE65100);
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
          'Edit Profile',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: darkBrown,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Save',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: brandOrange,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Change Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFCC80),
                              width: 2.0,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            widget.profile.avatarPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, size: 50, color: brandOrange),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: brandOrange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Change Photo',
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: brandOrange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields Card
              Container(
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
                    _buildTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      hint: 'Your full name',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Username',
                      controller: _usernameController,
                      icon: Icons.alternate_email_rounded,
                      hint: '@username',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      hint: 'explorer@travelyn.com',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Bio',
                      controller: _bioController,
                      icon: Icons.chat_bubble_outline_rounded,
                      hint: 'Tell travelers about yourself',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Home City',
                      controller: _homeCityController,
                      icon: Icons.location_on_outlined,
                      hint: 'e.g. Kuala Lumpur',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandOrange,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.fredoka(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: darkBrown,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.nunito(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: darkBrown,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunito(color: textMuted.withValues(alpha: 0.6)),
            prefixIcon: maxLines == 1
                ? Icon(icon, size: 20, color: const Color(0xFF8D6E63))
                : null,
            filled: true,
            fillColor: const Color(0xFFFAF7F2),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEDE4DA), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE65100), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
