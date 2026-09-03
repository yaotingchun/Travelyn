import 'package:flutter/material.dart';
import 'finance/models/finance_models.dart';
import 'finance/services/finance_service.dart';
import 'finance/widgets/budget_overview_card.dart';
import 'finance/widgets/currency_converter_view.dart';
import 'finance/widgets/debt_settlement_view.dart';
import 'finance/widgets/expense_list_card.dart';
import 'finance/widgets/finance_subnav_bar.dart';
import 'finance/widgets/quick_expense_sheet.dart';
import 'finance/widgets/receipt_scanner_sheet.dart';

/// Tab 4: Finance Tab (Budget Tracker, Receipt OCR Splitter, Debt Settlement & Currency FX)
class FinanceTab extends StatefulWidget {
  final String destination;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const FinanceTab({
    super.key,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Group Trip',
    this.startDate,
    this.endDate,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
  });

  @override
  State<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends State<FinanceTab> {
  final FinanceService _financeService = FinanceService();
  int _activeSubTabIndex = 0;
  ExpenseCategory? _filterCategory;

  void _openQuickExpense() {
    QuickExpenseSheet.show(
      context,
      service: _financeService,
      brandOrange: widget.brandOrange,
      darkBrown: widget.darkBrown,
      textMuted: widget.textMuted,
    );
  }

  void _openReceiptScanner() {
    ReceiptScannerSheet.show(
      context,
      service: _financeService,
      brandOrange: widget.brandOrange,
      darkBrown: widget.darkBrown,
      textMuted: widget.textMuted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _financeService,
      builder: (context, _) {
        return Stack(
          children: [
            // Main Scrollable Body
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Sub Navigation (Overview | Expenses | Who Owes | Converter)
                  FinanceSubNavBar(
                    selectedIndex: _activeSubTabIndex,
                    onTabChanged: (idx) {
                      setState(() {
                        _activeSubTabIndex = idx;
                      });
                    },
                    brandOrange: widget.brandOrange,
                    darkBrown: widget.darkBrown,
                    textMuted: widget.textMuted,
                  ),

                  const SizedBox(height: 16),

                  // 2. Tab Content Views
                  if (_activeSubTabIndex == 0) ...[
                    // --- SUBTAB 0: OVERVIEW & REAL-TIME BUDGET ---
                    BudgetOverviewCard(
                      service: _financeService,
                      startDate: widget.startDate,
                      endDate: widget.endDate,
                      onCategoryTap: (cat) {
                        setState(() {
                          _filterCategory = cat;
                          _activeSubTabIndex = 1; // Switch to Expenses subtab
                        });
                      },
                      brandOrange: widget.brandOrange,
                      darkBrown: widget.darkBrown,
                      textMuted: widget.textMuted,
                    ),
                    const SizedBox(height: 18),
                    _buildRecentExpensesSection(),
                  ] else if (_activeSubTabIndex == 1) ...[
                    // --- SUBTAB 1: ALL EXPENSES & FILTER CHIPS ---
                    _buildExpensesStream(),
                  ] else if (_activeSubTabIndex == 2) ...[
                    // --- SUBTAB 2: WHO OWES WHO (DEBTS & SETTLEMENT) ---
                    DebtSettlementView(
                      service: _financeService,
                      brandOrange: widget.brandOrange,
                      darkBrown: widget.darkBrown,
                      textMuted: widget.textMuted,
                    ),
                  ] else ...[
                    // --- SUBTAB 3: CURRENCY CONVERTER ---
                    CurrencyConverterView(
                      service: _financeService,
                      brandOrange: widget.brandOrange,
                      darkBrown: widget.darkBrown,
                      textMuted: widget.textMuted,
                    ),
                  ],
                ],
              ),
            ),

            // 3. Floating Bottom Action Bar (Quick Add & Scan Receipt)
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: _buildFloatingActionButtons(),
            ),
          ],
        );
      },
    );
  }

  /// Recent Expenses Section in the Overview Tab
  Widget _buildRecentExpensesSection() {
    final recent = _financeService.expenses.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Expenses',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: widget.darkBrown,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _activeSubTabIndex = 1; // Switch to all expenses
                });
              },
              child: Row(
                children: [
                  Text(
                    'View All (${_financeService.expenses.length})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.brandOrange,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 16, color: widget.brandOrange),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recent.map((exp) {
          return ExpenseListCard(
            expense: exp,
            service: _financeService,
            brandOrange: widget.brandOrange,
            darkBrown: widget.darkBrown,
            textMuted: widget.textMuted,
          );
        }),
      ],
    );
  }

  /// Full Expenses Stream Tab with Category Filters
  Widget _buildExpensesStream() {
    final expenses = _filterCategory == null
        ? _financeService.expenses
        : _financeService.expenses.where((e) => e.category == _filterCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: FilterChip(
                  selected: _filterCategory == null,
                  label: const Text('All'),
                  onSelected: (_) {
                    setState(() {
                      _filterCategory = null;
                    });
                  },
                  backgroundColor: const Color(0xFFF3ECE3),
                  selectedColor: widget.brandOrange,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _filterCategory == null ? Colors.white : widget.darkBrown,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  showCheckmark: false,
                  side: BorderSide.none,
                ),
              ),
              ...ExpenseCategory.values.map((cat) {
                final isSelected = _filterCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    selected: isSelected,
                    avatar: Icon(cat.icon, size: 12, color: isSelected ? Colors.white : cat.primaryColor),
                    label: Text(cat.label),
                    onSelected: (_) {
                      setState(() {
                        _filterCategory = isSelected ? null : cat;
                      });
                    },
                    backgroundColor: const Color(0xFFF3ECE3),
                    selectedColor: widget.brandOrange,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : widget.darkBrown,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    showCheckmark: false,
                    side: BorderSide.none,
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Expense Cards or Empty State
        if (expenses.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEDE3D7)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 40, color: widget.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 10),
                  Text(
                    'No expenses found',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.darkBrown),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "+ Add Expense" or "Scan Receipt" below.',
                    style: TextStyle(fontSize: 12, color: widget.textMuted),
                  ),
                ],
              ),
            ),
          )
        else
          ...expenses.map((exp) {
            return ExpenseListCard(
              key: ValueKey(exp.id),
              expense: exp,
              service: _financeService,
              brandOrange: widget.brandOrange,
              darkBrown: widget.darkBrown,
              textMuted: widget.textMuted,
            );
          }),
      ],
    );
  }

  /// Floating Dual Action Bar (Scan Receipt + Quick Expense)
  Widget _buildFloatingActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1C14),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.darkBrown.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Scan Receipt Button (Highlight Action)
          Expanded(
            child: InkWell(
              onTap: _openReceiptScanner,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.brandOrange, const Color(0xFFFF7043)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.brandOrange.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.document_scanner_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Scan Receipt',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 2. Direct Quick Add Button
          Expanded(
            child: InkWell(
              onTap: _openQuickExpense,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF453026),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: Color(0xFFFFD180), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Quick Add',
                      style: TextStyle(
                        color: Color(0xFFFFFBF7),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
