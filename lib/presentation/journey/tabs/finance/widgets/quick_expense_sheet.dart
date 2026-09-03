import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../services/finance_service.dart';

/// Bottom Sheet for directly keying in a shared expense.
class QuickExpenseSheet extends StatefulWidget {
  final FinanceService service;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const QuickExpenseSheet({
    super.key,
    required this.service,
    required this.brandOrange,
    required this.darkBrown,
    required this.textMuted,
  });

  static Future<void> show(
    BuildContext context, {
    required FinanceService service,
    required Color brandOrange,
    required Color darkBrown,
    required Color textMuted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickExpenseSheet(
        service: service,
        brandOrange: brandOrange,
        darkBrown: darkBrown,
        textMuted: textMuted,
      ),
    );
  }

  @override
  State<QuickExpenseSheet> createState() => _QuickExpenseSheetState();
}

class _QuickExpenseSheetState extends State<QuickExpenseSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  late String _selectedPayerId;
  late Set<String> _selectedSplitMemberIds;

  @override
  void initState() {
    super.initState();
    _selectedPayerId = widget.service.currentUser.id;
    _selectedSplitMemberIds = widget.service.members.map((m) => m.id).toSet();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    final amountText = _amountController.text.trim().replaceAll(',', '');
    final amount = double.tryParse(amountText);
    final title = _titleController.text.trim();

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid expense amount.')),
      );
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for the expense.')),
      );
      return;
    }

    if (_selectedSplitMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one member to split with.')),
      );
      return;
    }

    final newExpense = Expense(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      totalAmount: amount,
      category: _selectedCategory,
      date: DateTime.now(),
      payerId: _selectedPayerId,
      splitType: ExpenseSplitType.equal,
      splitMemberIds: _selectedSplitMemberIds.toList(),
      currency: widget.service.budget.currency,
    );

    widget.service.addExpense(newExpense);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${newExpense.title}" to trip expenses!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: widget.darkBrown,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final amountText = _amountController.text.trim().replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0.0;
    final splitCount = _selectedSplitMemberIds.length;
    final perPerson = splitCount > 0 ? (amount / splitCount) : 0.0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0D5C7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.brandOrange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_note_rounded, color: widget.brandOrange, size: 22),
                ),
                const SizedBox(width: 10),
                Text(
                  'Add Quick Expense',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: widget.darkBrown,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 1. Amount Input
            Text(
              'Amount',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.textMuted),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: widget.darkBrown,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixText: '${widget.service.budget.currency} ',
                prefixStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: widget.brandOrange,
                ),
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: widget.textMuted.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: const Color(0xFFF3ECE3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: widget.brandOrange, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 2. Title Input
            Text(
              'Expense Description',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.textMuted),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: widget.darkBrown),
              decoration: InputDecoration(
                hintText: 'e.g. Tokyo Metro tickets, Coffee at Harajuku',
                hintStyle: TextStyle(fontSize: 13, color: widget.textMuted.withValues(alpha: 0.5)),
                filled: true,
                fillColor: const Color(0xFFF3ECE3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: widget.brandOrange, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 3. Category Selector
            Text(
              'Category',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.textMuted),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ExpenseCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      avatar: Icon(
                        cat.icon,
                        size: 14,
                        color: isSelected ? Colors.white : cat.primaryColor,
                      ),
                      label: Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : widget.darkBrown,
                        ),
                      ),
                      backgroundColor: const Color(0xFFF3ECE3),
                      selectedColor: widget.brandOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? widget.brandOrange : const Color(0xFFE5DACD),
                          width: 0.8,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // 4. Who Paid?
            Text(
              'Paid By',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.textMuted),
            ),
            const SizedBox(height: 8),
            Row(
              children: widget.service.members.map((member) {
                final isSelected = _selectedPayerId == member.id;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPayerId = member.id;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.brandOrange.withValues(alpha: 0.12)
                            : const Color(0xFFF3ECE3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? widget.brandOrange : const Color(0xFFE5DACD),
                          width: isSelected ? 1.5 : 0.8,
                        ),
                      ),
                      child: Column(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              member.avatarPath,
                              width: 26,
                              height: 26,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 26),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.isCurrentUser ? 'You' : member.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? widget.brandOrange : widget.darkBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // 5. Split With (Equal Split Checkboxes)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Split Equally With ($splitCount members)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.textMuted),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedSplitMemberIds.length == widget.service.members.length) {
                        _selectedSplitMemberIds.clear();
                        _selectedSplitMemberIds.add(_selectedPayerId);
                      } else {
                        _selectedSplitMemberIds = widget.service.members.map((m) => m.id).toSet();
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    _selectedSplitMemberIds.length == widget.service.members.length
                        ? 'Deselect All'
                        : 'Select All',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: widget.brandOrange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F3EC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEDE3D7), width: 0.8),
              ),
              child: Column(
                children: widget.service.members.map((member) {
                  final isChecked = _selectedSplitMemberIds.contains(member.id);
                  return CheckboxListTile(
                    value: isChecked,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedSplitMemberIds.add(member.id);
                        } else {
                          if (_selectedSplitMemberIds.length > 1) {
                            _selectedSplitMemberIds.remove(member.id);
                          }
                        }
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: widget.brandOrange,
                    title: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            member.avatarPath,
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          member.isCurrentUser ? 'You (Diana)' : member.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: widget.darkBrown,
                          ),
                        ),
                      ],
                    ),
                    secondary: isChecked && amount > 0
                        ? Text(
                            '${widget.service.budget.currency}${perPerson.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: widget.brandOrange,
                            ),
                          )
                        : null,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.brandOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Add to Trip Expenses',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
