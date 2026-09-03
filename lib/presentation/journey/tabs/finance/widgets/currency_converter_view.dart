import 'package:flutter/material.dart';
import '../services/finance_service.dart';

/// Interactive Currency Converter and Travel Exchange Rate Cheat-Sheet.
class CurrencyConverterView extends StatefulWidget {
  final FinanceService service;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const CurrencyConverterView({
    super.key,
    required this.service,
    required this.brandOrange,
    required this.darkBrown,
    required this.textMuted,
  });

  @override
  State<CurrencyConverterView> createState() => _CurrencyConverterViewState();
}

class _CurrencyConverterViewState extends State<CurrencyConverterView> {
  final TextEditingController _amountController = TextEditingController(text: '1000');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showCurrencyPicker({required bool isBase}) {
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
                    isBase ? 'Select Base Currency' : 'Select Target Currency',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: widget.darkBrown,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFEDE3D7), height: 1),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: widget.service.supportedCurrencies.length,
                itemBuilder: (ctx, idx) {
                  final curr = widget.service.supportedCurrencies[idx];
                  final isSelected = isBase
                      ? curr.code == widget.service.baseCurrencyCode
                      : curr.code == widget.service.targetCurrencyCode;

                  return ListTile(
                    leading: Text(curr.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(
                      '${curr.code} (${curr.symbol})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? widget.brandOrange : widget.darkBrown,
                      ),
                    ),
                    subtitle: Text(curr.name, style: TextStyle(fontSize: 12, color: widget.textMuted)),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: widget.brandOrange, size: 20)
                        : null,
                    onTap: () {
                      if (isBase) {
                        widget.service.setCurrencies(base: curr.code);
                      } else {
                        widget.service.setCurrencies(target: curr.code);
                      }
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
    final inputVal = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    final convertedVal = widget.service.convert(
      inputVal,
      widget.service.baseCurrencyCode,
      widget.service.targetCurrencyCode,
    );

    final oneUnitRate = widget.service.convert(
      1.0,
      widget.service.baseCurrencyCode,
      widget.service.targetCurrencyCode,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Converter Main Box
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEDE3D7), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: widget.darkBrown.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
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
                          color: widget.brandOrange.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.currency_exchange_rounded, color: widget.brandOrange, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Live Currency Converter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: widget.darkBrown,
                        ),
                      ),
                    ],
                  ),
                  // Rate Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3ECE3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '1 ${widget.service.baseCurrencyCode} ≈ ${oneUnitRate < 0.01 ? oneUnitRate.toStringAsFixed(5) : oneUnitRate.toStringAsFixed(3)} ${widget.service.targetCurrencyCode}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.textMuted,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // From Currency Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F3EC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFE6DC), width: 0.8),
                ),
                child: Row(
                  children: [
                    // Currency Picker Button
                    InkWell(
                      onTap: () => _showCurrencyPicker(isBase: true),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0D5C7), width: 0.8),
                        ),
                        child: Row(
                          children: [
                            Text(widget.service.baseCurrency.flag, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              widget.service.baseCurrencyCode,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: widget.darkBrown,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: widget.textMuted),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Amount Input
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: widget.darkBrown,
                        ),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '0',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Swap Button
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: IconButton(
                    onPressed: () {
                      widget.service.swapCurrencies();
                      setState(() {});
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.brandOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.brandOrange.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),

              // To Currency Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F3EC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFE6DC), width: 0.8),
                ),
                child: Row(
                  children: [
                    // Currency Picker Button
                    InkWell(
                      onTap: () => _showCurrencyPicker(isBase: false),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0D5C7), width: 0.8),
                        ),
                        child: Row(
                          children: [
                            Text(widget.service.targetCurrency.flag, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              widget.service.targetCurrencyCode,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: widget.darkBrown,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: widget.textMuted),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Converted Output Display
                    Expanded(
                      child: Text(
                        '${widget.service.targetCurrency.symbol}${convertedVal.toStringAsFixed(2)}',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: widget.brandOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Quick Amount Preset Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [500, 1000, 3000, 5000, 10000, 50000].map((preset) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ActionChip(
                        label: Text(
                          '${widget.service.baseCurrency.symbol}$preset',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: widget.darkBrown),
                        ),
                        backgroundColor: const Color(0xFFF3ECE3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide.none,
                        onPressed: () {
                          setState(() {
                            _amountController.text = preset.toString();
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. Travel Price Pocket Cheat-Sheet
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEDE3D7), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: widget.darkBrown.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_outlined, size: 16, color: widget.brandOrange),
                  const SizedBox(width: 6),
                  Text(
                    'Travel Expense Cheat-Sheet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: widget.darkBrown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildCheatRow('🥫 Vending Machine Drink', 160.0),
              _buildCheatRow('🍜 Ramen Bowl (Shinjuku)', 1200.0),
              _buildCheatRow('🚇 Subway 24h Pass', 800.0),
              _buildCheatRow('🍣 Premium Sushi Lunch', 3800.0),
              _buildCheatRow('🗼 Tokyo Skytree Entry', 3100.0),
              _buildCheatRow('🚅 Shinkansen Bullet Train', 14500.0),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCheatRow(String itemLabel, double localAmount) {
    final converted = widget.service.convert(
      localAmount,
      'JPY', // Tokyo trip default
      widget.service.targetCurrencyCode,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(itemLabel, style: TextStyle(fontSize: 12, color: widget.darkBrown)),
          Row(
            children: [
              Text(
                '¥${localAmount.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.textMuted),
              ),
              const SizedBox(width: 6),
              Text(
                '≈ ${widget.service.targetCurrency.symbol}${converted.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: widget.brandOrange),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
