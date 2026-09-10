import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/booking_models.dart';

/// Modal bottom sheet allowing users to filter hotels or flights with RM currency.
class BookingFilterSheet extends StatefulWidget {
  final BookingType bookingType;
  final HotelFilterState initialHotelFilter;
  final FlightFilterState initialFlightFilter;
  final ValueChanged<HotelFilterState> onApplyHotelFilter;
  final ValueChanged<FlightFilterState> onApplyFlightFilter;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const BookingFilterSheet({
    super.key,
    required this.bookingType,
    required this.initialHotelFilter,
    required this.initialFlightFilter,
    required this.onApplyHotelFilter,
    required this.onApplyFlightFilter,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
  });

  static Future<void> show({
    required BuildContext context,
    required BookingType bookingType,
    required HotelFilterState initialHotelFilter,
    required FlightFilterState initialFlightFilter,
    required ValueChanged<HotelFilterState> onApplyHotelFilter,
    required ValueChanged<FlightFilterState> onApplyFlightFilter,
    Color brandOrange = const Color(0xFFE65100),
    Color darkBrown = const Color(0xFF2E1C14),
    Color textMuted = const Color(0xFF6B5A50),
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookingFilterSheet(
        bookingType: bookingType,
        initialHotelFilter: initialHotelFilter,
        initialFlightFilter: initialFlightFilter,
        onApplyHotelFilter: onApplyHotelFilter,
        onApplyFlightFilter: onApplyFlightFilter,
        brandOrange: brandOrange,
        darkBrown: darkBrown,
        textMuted: textMuted,
      ),
    );
  }

  @override
  State<BookingFilterSheet> createState() => _BookingFilterSheetState();
}

class _BookingFilterSheetState extends State<BookingFilterSheet> {
  late double _hotelMaxPriceRm;
  late double _hotelMinRating;
  late Set<String> _hotelAmenities;
  late bool _hotelFreeCancel;

  late double _flightMaxPriceRm;
  late bool _flightDirectOnly;
  late Set<String> _flightAirlines;

  final List<String> _availableAmenities = const [
    'Free cancellation',
    'Breakfast included',
    'Free Wi-Fi',
    'Subway direct',
    'Harbor view',
  ];

  final List<String> _availableAirlines = const [
    'AirAsia X',
    'Batik Air',
    'Malaysia Airlines',
    'Singapore Airlines',
  ];

  @override
  void initState() {
    super.initState();
    _hotelMaxPriceRm = widget.initialHotelFilter.maxPriceRm;
    _hotelMinRating = widget.initialHotelFilter.minRating;
    _hotelAmenities = Set.from(widget.initialHotelFilter.selectedAmenities);
    _hotelFreeCancel = widget.initialHotelFilter.freeCancellationOnly;

    _flightMaxPriceRm = widget.initialFlightFilter.maxPriceRm;
    _flightDirectOnly = widget.initialFlightFilter.directOnly;
    _flightAirlines = Set.from(widget.initialFlightFilter.selectedAirlines);
  }

  void _reset() {
    HapticFeedback.lightImpact();
    setState(() {
      if (widget.bookingType == BookingType.stays) {
        _hotelMaxPriceRm = 800;
        _hotelMinRating = 0.0;
        _hotelAmenities.clear();
        _hotelFreeCancel = false;
      } else {
        _flightMaxPriceRm = 2000;
        _flightDirectOnly = false;
        _flightAirlines.clear();
      }
    });
  }

  void _apply() {
    HapticFeedback.mediumImpact();
    if (widget.bookingType == BookingType.stays) {
      widget.onApplyHotelFilter(
        HotelFilterState(
          maxPriceRm: _hotelMaxPriceRm,
          minRating: _hotelMinRating,
          selectedAmenities: _hotelAmenities,
          freeCancellationOnly: _hotelFreeCancel,
        ),
      );
    } else {
      widget.onApplyFlightFilter(
        FlightFilterState(
          maxPriceRm: _flightMaxPriceRm,
          directOnly: _flightDirectOnly,
          selectedAirlines: _flightAirlines,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isStays = widget.bookingType == BookingType.stays;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFDF7F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDBC9B8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isStays ? 'Filter Stays' : 'Filter Flights',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: widget.darkBrown,
                ),
              ),
              TextButton(
                onPressed: _reset,
                child: Text(
                  'Reset',
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.brandOrange,
                  ),
                ),
              ),
            ],
          ),

          const Divider(color: Color(0xFFEDE3D7), height: 20),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: isStays ? _buildHotelFilters() : _buildFlightFilters(),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.brandOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Max Price / Night',
              style: GoogleFonts.fredoka(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: widget.darkBrown,
              ),
            ),
            Text(
              _hotelMaxPriceRm >= 800
                  ? 'Any'
                  : 'Up to RM${_hotelMaxPriceRm.round()}',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.brandOrange,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.brandOrange,
            inactiveTrackColor: const Color(0xFFE4D5C5),
            thumbColor: widget.brandOrange,
            overlayColor: widget.brandOrange.withValues(alpha: 0.15),
          ),
          child: Slider(
            value: _hotelMaxPriceRm,
            min: 80,
            max: 800,
            divisions: 18,
            onChanged: (val) => setState(() => _hotelMaxPriceRm = val),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Minimum Guest Rating',
          style: GoogleFonts.fredoka(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: widget.darkBrown,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildRatingChip('Any', 0.0),
            const SizedBox(width: 8),
            _buildRatingChip('4.0+ ★', 4.0),
            const SizedBox(width: 8),
            _buildRatingChip('4.5+ ★', 4.5),
            const SizedBox(width: 8),
            _buildRatingChip('4.8+ ★', 4.8),
          ],
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDE3D7)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Free cancellation only',
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.darkBrown,
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: _hotelFreeCancel,
                activeColor: widget.brandOrange,
                onChanged: (val) => setState(() => _hotelFreeCancel = val),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Amenities',
          style: GoogleFonts.fredoka(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: widget.darkBrown,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableAmenities.map((amenity) {
            final isSelected = _hotelAmenities.contains(amenity);
            return FilterChip(
              label: Text(amenity),
              labelStyle: GoogleFonts.fredoka(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : widget.darkBrown,
              ),
              selected: isSelected,
              selectedColor: widget.brandOrange,
              backgroundColor: const Color(0xFFFFFBF7),
              side: BorderSide(
                color: isSelected ? widget.brandOrange : const Color(0xFFEDE3D7),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _hotelAmenities.add(amenity);
                  } else {
                    _hotelAmenities.remove(amenity);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFlightFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Max Price / Person',
              style: GoogleFonts.fredoka(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: widget.darkBrown,
              ),
            ),
            Text(
              _flightMaxPriceRm >= 2000
                  ? 'Any'
                  : 'Up to RM${_flightMaxPriceRm.round()}',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.brandOrange,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.brandOrange,
            inactiveTrackColor: const Color(0xFFE4D5C5),
            thumbColor: widget.brandOrange,
            overlayColor: widget.brandOrange.withValues(alpha: 0.15),
          ),
          child: Slider(
            value: _flightMaxPriceRm,
            min: 400,
            max: 2000,
            divisions: 16,
            onChanged: (val) => setState(() => _flightMaxPriceRm = val),
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDE3D7)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.flight_takeoff_rounded,
                    size: 18,
                    color: widget.brandOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Direct flights only',
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.darkBrown,
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: _flightDirectOnly,
                activeColor: widget.brandOrange,
                onChanged: (val) => setState(() => _flightDirectOnly = val),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Filter by Airlines',
          style: GoogleFonts.fredoka(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: widget.darkBrown,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableAirlines.map((airline) {
            final isSelected = _flightAirlines.contains(airline);
            return FilterChip(
              label: Text(airline),
              labelStyle: GoogleFonts.fredoka(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : widget.darkBrown,
              ),
              selected: isSelected,
              selectedColor: widget.brandOrange,
              backgroundColor: const Color(0xFFFFFBF7),
              side: BorderSide(
                color: isSelected ? widget.brandOrange : const Color(0xFFEDE3D7),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _flightAirlines.add(airline);
                  } else {
                    _flightAirlines.remove(airline);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingChip(String label, double rating) {
    final isSelected = (_hotelMinRating == rating);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _hotelMinRating = rating),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? widget.brandOrange : const Color(0xFFFFFBF7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? widget.brandOrange : const Color(0xFFEDE3D7),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.fredoka(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : widget.darkBrown,
            ),
          ),
        ),
      ),
    );
  }
}
