import 'package:flutter/material.dart';
import '../models/finance_models.dart';

/// Centralized state and calculations for the Finance Tab.
class FinanceService extends ChangeNotifier {
  static final FinanceService _instance = FinanceService._internal();
  factory FinanceService() => _instance;

  FinanceService._internal() {
    _initializeDefaultData();
  }

  late List<TripMember> _members;
  late TripBudget _budget;
  late List<Expense> _expenses;
  late List<DebtSettlement> _settledDebts;

  // Currencies supported
  final List<CurrencyRate> supportedCurrencies = const [
    CurrencyRate(code: 'JPY', name: 'Japanese Yen', symbol: '¥', flag: '🇯🇵', rateToUSD: 154.50),
    CurrencyRate(code: 'USD', name: 'US Dollar', symbol: '\$', flag: '🇺🇸', rateToUSD: 1.0),
    CurrencyRate(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', flag: '🇲🇾', rateToUSD: 4.45),
    CurrencyRate(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$', flag: '🇸🇬', rateToUSD: 1.34),
    CurrencyRate(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺', rateToUSD: 0.92),
    CurrencyRate(code: 'GBP', name: 'British Pound', symbol: '£', flag: '🇬🇧', rateToUSD: 0.79),
    CurrencyRate(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$', flag: '🇦🇺', rateToUSD: 1.54),
    CurrencyRate(code: 'KRW', name: 'South Korean Won', symbol: '₩', flag: '🇰🇷', rateToUSD: 1380.0),
    CurrencyRate(code: 'THB', name: 'Thai Baht', symbol: '฿', flag: '🇹🇭', rateToUSD: 34.50),
    CurrencyRate(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', flag: '🇨🇳', rateToUSD: 7.25),
    CurrencyRate(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$', flag: '🇨🇦', rateToUSD: 1.38),
  ];

  String _baseCurrencyCode = 'JPY';
  String _targetCurrencyCode = 'MYR';

  List<TripMember> get members => _members;
  TripBudget get budget => _budget;
  List<Expense> get expenses => _expenses;
  String get baseCurrencyCode => _baseCurrencyCode;
  String get targetCurrencyCode => _targetCurrencyCode;

  CurrencyRate get baseCurrency =>
      supportedCurrencies.firstWhere((c) => c.code == _baseCurrencyCode);
  CurrencyRate get targetCurrency =>
      supportedCurrencies.firstWhere((c) => c.code == _targetCurrencyCode);

  TripMember get currentUser =>
      _members.firstWhere((m) => m.isCurrentUser, orElse: () => _members.first);

  TripMember? getMemberById(String id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  void _initializeDefaultData() {
    _members = [
      const TripMember(
        id: 'member_1',
        name: 'Alex',
        avatarPath: 'assets/journey/member_avatar_1.jpg',
      ),
      const TripMember(
        id: 'member_2',
        name: 'Brenda',
        avatarPath: 'assets/journey/member_avatar_2.jpg',
      ),
      const TripMember(
        id: 'member_3',
        name: 'Charlie',
        avatarPath: 'assets/journey/member_avatar_3.jpg',
      ),
      const TripMember(
        id: 'member_4',
        name: 'You (Diana)',
        avatarPath: 'assets/journey/member_avatar_4.jpg',
        isCurrentUser: true,
      ),
    ];

    _budget = const TripBudget(
      totalBudget: 350000.0,
      currency: '¥',
      categoryAllocations: {
        ExpenseCategory.food: 120000.0,
        ExpenseCategory.transport: 45000.0,
        ExpenseCategory.activities: 60000.0,
        ExpenseCategory.shopping: 75000.0,
        ExpenseCategory.lodging: 30000.0,
        ExpenseCategory.entertainment: 20000.0,
      },
    );

    _settledDebts = [];

    // Pre-populate realistic Tokyo expenses
    _expenses = [
      Expense(
        id: 'exp_1',
        title: 'Shinjuku Omoide Yokocho Izakaya',
        totalAmount: 18480.0,
        category: ExpenseCategory.food,
        date: DateTime.now().subtract(const Duration(hours: 18)),
        payerId: 'member_4', // You paid
        splitType: ExpenseSplitType.itemized,
        receiptMerchant: 'Torikizoku Shinjuku',
        serviceChargeAmount: 1680.0, // 10% Service charge
        taxAmount: 1527.0, // 10% VAT
        items: const [
          ExpenseItem(
            id: 'item_1',
            title: 'Wagyu Skewers Combo (6 pcs)',
            price: 4800.0,
            quantity: 1,
            assignedMemberIds: ['member_1', 'member_4'],
          ),
          ExpenseItem(
            id: 'item_2',
            title: 'Yakitori Assortment Platter',
            price: 3600.0,
            quantity: 1,
            assignedMemberIds: ['member_1', 'member_2', 'member_3'],
          ),
          ExpenseItem(
            id: 'item_3',
            title: 'Premium Draft Beer (4 glasses)',
            price: 2400.0,
            quantity: 1,
            assignedMemberIds: ['member_1', 'member_2', 'member_3', 'member_4'],
          ),
          ExpenseItem(
            id: 'item_4',
            title: 'Grilled Salmon Belly & Rice',
            price: 2800.0,
            quantity: 1,
            assignedMemberIds: ['member_2', 'member_3'],
          ),
          ExpenseItem(
            id: 'item_5',
            title: 'Matcha Gelato & Mochi',
            price: 1673.0,
            quantity: 1,
            assignedMemberIds: ['member_4', 'member_2'],
          ),
        ],
      ),
      Expense(
        id: 'exp_2',
        title: 'Tokyo Subway 72-Hour Passes',
        totalAmount: 6000.0,
        category: ExpenseCategory.transport,
        date: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        payerId: 'member_1', // Alex paid
        splitType: ExpenseSplitType.equal,
        splitMemberIds: ['member_1', 'member_2', 'member_3', 'member_4'],
      ),
      Expense(
        id: 'exp_3',
        title: 'teamLab Borderless Tickets',
        totalAmount: 16800.0,
        category: ExpenseCategory.activities,
        date: DateTime.now().subtract(const Duration(days: 2)),
        payerId: 'member_2', // Brenda paid
        splitType: ExpenseSplitType.equal,
        splitMemberIds: ['member_1', 'member_2', 'member_3', 'member_4'],
      ),
      Expense(
        id: 'exp_4',
        title: 'Tsukiji Market Seafood Breakfast',
        totalAmount: 14200.0,
        category: ExpenseCategory.food,
        date: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
        payerId: 'member_3', // Charlie paid
        splitType: ExpenseSplitType.itemized,
        receiptMerchant: 'Tsukiji Fish Bar',
        serviceChargeAmount: 1200.0,
        taxAmount: 1100.0,
        items: const [
          ExpenseItem(
            id: 'tsu_1',
            title: 'King Salmon & Uni Bowl',
            price: 5200.0,
            quantity: 1,
            assignedMemberIds: ['member_3', 'member_4'],
          ),
          ExpenseItem(
            id: 'tsu_2',
            title: 'Tuna Trio Sashimi Set',
            price: 4500.0,
            quantity: 1,
            assignedMemberIds: ['member_1', 'member_2'],
          ),
          ExpenseItem(
            id: 'tsu_3',
            title: 'Tamagoyaki Sweet Omelet',
            price: 2200.0,
            quantity: 1,
            assignedMemberIds: ['member_1', 'member_2', 'member_3', 'member_4'],
          ),
        ],
      ),
    ];
  }

  // --- Real-time Calculations ---

  double get totalSpent {
    return _expenses.fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  double get remainingBudget {
    return _budget.totalBudget - totalSpent;
  }

  double get budgetProgressPercent {
    if (_budget.totalBudget <= 0) return 0.0;
    return (totalSpent / _budget.totalBudget).clamp(0.0, 1.0);
  }

  Map<ExpenseCategory, double> get categorySpending {
    final Map<ExpenseCategory, double> map = {};
    for (final exp in _expenses) {
      map[exp.category] = (map[exp.category] ?? 0.0) + exp.totalAmount;
    }
    return map;
  }

  /// Calculates net balance for every member:
  /// (Total amount paid for group) - (Total share of expenses consumed)
  /// Positive (+) = Member is owed money
  /// Negative (-) = Member owes money
  Map<String, double> get memberNetBalances {
    final Map<String, double> balances = {};
    for (final member in _members) {
      balances[member.id] = 0.0;
    }

    for (final exp in _expenses) {
      // 1. Credit the payer with the full amount paid
      balances[exp.payerId] = (balances[exp.payerId] ?? 0.0) + exp.totalAmount;

      // 2. Debit each member for their computed share
      final shares = exp.calculateMemberShares(_members);
      shares.forEach((memberId, share) {
        balances[memberId] = (balances[memberId] ?? 0.0) - share;
      });
    }

    return balances;
  }

  /// Computes the minimal pairwise debt settlements using greedy reduction.
  List<DebtSettlement> get calculatedSettlements {
    final balances = Map<String, double>.from(memberNetBalances);

    // Filter out settled adjustments if any
    for (final settled in _settledDebts) {
      if (settled.isSettled) {
        balances[settled.fromMemberId] =
            (balances[settled.fromMemberId] ?? 0.0) + settled.amount;
        balances[settled.toMemberId] =
            (balances[settled.toMemberId] ?? 0.0) - settled.amount;
      }
    }

    final List<DebtSettlement> settlements = [];

    // Separate debtors (< -0.01) and creditors (> 0.01)
    final List<MapEntry<String, double>> debtors = [];
    final List<MapEntry<String, double>> creditors = [];

    balances.forEach((memberId, balance) {
      if (balance < -0.01) {
        debtors.add(MapEntry(memberId, -balance)); // positive debt amount
      } else if (balance > 0.01) {
        creditors.add(MapEntry(memberId, balance));
      }
    });

    int dIndex = 0;
    int cIndex = 0;

    while (dIndex < debtors.length && cIndex < creditors.length) {
      final debtor = debtors[dIndex];
      final creditor = creditors[cIndex];

      final settleAmount = debtor.value < creditor.value ? debtor.value : creditor.value;

      if (settleAmount > 0.01) {
        settlements.add(
          DebtSettlement(
            fromMemberId: debtor.key,
            toMemberId: creditor.key,
            amount: double.parse(settleAmount.toStringAsFixed(2)),
          ),
        );
      }

      debtors[dIndex] = MapEntry(debtor.key, debtor.value - settleAmount);
      creditors[cIndex] = MapEntry(creditor.key, creditor.value - settleAmount);

      if (debtors[dIndex].value < 0.01) dIndex++;
      if (creditors[cIndex].value < 0.01) cIndex++;
    }

    return settlements;
  }

  // --- Actions ---

  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
    notifyListeners();
  }

  void updateExpense(Expense expense) {
    final idx = _expenses.indexWhere((e) => e.id == expense.id);
    if (idx != -1) {
      _expenses[idx] = expense;
      notifyListeners();
    }
  }

  void deleteExpense(String expenseId) {
    _expenses.removeWhere((e) => e.id == expenseId);
    notifyListeners();
  }

  void updateBudget(TripBudget newBudget) {
    _budget = newBudget;
    notifyListeners();
  }

  void markDebtSettled(DebtSettlement settlement) {
    _settledDebts.add(settlement.copyWith(isSettled: true));
    notifyListeners();
  }

  void resetSettlements() {
    _settledDebts.clear();
    notifyListeners();
  }

  void setCurrencies({String? base, String? target}) {
    if (base != null) _baseCurrencyCode = base;
    if (target != null) _targetCurrencyCode = target;
    notifyListeners();
  }

  void swapCurrencies() {
    final temp = _baseCurrencyCode;
    _baseCurrencyCode = _targetCurrencyCode;
    _targetCurrencyCode = temp;
    notifyListeners();
  }

  double convert(double amount, String fromCode, String toCode) {
    final fromRate = supportedCurrencies.firstWhere((c) => c.code == fromCode).rateToUSD;
    final toRate = supportedCurrencies.firstWhere((c) => c.code == toCode).rateToUSD;

    // Convert from -> USD -> to
    final inUSD = amount / fromRate;
    return inUSD * toRate;
  }

  // Preset Realistic Sample Receipts for quick testing & demonstration
  List<Map<String, dynamic>> getSampleReceiptPresets() {
    return [
      {
        'merchant': 'Ichiran Ramen Shibuya',
        'category': ExpenseCategory.food,
        'taxAmount': 420.0,
        'serviceChargeAmount': 0.0,
        'items': [
          {'title': 'Tonkotsu Ramen (Rich Broth)', 'price': 1180.0, 'quantity': 2},
          {'title': 'Extra Chashu Pork (4 slices)', 'price': 400.0, 'quantity': 2},
          {'title': 'Soft-Boiled Seasoned Egg', 'price': 250.0, 'quantity': 3},
          {'title': 'Matcha Draft Beer', 'price': 650.0, 'quantity': 2},
        ],
      },
      {
        'merchant': 'Gyukatsu Motomura Akihabara',
        'category': ExpenseCategory.food,
        'taxAmount': 890.0,
        'serviceChargeAmount': 890.0,
        'items': [
          {'title': 'Premium Beef Cutlet Set 260g', 'price': 3200.0, 'quantity': 2},
          {'title': 'Classic Gyukatsu Set 130g', 'price': 1930.0, 'quantity': 2},
          {'title': 'Tororo Yam & Rice Refill', 'price': 200.0, 'quantity': 2},
          {'title': 'Yuzu Highball', 'price': 550.0, 'quantity': 3},
        ],
      },
      {
        'merchant': 'FamilyMart Tokyo Metro',
        'category': ExpenseCategory.food,
        'taxAmount': 230.0,
        'serviceChargeAmount': 0.0,
        'items': [
          {'title': 'FamiChiki Fried Chicken', 'price': 240.0, 'quantity': 4},
          {'title': 'Egg Salad Sandwich', 'price': 268.0, 'quantity': 2},
          {'title': 'Boss Coffee Can (Black)', 'price': 140.0, 'quantity': 3},
          {'title': 'Pocky Matcha Sticks', 'price': 198.0, 'quantity': 2},
        ],
      },
    ];
  }
}
