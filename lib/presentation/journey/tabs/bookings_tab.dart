import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/booking_models.dart';
import '../../../services/booking_service.dart';
import '../widgets/booking_checklist_view.dart';
import '../widgets/booking_filter_sheet.dart';
import '../widgets/booking_sort_chips.dart';
import '../widgets/flight_card.dart';
import '../widgets/hotel_card.dart';
import '../widgets/split_stay_banner.dart';
import '../widgets/train_card.dart';

/// Tab 2: Bookings Tab (Checklist as default, with Stays, Flights, & Bullet Trains drill-down).
class BookingsTab extends StatefulWidget {
  final String destination;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const BookingsTab({
    super.key,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Solo Trip',
    this.startDate,
    this.endDate,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
  });

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  // Default page is the AI-generated Checklist!
  bool _showChecklistView = true;

  BookingType _activeType = BookingType.stays;
  HotelSortOption _hotelSort = HotelSortOption.recommended;
  FlightSortOption _flightSort = FlightSortOption.recommended;
  TrainSortOption _trainSort = TrainSortOption.recommended;

  HotelFilterState _hotelFilter = const HotelFilterState();
  FlightFilterState _flightFilter = const FlightFilterState();

  String? _selectedHotelId;
  String? _selectedFlightId;
  String? _selectedTrainId;

  List<BookingChecklistItem> _checklist = [];
  List<HotelOption> _allHotels = [];
  List<FlightOption> _allFlights = [];
  List<TrainOption> _allTrains = [];

  @override
  void initState() {
    super.initState();
    _loadBookingData();
  }

  @override
  void didUpdateWidget(covariant BookingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destination != widget.destination ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate ||
        oldWidget.tripType != widget.tripType) {
      _loadBookingData();
    }
  }

  void _loadBookingData() {
    _checklist = BookingService.generateAiChecklist(
      destination: widget.destination,
      startDate: widget.startDate,
      endDate: widget.endDate,
      tripType: widget.tripType,
    );

    _allHotels = BookingService.getHotels(
      destination: widget.destination,
      startDate: widget.startDate,
      endDate: widget.endDate,
      tripType: widget.tripType,
    );

    _allFlights = BookingService.getFlights(
      destination: widget.destination,
      startDate: widget.startDate,
      endDate: widget.endDate,
      tripType: widget.tripType,
    );

    _allTrains = BookingService.getTrains(
      destination: widget.destination,
      startDate: widget.startDate,
      endDate: widget.endDate,
      tripType: widget.tripType,
    );
  }

  void _navigateToChecklistItem(BookingType type) {
    setState(() {
      _activeType = type;
      _showChecklistView = false;
    });
  }

  void _openFilterSheet() {
    BookingFilterSheet.show(
      context: context,
      bookingType: _activeType,
      initialHotelFilter: _hotelFilter,
      initialFlightFilter: _flightFilter,
      onApplyHotelFilter: (newFilter) {
        setState(() => _hotelFilter = newFilter);
      },
      onApplyFlightFilter: (newFilter) {
        setState(() => _flightFilter = newFilter);
      },
      brandOrange: widget.brandOrange,
      darkBrown: widget.darkBrown,
      textMuted: widget.textMuted,
    );
  }

  void _toggleHotelSelection(HotelOption hotel, {String? platformName}) {
    setState(() {
      if (_selectedHotelId == hotel.id && platformName == null) {
        _selectedHotelId = null;
        _updateChecklistStatus(BookingType.stays, BookingItemStatus.needed, null);
        _showSelectionToast('${hotel.name} removed from your stays');
      } else {
        _selectedHotelId = hotel.id;
        final bookedLabel = platformName != null
            ? '${hotel.name} ($platformName)'
            : hotel.name;
        _updateChecklistStatus(BookingType.stays, BookingItemStatus.booked, bookedLabel);
        if (platformName == null) {
          _showSelectionToast('${hotel.name} selected as your stay! 🏨');
        }
      }
    });
  }

  void _toggleFlightSelection(FlightOption flight) {
    setState(() {
      if (_selectedFlightId == flight.id) {
        _selectedFlightId = null;
        _updateChecklistStatus(BookingType.flights, BookingItemStatus.needed, null);
      } else {
        _selectedFlightId = flight.id;
        _updateChecklistStatus(BookingType.flights, BookingItemStatus.booked, '${flight.airline} (${flight.flightNumber})');
        _showSelectionToast('${flight.airline} (${flight.flightNumber}) selected! ✈️');
      }
    });
  }

  void _toggleTrainSelection(TrainOption train) {
    setState(() {
      if (_selectedTrainId == train.id) {
        _selectedTrainId = null;
        _updateChecklistStatus(BookingType.trains, BookingItemStatus.needed, null);
      } else {
        _selectedTrainId = train.id;
        _updateChecklistStatus(BookingType.trains, BookingItemStatus.booked, train.trainName);
        _showSelectionToast('${train.trainName} selected! 🚄');
      }
    });
  }

  void _toggleChecklistItem(String id) {
    setState(() {
      final idx = _checklist.indexWhere((item) => item.id == id);
      if (idx != -1) {
        final current = _checklist[idx];
        final newStatus = current.status == BookingItemStatus.booked
            ? BookingItemStatus.needed
            : BookingItemStatus.booked;
        _checklist[idx] = current.copyWith(status: newStatus);

        if (current.type == BookingType.stays && newStatus == BookingItemStatus.needed) {
          _selectedHotelId = null;
        } else if (current.type == BookingType.flights && newStatus == BookingItemStatus.needed) {
          _selectedFlightId = null;
        } else if (current.type == BookingType.trains && newStatus == BookingItemStatus.needed) {
          _selectedTrainId = null;
        }
      }
    });
  }

  void _updateChecklistStatus(BookingType type, BookingItemStatus status, String? name) {
    final idx = _checklist.indexWhere((item) => item.type == type);
    if (idx != -1) {
      _checklist[idx] = _checklist[idx].copyWith(
        status: status,
        bookedOptionName: name,
      );
    }
  }

  void _showSelectionToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.fredoka(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int get _bookedCount {
    return _checklist.where((i) => i.status == BookingItemStatus.booked).length;
  }

  @override
  Widget build(BuildContext context) {
    if (_checklist.isEmpty || _allHotels.isEmpty || _allFlights.isEmpty) {
      _loadBookingData();
    }

    final dateRangeStr = BookingService.formatDateRange(widget.startDate, widget.endDate);
    final travellers = BookingService.getTravellerCount(widget.tripType);
    final nights = BookingService.calculateNights(widget.startDate, widget.endDate);

    // 1. DEFAULT VIEW: AI-Generated Booking Checklist
    if (_showChecklistView) {
      return BookingChecklistView(
        checklistItems: _checklist,
        destination: widget.destination,
        dateRangeStr: dateRangeStr,
        travellerCount: travellers,
        tripType: widget.tripType ?? 'Solo Trip',
        onItemTapped: _navigateToChecklistItem,
        onToggleItem: _toggleChecklistItem,
        brandOrange: widget.brandOrange,
        darkBrown: widget.darkBrown,
        textMuted: widget.textMuted,
      );
    }

    // 2. DRILL-DOWN RECOMMENDATION VIEW (Stays, Flights, Trains)
    final displayHotels = BookingService.filterAndSortHotels(
      hotels: _allHotels,
      sortOption: _hotelSort,
      filter: _hotelFilter,
    );

    final displayFlights = BookingService.filterAndSortFlights(
      flights: _allFlights,
      sortOption: _flightSort,
      filter: _flightFilter,
    );

    final displayTrains = BookingService.filterAndSortTrains(
      trains: _allTrains,
      sortOption: _trainSort,
    );

    final activeFilterCount = _activeType == BookingType.stays
        ? _hotelFilter.activeFilterCount
        : _activeType == BookingType.flights
            ? _flightFilter.activeFilterCount
            : 0;

    final splitStaySuggestion = BookingService.getSplitStaySuggestion(
      destination: widget.destination,
      startDate: widget.startDate,
      endDate: widget.endDate,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb Navigation: Back to Checklist
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showChecklistView = true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEDE3D7)),
                    boxShadow: [
                      BoxShadow(
                        color: widget.darkBrown.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 13,
                        color: widget.brandOrange,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Bookings',
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: widget.brandOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Checklist progress badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _bookedCount > 0 ? const Color(0xFFE8F5E9) : const Color(0xFFFFF1E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _bookedCount > 0 ? const Color(0xFFA5D6A7) : const Color(0xFFFFCCBC),
                  ),
                ),
                child: Text(
                  '$_bookedCount/${_checklist.length} booked',
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _bookedCount > 0 ? const Color(0xFF2E7D32) : widget.brandOrange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Category Title Header
          Row(
            children: [
              Text(
                _activeType == BookingType.stays
                    ? 'Recommended Stays'
                    : _activeType == BookingType.flights
                        ? 'Recommended Flights'
                        : 'Bullet Trains & Transit',
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: widget.darkBrown,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Split-Stay Banner (if in Stays and 7+ nights)
          if (_activeType == BookingType.stays && splitStaySuggestion != null) ...[
            SplitStayBanner(
              suggestion: splitStaySuggestion,
              brandOrange: widget.brandOrange,
              darkBrown: widget.darkBrown,
              textMuted: widget.textMuted,
            ),
          ],

          // Sort & Filter Bar
          BookingSortChips(
            bookingType: _activeType,
            activeHotelSort: _hotelSort,
            activeFlightSort: _flightSort,
            activeTrainSort: _trainSort,
            onHotelSortChanged: (sort) => setState(() => _hotelSort = sort),
            onFlightSortChanged: (sort) => setState(() => _flightSort = sort),
            onTrainSortChanged: (sort) => setState(() => _trainSort = sort),
            onFilterTap: _openFilterSheet,
            activeFilterCount: activeFilterCount,
            brandOrange: widget.brandOrange,
            darkBrown: widget.darkBrown,
            textMuted: widget.textMuted,
          ),

          const SizedBox(height: 16),

          // Cards List based on active segment
          if (_activeType == BookingType.stays) ...[
            if (displayHotels.isEmpty)
              _buildEmptyState(
                title: 'No stays match your filters',
                onReset: () => setState(() => _hotelFilter = const HotelFilterState()),
              )
            else
              ...displayHotels.map(
                (hotel) => HotelCard(
                  key: ValueKey(hotel.id),
                  hotel: hotel,
                  totalNights: nights,
                  activeSort: _hotelSort,
                  isSelected: _selectedHotelId == hotel.id,
                  onSelect: () => _toggleHotelSelection(hotel),
                  onSelectWithPlatform: (platformName) =>
                      _toggleHotelSelection(hotel, platformName: platformName),
                  brandOrange: widget.brandOrange,
                  darkBrown: widget.darkBrown,
                  textMuted: widget.textMuted,
                ),
              ),
          ] else if (_activeType == BookingType.flights) ...[
            if (displayFlights.isEmpty)
              _buildEmptyState(
                title: 'No flights match your filters',
                onReset: () => setState(() => _flightFilter = const FlightFilterState()),
              )
            else
              ...displayFlights.map(
                (flight) => FlightCard(
                  key: ValueKey(flight.id),
                  flight: flight,
                  travellerCount: travellers,
                  activeSort: _flightSort,
                  isSelected: _selectedFlightId == flight.id,
                  onSelect: () => _toggleFlightSelection(flight),
                  brandOrange: widget.brandOrange,
                  darkBrown: widget.darkBrown,
                  textMuted: widget.textMuted,
                ),
              ),
          ] else ...[
            if (displayTrains.isEmpty)
              _buildEmptyState(
                title: 'No transit options found',
                onReset: () {},
              )
            else
              ...displayTrains.map(
                (train) => TrainCard(
                  key: ValueKey(train.id),
                  train: train,
                  travellerCount: travellers,
                  activeSort: _trainSort,
                  isSelected: _selectedTrainId == train.id,
                  onSelect: () => _toggleTrainSelection(train),
                  brandOrange: widget.brandOrange,
                  darkBrown: widget.darkBrown,
                  textMuted: widget.textMuted,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required VoidCallback onReset,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE3D7)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: widget.darkBrown.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.darkBrown,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Try widening your budget or relaxing criteria',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              color: widget.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onReset,
            style: OutlinedButton.styleFrom(
              foregroundColor: widget.brandOrange,
              side: BorderSide(color: widget.brandOrange),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Reset Filters',
              style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
