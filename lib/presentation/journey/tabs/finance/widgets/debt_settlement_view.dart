import 'package:flutter/material.dart';
import '../services/finance_service.dart';

/// View for "Who Owes Who" debt calculations & simplified pairwise settlement
/// with integrated live multi-currency conversion.
class DebtSettlementView extends StatelessWidget {
  final FinanceService service;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const DebtSettlementView({
    super.key,
    required this.service,
    required this.brandOrange,
    required this.darkBrown,
    required this.textMuted,
  });

  String _formatCurrency(double amount) {
    final currency = service.budget.currency;
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$currency$formatted';
  }

  String _formatConverted(double amountInJPY) {
    final converted = service.convert(
      amountInJPY,
      service.baseCurrencyCode,
      service.targetCurrencyCode,
    );
    final sym = service.targetCurrency.symbol;
    final code = service.targetCurrencyCode;
    return '$sym${converted.toStringAsFixed(2)} $code';
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFBF7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0D5C7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Convert Balances To',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkBrown,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFEDE3D7), height: 1),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: service.supportedCurrencies.length,
                itemBuilder: (ctx, idx) {
                  final curr = service.supportedCurrencies[idx];
                  final isSelected = curr.code == service.targetCurrencyCode;

                  return ListTile(
                    leading: Text(curr.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(
                      '${curr.code} (${curr.symbol})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? brandOrange : darkBrown,
                      ),
                    ),
                    subtitle: Text(curr.name, style: TextStyle(fontSize: 12, color: textMuted)),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: brandOrange, size: 20)
                        : null,
                    onTap: () {
                      service.setCurrencies(target: curr.code);
                      Navigator.of(ctx).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final netBalances = service.memberNetBalances;
    final settlements = service.calculatedSettlements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Group Net Balances Overview Card with Currency Converter Badge
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEDE3D7), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: darkBrown.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        child: Icon(Icons.account_balance_rounded, color: brandOrange, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Member Net Balances',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: darkBrown,
                        ),
                      ),
                    ],
                  ),
                  // Currency Selector Button
                  InkWell(
                    onTap: () => _showCurrencyPicker(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3ECE3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5DACD), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(service.targetCurrency.flag, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            service.targetCurrencyCode,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: textMuted),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Members List
              ...service.members.map((member) {
                final balance = netBalances[member.id] ?? 0.0;
                final isCreditor = balance > 0.01;
                final isDebtor = balance < -0.01;

                // Total paid by this member
                final totalPaid = service.expenses
                    .where((e) => e.payerId == member.id)
                    .fold(0.0, (sum, e) => sum + e.totalAmount);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F3EC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEFE6DC), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          member.avatarPath,
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 38),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.isCurrentUser ? 'You (Diana)' : member.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: member.isCurrentUser ? FontWeight.w800 : FontWeight.w700,
                                color: darkBrown,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Paid ${_formatCurrency(totalPaid)} (${_formatConverted(totalPaid)})',
                              style: TextStyle(fontSize: 11, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                      // Net Balance Badge with Currency Conversion
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isCreditor
                              ? const Color(0xFFE8F5E9)
                              : (isDebtor ? const Color(0xFFFFEBEE) : const Color(0xFFECEFF1)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCreditor
                                ? const Color(0xFFC8E6C9)
                                : (isDebtor ? const Color(0xFFFFCDD2) : const Color(0xFFCFD8DC)),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isCreditor
                                  ? 'Gets back'
                                  : (isDebtor ? 'Owes' : 'Settled'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isCreditor
                                    ? const Color(0xFF2E7D32)
                                    : (isDebtor ? const Color(0xFFC62828) : textMuted),
                              ),
                            ),
                            Text(
                              isCreditor
                                  ? '+${_formatCurrency(balance)}'
                                  : (isDebtor
                                      ? '-${_formatCurrency(balance.abs())}'
                                      : '¥0'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isCreditor
                                    ? const Color(0xFF2E7D32)
                                    : (isDebtor ? const Color(0xFFC62828) : darkBrown),
                              ),
                            ),
                            if (balance.abs() > 0.01)
                              Text(
                                '≈ ${_formatConverted(balance.abs())}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isCreditor
                                      ? const Color(0xFF2E7D32).withValues(alpha: 0.8)
                                      : const Color(0xFFC62828).withValues(alpha: 0.8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. Simplified Settlement Payments Plan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggested Settlement Plan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: darkBrown,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Converted to ${service.targetCurrency.flag} ${service.targetCurrencyCode} in real time',
                  style: TextStyle(fontSize: 11, color: textMuted),
                ),
              ],
            ),
            if (settlements.isEmpty)
              TextButton(
                onPressed: () => service.resetSettlements(),
                child: Text('Reset', style: TextStyle(fontSize: 12, color: brandOrange)),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (settlements.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEDE3D7), width: 1.0),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'All Settled Up!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: darkBrown),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No one owes anyone money right now.',
                    style: TextStyle(fontSize: 12, color: textMuted),
                  ),
                ],
              ),
            ),
          )
        else
          ...settlements.map((settle) {
            final fromMember = service.getMemberById(settle.fromMemberId);
            final toMember = service.getMemberById(settle.toMemberId);

            if (fromMember == null || toMember == null) return const SizedBox();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEDE3D7), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: darkBrown.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Debtor (Sender)
                  Column(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          fromMember.avatarPath,
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 34),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fromMember.isCurrentUser ? 'You' : fromMember.name,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: darkBrown),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),

                  // Arrow with Amount Transfer + Converted Currency
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'pays ${_formatCurrency(settle.amount)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: brandOrange,
                          ),
                        ),
                        Text(
                          '(≈ ${_formatConverted(settle.amount)})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1.5,
                                color: brandOrange.withValues(alpha: 0.5),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: brandOrange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Creditor (Receiver)
                  Column(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          toMember.avatarPath,
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 34),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        toMember.isCurrentUser ? 'You' : toMember.name,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: darkBrown),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // Settle Up Action Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {
                      service.markDebtSettled(settle);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Marked payment of ${_formatCurrency(settle.amount)} (${_formatConverted(settle.amount)}) as settled! ✨'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: darkBrown,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    child: const Text(
                      'Settle',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          }),

        const SizedBox(height: 20),
      ],
    );
  }
}
