import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../services/finance_service.dart';

/// Interactive card displaying an expense with expandable itemized breakdown.
class ExpenseListCard extends StatefulWidget {
  final Expense expense;
  final FinanceService service;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const ExpenseListCard({
    super.key,
    required this.expense,
    required this.service,
    required this.brandOrange,
    required this.darkBrown,
    required this.textMuted,
  });

  @override
  State<ExpenseListCard> createState() => _ExpenseListCardState();
}

class _ExpenseListCardState extends State<ExpenseListCard> {
  bool _isExpanded = false;

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  String _formatCurrency(double amount) {
    final currency = widget.expense.currency;
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$currency$formatted';
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete Expense?',
          style: TextStyle(color: widget.darkBrown, fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          'Are you sure you want to remove "${widget.expense.title}"? This will recalculate everyone\'s balances.',
          style: TextStyle(color: widget.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: widget.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              widget.service.deleteExpense(widget.expense.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exp = widget.expense;
    final payer = widget.service.getMemberById(exp.payerId);
    final shares = exp.calculateMemberShares(widget.service.members);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE3D7), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: widget.darkBrown.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Top Summary Row
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Icon Badge
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: exp.category.bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: exp.category.primaryColor.withValues(alpha: 0.2),
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        exp.category.icon,
                        color: exp.category.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title, Payer, Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exp.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: widget.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              if (payer != null) ...[
                                ClipOval(
                                  child: Image.asset(
                                    payer.avatarPath,
                                    width: 15,
                                    height: 15,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 15),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Paid by ${payer.isCurrentUser ? "You" : payer.name}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: widget.brandOrange,
                                  ),
                                ),
                                Text(
                                  ' • ',
                                  style: TextStyle(fontSize: 11, color: widget.textMuted),
                                ),
                              ],
                              Text(
                                _formatDate(exp.date),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          // Split Type Tag
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: exp.splitType == ExpenseSplitType.itemized
                                      ? const Color(0xFFEDE7F6)
                                      : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  exp.splitType == ExpenseSplitType.itemized
                                      ? '🧾 Itemized Receipt'
                                      : '🤝 Equal Split',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: exp.splitType == ExpenseSplitType.itemized
                                        ? const Color(0xFF512DA8)
                                        : const Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                              if (exp.receiptMerchant != null) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    exp.receiptMerchant!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      color: widget.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Amount & Expand Arrow
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(exp.totalAmount),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: widget.darkBrown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: widget.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Breakdown Section
            if (_isExpanded) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9F3EC),
                  border: Border(
                    top: BorderSide(color: Color(0xFFEDE3D7), width: 0.8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // If itemized, list individual line items
                    if (exp.splitType == ExpenseSplitType.itemized && exp.items.isNotEmpty) ...[
                      Text(
                        'Extracted Line Items',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: widget.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...exp.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity > 1 ? "${item.quantity}x " : ""}${item.title}',
                                  style: TextStyle(fontSize: 12, color: widget.darkBrown),
                                ),
                              ),
                              // Member avatars assigned to this item
                              Row(
                                children: item.assignedMemberIds.map((mId) {
                                  final m = widget.service.getMemberById(mId);
                                  if (m == null) return const SizedBox();
                                  return Container(
                                    margin: const EdgeInsets.only(left: 3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.2),
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        m.avatarPath,
                                        width: 16,
                                        height: 16,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 16),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatCurrency(item.totalPrice),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: widget.darkBrown,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (exp.serviceChargeAmount > 0 || exp.taxAmount > 0) ...[
                        const Divider(color: Color(0xFFE5DACD), height: 16),
                        if (exp.serviceChargeAmount > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Service Charge (Apportioned)',
                                style: TextStyle(fontSize: 11, color: widget.textMuted),
                              ),
                              Text(
                                _formatCurrency(exp.serviceChargeAmount),
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: widget.textMuted),
                              ),
                            ],
                          ),
                        if (exp.taxAmount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Consumption Tax / VAT',
                                  style: TextStyle(fontSize: 11, color: widget.textMuted),
                                ),
                                Text(
                                  _formatCurrency(exp.taxAmount),
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: widget.textMuted),
                                ),
                              ],
                            ),
                          ),
                      ],
                      const Divider(color: Color(0xFFE5DACD), height: 18),
                    ],

                    // Member Cost Shares
                    Text(
                      'Split Breakdown per Member',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: widget.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.service.members.map((member) {
                      final share = shares[member.id] ?? 0.0;
                      if (share <= 0.01) return const SizedBox();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          children: [
                            ClipOval(
                              child: Image.asset(
                                member.avatarPath,
                                width: 18,
                                height: 18,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 18),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                member.isCurrentUser ? 'You (Diana)' : member.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: member.isCurrentUser ? FontWeight.w700 : FontWeight.w500,
                                  color: widget.darkBrown,
                                ),
                              ),
                            ),
                            Text(
                              _formatCurrency(share),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: widget.darkBrown,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                    // Action Buttons (Delete)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _confirmDelete,
                        icon: const Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFC62828)),
                        label: const Text(
                          'Delete Expense',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFC62828)),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
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
    );
  }
}
