import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Data class representing a supported language option.
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

/// Screen allowing the user to select and save their preferred app language independently.
class LanguageScreen extends StatefulWidget {
  final String currentLanguage;
  final ValueChanged<String>? onLanguageSelected;

  const LanguageScreen({
    super.key,
    this.currentLanguage = 'English',
    this.onLanguageSelected,
  });

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedLanguage;

  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English (US)',
      flag: '🇺🇸',
    ),
    LanguageOption(
      code: 'zh',
      name: '中文',
      nativeName: '简体中文 / 繁體中文',
      flag: '🇨🇳',
    ),
    LanguageOption(
      code: 'ms',
      name: 'Bahasa Melayu',
      nativeName: 'Bahasa Melayu',
      flag: '🇲🇾',
    ),
    LanguageOption(
      code: 'ja',
      name: '日本語',
      nativeName: '日本語 (Japanese)',
      flag: '🇯🇵',
    ),
    LanguageOption(
      code: 'ko',
      name: '한국어',
      nativeName: '한국어 (Korean)',
      flag: '🇰🇷',
    ),
    LanguageOption(
      code: 'es',
      name: 'Español',
      nativeName: 'Español (Spanish)',
      flag: '🇪🇸',
    ),
    LanguageOption(
      code: 'fr',
      name: 'Français',
      nativeName: 'Français (French)',
      flag: '🇫🇷',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
  }

  void _saveLanguage() {
    widget.onLanguageSelected?.call(_selectedLanguage);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Language set to $_selectedLanguage ✨',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFE65100),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1500),
      ),
    );

    Navigator.of(context).pop(_selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

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
          'Language',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: darkBrown,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveLanguage,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFCC80),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🌐', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Choose your preferred language for app navigation, destination tips, and Trippy AI suggestions.',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFBF360C),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Supported Languages Card
              Container(
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
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(supportedLanguages.length, (index) {
                    final lang = supportedLanguages[index];
                    final isSelected = lang.name == _selectedLanguage ||
                        lang.name.toLowerCase() == _selectedLanguage.toLowerCase();
                    final isLast = index == supportedLanguages.length - 1;

                    return Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedLanguage = lang.name;
                              });
                            },
                            borderRadius: BorderRadius.vertical(
                              top: index == 0 ? const Radius.circular(24) : Radius.zero,
                              bottom: isLast ? const Radius.circular(24) : Radius.zero,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              child: Row(
                                children: [
                                  Text(
                                    lang.flag,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang.name,
                                          style: GoogleFonts.fredoka(
                                            fontSize: 15,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                            color: isSelected ? const Color(0xFFBF360C) : darkBrown,
                                          ),
                                        ),
                                        Text(
                                          lang.nativeName,
                                          style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: isSelected ? brandOrange : const Color(0xFFBCAAA4),
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Divider(
                              height: 1,
                              thickness: 0.8,
                              color: Color(0xFFF0EAE1),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveLanguage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandOrange,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Set Language',
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
}
