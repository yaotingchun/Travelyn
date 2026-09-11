import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../services/finance_service.dart';

/// Real-time Budget vs Expense comparison card.
class BudgetOverviewCard extends StatelessWidget {
  final FinanceService service;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<ExpenseCategory?>? onCategoryTap;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const BudgetOverviewCard({
    super.key,
    required this.service,
    this.startDate,
    this.endDate,
    this.onCategoryTap,
    required this.brandOrange,
    required this.darkBrown,
    required this.textMuted,
  });

  void _showEditBudgetDialog(BuildContext context) {
    final controller = TextEditingController(
      text: service.budget.totalBudget.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: brandOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_wallet_rounded, color: brandOrange, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Set Trip Budget',
              style: TextStyle(
                color: darkBrown,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter total group spending limit for this trip:',
              style: TextStyle(color: textMuted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: darkBrown,
              ),
              decoration: InputDecoration(
                prefixText: '${service.budget.currency} ',
                prefixStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: brandOrange,
                ),
                filled: true,
                fillColor: const Color(0xFFF3ECE3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: brandOrange, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                service.updateBudget(service.budget.copyWith(totalBudget: val));
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save Budget', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amountInBase, {bool showDecimals = false}) {
    final isBase = service.targetCurrencyCode == service.baseCurrencyCode;
    final amount = isBase
        ? amountInBase
        : service.convert(amountInBase, service.baseCurrencyCode, service.targetCurrencyCode);
    final sym = service.targetCurrency.symbol;
    final isZeroDecimal = service.targetCurrencyCode == 'JPY' || service.targetCurrencyCode == 'KRW';

    if (isZeroDecimal) {
      final formatted = amount.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return '$sym$formatted';
    }

    final hasCents = showDecimals || (amount % 1 != 0);
    final formatted = (hasCents ? amount.toStringAsFixed(2) : amount.toStringAsFixed(0))
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$sym$formatted';
  }

  String _formatBaseCurrency(double amountInBase) {
    final sym = service.budget.currency;
    final formatted = amountInBase.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$sym$formatted';
  }

  int get _tripDays {
    if (startDate != null && endDate != null) {
      final days = endDate!.difference(startDate!).inDays + 1;
      return days > 0 ? days : 7;
    }
    return 7; // Default 7 days
  }

  @override
  Widget build(BuildContext context) {
    final budget = service.budget.totalBudget;
    final spent = service.totalSpent;
    final remaining = service.remainingBudget;
    final progress = service.budgetProgressPercent;
    final isOverBudget = remaining < 0;

    final dailyBudget = budget / _tripDays;
    final dailySpent = spent / _tripDays;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDE3D7), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Budget Title & Edit Button
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: brandOrange.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.analytics_rounded, color: brandOrange, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Trip Budget Tracker',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                      ),
                    ),
                  ],
                ),
                // Edit Budget Button
                InkWell(
                  onTap: () => _showEditBudgetDialog(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3ECE3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 13, color: textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Main Budget Gauge / Comparison Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Total Spent',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCurrencySelectorPill(context),
                  ],
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatCurrency(spent),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: darkBrown,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '/ ${_formatCurrency(budget)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (service.targetCurrencyCode != service.baseCurrencyCode) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${_formatBaseCurrency(spent)} / ${_formatBaseCurrency(budget)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3. Progress Bar Meter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Container(
                        height: 10,
                        width: double.infinity,
                        color: const Color(0xFFF3ECE3),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isOverBudget
                                  ? [const Color(0xFFE53935), const Color(0xFFC62828)]
                                  : (progress > 0.8
                                      ? [brandOrange, const Color(0xFFD84315)]
                                      : [const Color(0xFF43A047), const Color(0xFF2E7D32)]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}% of budget used',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textMuted),
                    ),
                    Text(
                      '${(100 - progress * 100).clamp(0, 100).toStringAsFixed(1)}% left',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Daily Pace & Insights Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F3EC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEFE6DC), width: 0.8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: brandOrange),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Limit', style: TextStyle(fontSize: 10, color: textMuted)),
                          Text(
                            _formatCurrency(dailyBudget),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(height: 24, width: 1, color: const Color(0xFFE5DACD)),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.speed_rounded, size: 16, color: const Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Pace', style: TextStyle(fontSize: 10, color: textMuted)),
                          Text(
                            _formatCurrency(dailySpent),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
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

          // 5. Category Breakdown Section (Header navigates to all categories)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: InkWell(
              onTap: () => onCategoryTap?.call(null),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spending by Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: brandOrange,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: brandOrange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          _buildCategoryList(),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final catSpend = service.categorySpending;
    final total = service.totalSpent > 0 ? service.totalSpent : 1.0;

    final categoriesWithSpend = ExpenseCategory.values.where((c) => (catSpend[c] ?? 0.0) > 0).toList();

    if (categoriesWithSpend.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Text(
          'No expenses recorded yet.',
          style: TextStyle(color: textMuted, fontSize: 12, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: categoriesWithSpend.map((cat) {
          final amount = catSpend[cat] ?? 0.0;
          final pct = (amount / total).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onCategoryTap?.call(cat),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cat.bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(cat.icon, size: 14, color: cat.primaryColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      cat.label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: darkBrown,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 10,
                                      color: textMuted.withValues(alpha: 0.6),
                                    ),
                                  ],
                                ),
                                Text(
                                  _formatCurrency(amount),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: darkBrown,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 5,
                                backgroundColor: const Color(0xFFF3ECE3),
                                valueColor: AlwaysStoppedAnimation<Color>(cat.primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Quick Currency Toggle Button between Travelled Country (e.g. JPY) and Residential Country (MYR)
  Widget _buildCurrencySelectorPill(BuildContext context) {
    return InkWell(
      onTap: () {
        final nextCurrency = service.targetCurrencyCode == 'MYR'
            ? service.baseCurrencyCode
            : 'MYR';
        service.setCurrencies(target: nextCurrency);
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF3ECE3),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE5DACD), width: 0.8),
        ),
        child: Icon(
          Icons.sync_alt_rounded,
          size: 14,
          color: textMuted,
        ),
      ),
    );
  }
}

