import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelyn/presentation/journey/widgets/accommodation_booking_sheet.dart';
import 'package:travelyn/presentation/journey/widgets/hotel_card.dart';
import 'package:travelyn/services/booking_models.dart';
import 'package:travelyn/services/booking_service.dart';

void main() {
  testWidgets('HotelCard Select This Stay button opens AccommodationBookingSheet',
      (WidgetTester tester) async {
    final hotels = BookingService.getHotels(
      destination: 'Kyoto, Japan',
      startDate: DateTime(2026, 9, 10),
      endDate: DateTime(2026, 9, 13),
      tripType: 'Group',
    );

    expect(hotels.isNotEmpty, isTrue);
    final hotel = hotels.first;

    bool selected = false;
    String? chosenPlatform;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HotelCard(
              hotel: hotel,
              totalNights: 3,
              activeSort: HotelSortOption.recommended,
              isSelected: selected,
              onSelect: () {
                selected = !selected;
              },
              onSelectWithPlatform: (platform) {
                chosenPlatform = platform;
                selected = true;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify hotel card renders
    expect(find.text(hotel.name), findsOneWidget);
    expect(find.text('Select This Stay'), findsOneWidget);

    // Tap "Select This Stay"
    await tester.tap(find.text('Select This Stay'));
    await tester.pumpAndSettle();

    // Bottom sheet should now be visible
    expect(find.text('Compare Booking Platforms'), findsOneWidget);
    expect(find.text('Klook'), findsOneWidget);
    expect(find.text('Trip.com'), findsOneWidget);
    expect(find.text('Agoda'), findsOneWidget);
    expect(find.text('Booking.com'), findsOneWidget);
    expect(find.text('Book on Klook'), findsOneWidget);
    expect(find.text('Book on Trip.com'), findsOneWidget);

    // Tap "Book on Klook"
    await tester.tap(find.text('Book on Klook'));
    await tester.pumpAndSettle();

    // Callback should have received platform
    expect(chosenPlatform, 'Klook');
    expect(selected, isTrue);
  });
}
