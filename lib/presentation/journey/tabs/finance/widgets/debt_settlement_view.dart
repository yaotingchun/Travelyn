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
    return '$sym${converted.toStringAsFixed(2)}';
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
              const SizedBox(height: 14),

              // Members List (Seamless list with subtle dividers)
              ...service.members.asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;
                final balance = netBalances[member.id] ?? 0.0;
                final isCreditor = balance > 0.01;
                final isDebtor = balance < -0.01;
                final isLast = index == service.members.length - 1;

                // Total paid by this member
                final totalPaid = service.expenses
                    .where((e) => e.payerId == member.id)
                    .fold(0.0, (sum, e) => sum + e.totalAmount);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                                  service.targetCurrencyCode != service.baseCurrencyCode
                                      ? 'Paid ${_formatCurrency(totalPaid)} (≈ ${_formatConverted(totalPaid)})'
                                      : 'Paid ${_formatCurrency(totalPaid)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Net Balance & Status
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isCreditor
                                    ? 'gets back ${_formatCurrency(balance)}'
                                    : (isDebtor
                                        ? 'owes ${_formatCurrency(balance.abs())}'
                                        : 'settled up'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isCreditor
                                      ? const Color(0xFF2E7D32)
                                      : (isDebtor ? const Color(0xFFD32F2F) : textMuted),
                                ),
                              ),
                              if (balance.abs() > 0.01 && service.targetCurrencyCode != service.baseCurrencyCode)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    '≈ ${_formatConverted(balance.abs())}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isCreditor
                                          ? const Color(0xFF2E7D32).withValues(alpha: 0.8)
                                          : const Color(0xFFD32F2F).withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(height: 1, thickness: 0.6, color: Color(0xFFEDE3D7)),
                  ],
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
                  'Optimized repayments to clear balances',
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
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDE3D7), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: darkBrown.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Pair of Avatars with direction arrow
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          fromMember.avatarPath,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 32),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.arrow_forward_rounded, size: 14, color: brandOrange),
                      ),
                      ClipOval(
                        child: Image.asset(
                          toMember.avatarPath,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Who pays whom + Amount & Converted Amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              color: darkBrown,
                              fontFamily: 'PlusJakartaSans',
                            ),
                            children: [
                              TextSpan(
                                text: fromMember.isCurrentUser ? 'You' : fromMember.name,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: ' pays ',
                                style: TextStyle(color: textMuted, fontSize: 12),
                              ),
                              TextSpan(
                                text: toMember.isCurrentUser ? 'You' : toMember.name,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              _formatCurrency(settle.amount),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: brandOrange,
                              ),
                            ),
                            if (service.targetCurrencyCode != service.baseCurrencyCode) ...[
                              const SizedBox(width: 6),
                              Text(
                                '≈ ${_formatConverted(settle.amount)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Settle Action Button (Soft pill matching design language)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
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
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFC8E6C9), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, size: 14, color: Color(0xFF2E7D32)),
                            SizedBox(width: 3),
                            Text(
                              'Settle',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
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
          }),

        const SizedBox(height: 20),
      ],
    );
  }
}
