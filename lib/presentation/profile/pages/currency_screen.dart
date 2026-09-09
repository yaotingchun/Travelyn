import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Data class representing a supported currency option.
class CurrencyOption {
  final String code;
  final String symbol;
  final String name;
  final String flag;

  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });

  String get displayName => '$code ($symbol)';
}

/// Screen allowing the user to select and save their preferred travel currency independently.
class CurrencyScreen extends StatefulWidget {
  final String currentCurrency;
  final ValueChanged<String>? onCurrencySelected;

  const CurrencyScreen({
    super.key,
    this.currentCurrency = 'MYR',
    this.onCurrencySelected,
  });

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  late String _selectedCurrency;

  static const List<CurrencyOption> supportedCurrencies = [
    CurrencyOption(
      code: 'MYR',
      symbol: 'RM',
      name: 'Malaysian Ringgit',
      flag: '🇲🇾',
    ),
    CurrencyOption(
      code: 'USD',
      symbol: '\$',
      name: 'United States Dollar',
      flag: '🇺🇸',
    ),
    CurrencyOption(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese Yen',
      flag: '🇯🇵',
    ),
    CurrencyOption(
      code: 'KRW',
      symbol: '₩',
      name: 'South Korean Won',
      flag: '🇰🇷',
    ),
    CurrencyOption(
      code: 'SGD',
      symbol: 'S\$',
      name: 'Singapore Dollar',
      flag: '🇸🇬',
    ),
    CurrencyOption(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      flag: '🇪🇺',
    ),
    CurrencyOption(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound Sterling',
      flag: '🇬🇧',
    ),
    CurrencyOption(
      code: 'THB',
      symbol: '฿',
      name: 'Thai Baht',
      flag: '🇹🇭',
    ),
    CurrencyOption(
      code: 'AUD',
      symbol: 'A\$',
      name: 'Australian Dollar',
      flag: '🇦🇺',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.currentCurrency;
  }

  void _saveCurrency() {
    widget.onCurrencySelected?.call(_selectedCurrency);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Currency set to $_selectedCurrency 🪙',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFE65100),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1500),
      ),
    );

    Navigator.of(context).pop(_selectedCurrency);
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
          'Currency',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: darkBrown,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveCurrency,
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
                    const Text('🪙', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select your default currency for trip budgets, expense splitting, bookings, and activity cost estimates.',
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

              // Supported Currencies Card
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
                  children: List.generate(supportedCurrencies.length, (index) {
                    final curr = supportedCurrencies[index];
                    final isSelected = curr.code == _selectedCurrency ||
                        _selectedCurrency.startsWith(curr.code);
                    final isLast = index == supportedCurrencies.length - 1;

                    return Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCurrency = curr.code;
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
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFFFEDE0)
                                          : const Color(0xFFFAF7F2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFFFCC80)
                                            : const Color(0xFFEDE4DA),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        curr.flag,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              curr.code,
                                              style: GoogleFonts.fredoka(
                                                fontSize: 15,
                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                color: isSelected ? const Color(0xFFBF360C) : darkBrown,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF5EFEB),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                curr.symbol,
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF8D6E63),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          curr.name,
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
                  onPressed: _saveCurrency,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandOrange,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Set Currency',
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
