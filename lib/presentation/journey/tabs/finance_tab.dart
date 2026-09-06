import 'package:flutter/material.dart';
import 'finance/models/finance_models.dart';
import 'finance/services/finance_service.dart';
import 'finance/widgets/budget_overview_card.dart';
import 'finance/widgets/debt_settlement_view.dart';
import 'finance/widgets/expense_list_card.dart';
import 'finance/widgets/quick_expense_sheet.dart';
import 'finance/widgets/receipt_scanner_sheet.dart';

/// Tab 4: Finance Tab (Overview with Budget & Who Owes, and Category Expenses View)
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
  bool _isViewingExpenses = false;
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
            // Scrollable Body
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              child: _isViewingExpenses
                  ? _buildCategoryExpensesView()
                  : _buildOverviewView(),
            ),

            // Floating Bottom Action Bar (Quick Add & Scan Receipt)
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

  /// 1. Main Overview View: Budget Overview Card + Who Owes Who
  Widget _buildOverviewView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Real-Time Budget & Category Spending Overview
        BudgetOverviewCard(
          service: _financeService,
          startDate: widget.startDate,
          endDate: widget.endDate,
          onCategoryTap: (cat) {
            setState(() {
              _filterCategory = cat;
              _isViewingExpenses = true; // Navigate directly to this category's expenses
            });
          },
          brandOrange: widget.brandOrange,
          darkBrown: widget.darkBrown,
          textMuted: widget.textMuted,
        ),

        const SizedBox(height: 18),

        // Who Owes Who (Member Net Balances & Suggested Settlement Plan)
        DebtSettlementView(
          service: _financeService,
          brandOrange: widget.brandOrange,
          darkBrown: widget.darkBrown,
          textMuted: widget.textMuted,
        ),
      ],
    );
  }

  /// 2. Dedicated Expenses View for Selected Category (with Back Button & Filters)
  Widget _buildCategoryExpensesView() {
    final expenses = _filterCategory == null
        ? _financeService.expenses
        : _financeService.expenses.where((e) => e.category == _filterCategory).toList();

    final catTotal = expenses.fold(0.0, (sum, e) => sum + e.totalAmount);
    final sym = _financeService.budget.currency;
    final convertedTotal = _financeService.convert(
      catTotal,
      _financeService.baseCurrencyCode,
      _financeService.targetCurrencyCode,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Navigation Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isViewingExpenses = false;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3ECE3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5DACD), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_rounded, size: 13, color: widget.darkBrown),
                    const SizedBox(width: 4),
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: widget.darkBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_filterCategory != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _filterCategory!.bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_filterCategory!.icon, size: 14, color: _filterCategory!.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      _filterCategory!.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _filterCategory!.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        // Category Spend Summary Header Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDE3D7), width: 1.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _filterCategory != null ? '${_filterCategory!.label} Expenses' : 'All Expenses',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: widget.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${expenses.length} transaction${expenses.length == 1 ? "" : "s"} recorded',
                    style: TextStyle(fontSize: 11, color: widget.textMuted),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sym${catTotal.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: widget.brandOrange,
                    ),
                  ),
                  Text(
                    '≈ ${_financeService.targetCurrency.symbol}${convertedTotal.toStringAsFixed(2)} ${_financeService.targetCurrencyCode}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

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
                    'No expenses for this category',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.darkBrown),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Scan Receipt" or "Quick Add" below to record.',
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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _openReceiptScanner,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _openQuickExpense,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
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



