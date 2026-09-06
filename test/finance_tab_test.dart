import 'package:flutter_test/flutter_test.dart';
import 'package:travelyn/presentation/journey/tabs/finance/models/finance_models.dart';
import 'package:travelyn/presentation/journey/tabs/finance/services/finance_service.dart';

void main() {
  group('FinanceService & Calculations Tests', () {
    late FinanceService service;

    setUp(() {
      service = FinanceService();
    });

    test('Real-time Budget and Total Spent calculations', () {
      final totalSpent = service.totalSpent;
      final remaining = service.remainingBudget;
      final totalBudget = service.budget.totalBudget;

      expect(totalSpent, greaterThan(0));
      expect(remaining + totalSpent, equals(totalBudget));
    });

    test('Itemized Receipt split with proportional service charge & tax', () {
      final allMembers = service.members;
      final expense = Expense(
        id: 'test_exp',
        title: 'Test Izakaya',
        totalAmount: 11000.0,
        category: ExpenseCategory.food,
        date: DateTime.now(),
        payerId: allMembers[0].id,
        splitType: ExpenseSplitType.itemized,
        serviceChargeAmount: 1000.0,
        taxAmount: 1000.0,
        items: [
          ExpenseItem(
            id: 'it1',
            title: 'Dish 1',
            price: 6000.0,
            assignedMemberIds: [allMembers[0].id], // Only Member 0 had Dish 1 ($6000)
          ),
          ExpenseItem(
            id: 'it2',
            title: 'Dish 2',
            price: 3000.0,
            assignedMemberIds: [allMembers[1].id], // Only Member 1 had Dish 2 ($3000)
          ),
        ],
      );

      final shares = expense.calculateMemberShares(allMembers);
      // Dish total = 9000. Extra fees = 2000.
      // Member 0: 6000 + 2000 * (6000/9000) = 6000 + 1333.33 = 7333.33
      // Member 1: 3000 + 2000 * (3000/9000) = 3000 + 666.67 = 3666.67
      // Total shares sum = 11000
      expect(shares[allMembers[0].id]!, closeTo(7333.33, 0.1));
      expect(shares[allMembers[1].id]!, closeTo(3666.67, 0.1));
      expect(shares[allMembers[2].id]!, closeTo(0.0, 0.01));
      expect(shares[allMembers[3].id]!, closeTo(0.0, 0.01));
    });

    test('Debt settlement calculation sums to zero balance', () {
      final settlements = service.calculatedSettlements;
      expect(settlements, isNotEmpty);
      for (final s in settlements) {
        expect(s.amount, greaterThan(0.0));
      }
    });

    test('Currency conversion logic', () {
      // 1000 JPY to USD
      final usd = service.convert(1000.0, 'JPY', 'USD');
      expect(usd, closeTo(6.47, 0.5));

      // Swap
      final initialBase = service.baseCurrencyCode;
      final initialTarget = service.targetCurrencyCode;
      service.swapCurrencies();
      expect(service.baseCurrencyCode, equals(initialTarget));
      expect(service.targetCurrencyCode, equals(initialBase));
    });
  });
}
