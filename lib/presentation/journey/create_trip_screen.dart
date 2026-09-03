import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/destination_service.dart';

enum TripType { solo, group }

/// Screen allowing users to create and plan a new trip.
/// Matches the provided UI reference with "Where to next?" mascot,
/// destination card, date range selector, and solo/group trip type choices.
class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _destinationFocusNode = FocusNode();
  List<Destination> _destinationSuggestions = [];
  bool _showSuggestions = false;
  DateTime? _startDate;
  DateTime? _endDate;
  TripType _selectedTripType = TripType.solo;

  @override
  void initState() {
    super.initState();
    _destinationFocusNode.addListener(() {
      if (!_destinationFocusNode.hasFocus) {
        setState(() {
          _showSuggestions = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  void _onDestinationQueryChanged(String query) {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      setState(() {
        _destinationSuggestions = [];
        _showSuggestions = false;
      });
    } else {
      final matches = DestinationService.search(cleanQuery);
      setState(() {
        _destinationSuggestions = matches;
        _showSuggestions = true;
      });
    }
  }

  void _selectDestination(Destination destination) {
    _destinationController.text = destination.displayName;
    setState(() {
      _destinationSuggestions = [];
      _showSuggestions = false;
    });
    _destinationFocusNode.unfocus();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE65100),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2E1C14),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE65100),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2E1C14),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  bool get _isFormValid {
    return _destinationController.text.trim().isNotEmpty &&
        _startDate != null &&
        _endDate != null;
  }

  void _onNext() {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a destination to proceed.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E1C14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final tripTypeStr =
        _selectedTripType == TripType.solo ? 'Solo Trip' : 'Group Trip';
    final dateStr = _startDate != null && _endDate != null
        ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
        : 'Dates to be decided';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFDF7F0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'Adventure Ready!',
          style: GoogleFonts.fredoka(
            color: const Color(0xFF2E1C14),
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your journey to $destination ($tripTypeStr) has been created.',
              style: const TextStyle(
                color: Color(0xFF5D4A3E),
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: GoogleFonts.fredoka(
                color: const Color(0xFFE65100),
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              'Back to Journey',
              style: GoogleFonts.fredoka(
                color: const Color(0xFFE65100),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);
    const lightBorder = Color(0xFFEFE6DC);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Top App Bar: Back arrow + "Create Trip"
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: darkBrown,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Create Trip',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: darkBrown,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44), // Balanced spacer for back button
                  ],
                ),
              ),

              // 2. Scrollable Body Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Header: "Where to next?" + Mascot
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Where to next?',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: darkBrown,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Let's plan your adventure",
                                  style: GoogleFonts.fredoka(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w400,
                                    color: textMuted,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Mascot Image
                          SizedBox(
                            width: 116,
                            height: 116,
                            child: Image.asset(
                              'assets/journey/where_to_next_fox.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/home/where_to_next_fox.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (ctx, err, st) {
                                    return const Icon(
                                      Icons.pets_rounded,
                                      size: 54,
                                      color: brandOrange,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Card 1: Destination
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: _showSuggestions
                              ? Border.all(
                                  color: brandOrange.withValues(alpha: 0.5),
                                  width: 1.2,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: darkBrown.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Destination',
                              style: GoogleFonts.fredoka(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: textMuted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.place_outlined,
                                  color: Color(0xFF9E8E84),
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _destinationController,
                                    focusNode: _destinationFocusNode,
                                    onChanged: _onDestinationQueryChanged,
                                    style: GoogleFonts.fredoka(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w500,
                                      color: darkBrown,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter location',
                                      hintStyle: TextStyle(
                                        color: Color(0xFFB8A99E),
                                        fontSize: 14.5,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (_destinationController.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _destinationController.clear();
                                      _onDestinationQueryChanged('');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF1E9E0),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: Color(0xFF7A6860),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            // Substring-matched City Autocomplete Suggestions
                            if (_showSuggestions) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Divider(
                                  color: Color(0xFFF1E9E0),
                                  height: 1,
                                  thickness: 1,
                                ),
                              ),
                              if (_destinationSuggestions.isNotEmpty)
                                ListView.separated(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _destinationSuggestions.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                    color: Color(0xFFFBF5EE),
                                    height: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    final dest = _destinationSuggestions[index];
                                    return InkWell(
                                      onTap: () => _selectDestination(dest),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                          vertical: 9.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              dest.flag,
                                              style: const TextStyle(fontSize: 18),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                dest.displayName,
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: darkBrown,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFAF2E9),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                dest.region,
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFF8A6C58),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              else
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.search_off_rounded,
                                        size: 18,
                                        color: Color(0xFFB5A69D),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'No exact city match. You can still use this as custom location.',
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Card 2: Dates (From & To)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: darkBrown.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "From" Selector
                            GestureDetector(
                              onTap: _pickStartDate,
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'From',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        color: Color(0xFF9E8E84),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _startDate != null
                                            ? _formatDate(_startDate!)
                                            : 'Select start date',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w500,
                                          color: _startDate != null
                                              ? darkBrown
                                              : const Color(0xFFB8A99E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Divider(
                                color: Color(0xFFF1E9E0),
                                height: 1,
                                thickness: 1,
                              ),
                            ),

                            // "To" Selector
                            GestureDetector(
                              onTap: _pickEndDate,
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'To',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        color: Color(0xFF9E8E84),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _endDate != null
                                            ? _formatDate(_endDate!)
                                            : 'Select end date',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w500,
                                          color: _endDate != null
                                              ? darkBrown
                                              : const Color(0xFFB8A99E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Card 3: Trip Type (Solo vs Group)
                      Text(
                        'Trip type',
                        style: GoogleFonts.fredoka(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          // Solo Trip Card
                          Expanded(
                            child: _buildTripTypeCard(
                              type: TripType.solo,
                              title: 'Solo Trip',
                              subtitle: 'Just you and the world',
                              imageAsset: 'assets/journey/solo_trip.png',
                              isSelected: _selectedTripType == TripType.solo,
                              brandOrange: brandOrange,
                              darkBrown: darkBrown,
                              textMuted: textMuted,
                              lightBorder: lightBorder,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Group Trip Card
                          Expanded(
                            child: _buildTripTypeCard(
                              type: TripType.group,
                              title: 'Group Trip',
                              subtitle: 'Better together, more fun!',
                              imageAsset: 'assets/journey/group_trip.png',
                              isSelected: _selectedTripType == TripType.group,
                              brandOrange: brandOrange,
                              darkBrown: darkBrown,
                              textMuted: textMuted,
                              lightBorder: lightBorder,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // "Next" Button
                      GestureDetector(
                        onTap: _onNext,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _isFormValid
                                ? brandOrange
                                : const Color(0xFFF6C8A8),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: _isFormValid
                                ? [
                                    BoxShadow(
                                      color: brandOrange.withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Next',
                              style: GoogleFonts.fredoka(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // 3. Floating Rounded Navigation Bar (Matching App Standard)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EEE6),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFE8DFD5),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: darkBrown.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildNavBarItem(
                          label: 'Home',
                          icon: Icons.home_outlined,
                          isSelected: false,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          brandOrange: brandOrange,
                          textMuted: textMuted,
                        ),
                      ),
                      Expanded(
                        child: _buildNavBarItem(
                          label: 'Journey',
                          icon: Icons.place_rounded,
                          isSelected: true,
                          onTap: () {},
                          brandOrange: brandOrange,
                          textMuted: textMuted,
                        ),
                      ),
                      Expanded(
                        child: _buildNavBarItem(
                          label: 'Discover',
                          icon: Icons.explore_outlined,
                          isSelected: false,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          brandOrange: brandOrange,
                          textMuted: textMuted,
                        ),
                      ),
                      Expanded(
                        child: _buildNavBarItem(
                          label: 'Me',
                          icon: Icons.person_outline_rounded,
                          isSelected: false,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          brandOrange: brandOrange,
                          textMuted: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripTypeCard({
    required TripType type,
    required String title,
    required String subtitle,
    required String imageAsset,
    required bool isSelected,
    required Color brandOrange,
    required Color darkBrown,
    required Color textMuted,
    required Color lightBorder,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTripType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 104,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF8F2) : const Color(0xFFFBF5EE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFF39860) : lightBorder,
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: darkBrown.withValues(alpha: isSelected ? 0.04 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mascot 3D icon
            SizedBox(
              width: 44,
              height: 44,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, st) {
                  return Icon(
                    type == TripType.solo
                        ? Icons.person_rounded
                        : Icons.group_rounded,
                    color: brandOrange,
                    size: 32,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // Text column
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: darkBrown,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                      color: textMuted,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color brandOrange,
    required Color textMuted,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAF7F2) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: const Color(0xFFECE4D9), width: 0.8)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2E1C14).withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? brandOrange : textMuted,
              size: 21,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? brandOrange : textMuted,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
