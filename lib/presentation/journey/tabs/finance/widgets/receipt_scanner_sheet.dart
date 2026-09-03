import 'package:flutter/material.dart';
import '../../../../../services/google_ai_service.dart';
import '../models/finance_models.dart';
import '../services/finance_service.dart';

/// Smart Receipt Scanner & Interactive Item Claiming Modal Sheet.
/// Matches the exact user workflow:
/// 1. Choose whether you paid the bill or someone else paid.
/// 2. For each extracted item, choose whether YOU had that item (avatar appears next to it) or assign to friends.
/// 3. Service charges and tax are automatically retracted and apportioned.
class ReceiptScannerSheet extends StatefulWidget {
  final FinanceService service;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const ReceiptScannerSheet({
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
      builder: (ctx) => ReceiptScannerSheet(
        service: service,
        brandOrange: brandOrange,
        darkBrown: darkBrown,
        textMuted: textMuted,
      ),
    );
  }

  @override
  State<ReceiptScannerSheet> createState() => _ReceiptScannerSheetState();
}

class _ReceiptScannerSheetState extends State<ReceiptScannerSheet> {
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _serviceChargeController = TextEditingController();

  final GoogleAIService _aiService = GoogleAIService();
  List<ExpenseItem> _extractedItems = [];
  bool _didIPay = true;
  late String _selectedPayerId;
  ExpenseCategory _category = ExpenseCategory.food;
  bool _isScanning = false;
  int _selectedPresetIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedPayerId = widget.service.currentUser.id;
    _didIPay = true;
    _aiService.initialize();
    _loadPresetReceipt(0);
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _taxController.dispose();
    _serviceChargeController.dispose();
    super.dispose();
  }

  Future<void> _loadPresetReceipt(int index) async {
    _selectedPresetIndex = index;
    final result = await _aiService.analyzeReceipt(
      presetIndex: index,
      members: widget.service.members,
    );

    if (mounted) {
      setState(() {
        _merchantController.text = result.merchant;
        _category = result.category;
        _taxController.text = result.taxAmount.toStringAsFixed(0);
        _serviceChargeController.text = result.serviceCharge.toStringAsFixed(0);
        _extractedItems = result.items;
      });
    }
  }

  Future<void> _simulateCameraScan() async {
    setState(() {
      _isScanning = true;
    });

    final nextIdx = (_selectedPresetIndex + 1) % 3;
    final result = await _aiService.analyzeReceipt(
      presetIndex: nextIdx,
      members: widget.service.members,
    );

    if (mounted) {
      setState(() {
        _selectedPresetIndex = nextIdx;
        _merchantController.text = result.merchant;
        _category = result.category;
        _taxController.text = result.taxAmount.toStringAsFixed(0);
        _serviceChargeController.text = result.serviceCharge.toStringAsFixed(0);
        _extractedItems = result.items;
        _isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ Google AI extracted ${_extractedItems.length} items & service fees successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: widget.darkBrown,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  double get _itemsSubtotal {
    return _extractedItems.fold(0.0, (sum, it) => sum + it.totalPrice);
  }

  double get _taxAmount {
    return double.tryParse(_taxController.text.trim()) ?? 0.0;
  }

  double get _serviceChargeAmount {
    return double.tryParse(_serviceChargeController.text.trim()) ?? 0.0;
  }

  double get _totalReceiptAmount {
    return _itemsSubtotal + _taxAmount + _serviceChargeAmount;
  }

  Map<String, double> _calculatePerMemberPreview() {
    final tempExpense = Expense(
      id: 'preview',
      title: _merchantController.text.trim(),
      totalAmount: _totalReceiptAmount,
      category: _category,
      date: DateTime.now(),
      payerId: _selectedPayerId,
      splitType: ExpenseSplitType.itemized,
      items: _extractedItems,
      serviceChargeAmount: _serviceChargeAmount,
      taxAmount: _taxAmount,
      currency: widget.service.budget.currency,
    );

    return tempExpense.calculateMemberShares(widget.service.members);
  }

  void _toggleMemberForItem(int itemIndex, String memberId) {
    setState(() {
      final item = _extractedItems[itemIndex];
      final current = List<String>.from(item.assignedMemberIds);

      if (current.contains(memberId)) {
        current.remove(memberId);
      } else {
        current.add(memberId);
      }

      _extractedItems[itemIndex] = item.copyWith(assignedMemberIds: current);
    });
  }

  void _addNewCustomItem() {
    setState(() {
      _extractedItems.add(
        ExpenseItem(
          id: 'item_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Custom Item',
          price: 1000.0,
          quantity: 1,
          assignedMemberIds: [widget.service.currentUser.id],
        ),
      );
    });
  }

  void _saveReceiptExpense() {
    final merchant = _merchantController.text.trim();
    if (merchant.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a merchant / restaurant name.')),
      );
      return;
    }

    if (_extractedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item from the receipt.')),
      );
      return;
    }

    final newExpense = Expense(
      id: 'receipt_${DateTime.now().millisecondsSinceEpoch}',
      title: merchant,
      totalAmount: _totalReceiptAmount,
      category: _category,
      date: DateTime.now(),
      payerId: _selectedPayerId,
      splitType: ExpenseSplitType.itemized,
      receiptMerchant: merchant,
      items: _extractedItems,
      serviceChargeAmount: _serviceChargeAmount,
      taxAmount: _taxAmount,
      currency: widget.service.budget.currency,
    );

    widget.service.addExpense(newExpense);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved "${newExpense.title}" receipt & apportioned shares! 🎉'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.darkBrown,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final memberShares = _calculatePerMemberPreview();
    final presets = widget.service.getSampleReceiptPresets();
    final currentUserId = widget.service.currentUser.id;
    final yourShare = memberShares[currentUserId] ?? 0.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header with drag handle
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Column(
              children: [
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.brandOrange.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.document_scanner_rounded, color: widget.brandOrange, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart Receipt Scanner',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: widget.darkBrown,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Extract items & choose what you had',
                                  style: TextStyle(fontSize: 11, color: widget.textMuted),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F0FE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '⚡ Google AI',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF1967D2)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: widget.textMuted,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFFEDE3D7), height: 1),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Scanner Camera / Preset Selector Bar
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3ECE3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5DACD), width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.receipt_long_rounded, size: 16, color: widget.brandOrange),
                                const SizedBox(width: 6),
                                Text(
                                  'Receipt Presets (Google AI)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: widget.darkBrown,
                                  ),
                                ),
                              ],
                            ),
                            // Scan Button
                            InkWell(
                              onTap: _simulateCameraScan,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: widget.brandOrange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _isScanning
                                        ? const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.camera_alt_outlined, size: 13, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isScanning ? 'Extracting...' : 'Scan Receipt',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: List.generate(presets.length, (idx) {
                              final preset = presets[idx];
                              final isSelected = _selectedPresetIndex == idx;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: InkWell(
                                  onTap: () => _loadPresetReceipt(idx),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : const Color(0xFFEAE0D5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? widget.brandOrange : Colors.transparent,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      preset['merchant'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? widget.brandOrange : widget.darkBrown,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Merchant Name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Merchant / Restaurant',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: widget.textMuted),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _merchantController,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.darkBrown),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF3ECE3),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 3. STEP 1: DID YOU PAY FOR THIS BILL? (Yes / No toggle)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: widget.brandOrange.withValues(alpha: 0.35), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.payment_rounded, color: widget.brandOrange, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Did you pay for this bill?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: widget.darkBrown,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // Option: Yes, I paid
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _didIPay = true;
                                    _selectedPayerId = currentUserId;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _didIPay ? widget.brandOrange : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _didIPay ? widget.brandOrange : const Color(0xFFE5DACD),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _didIPay ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                          size: 16,
                                          color: _didIPay ? Colors.white : widget.textMuted,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Yes, I paid',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _didIPay ? Colors.white : widget.darkBrown,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Option: No / Someone else paid
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _didIPay = false;
                                    final other = widget.service.members.firstWhere(
                                      (m) => !m.isCurrentUser,
                                      orElse: () => widget.service.members.first,
                                    );
                                    _selectedPayerId = other.id;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !_didIPay ? widget.darkBrown : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !_didIPay ? widget.darkBrown : const Color(0xFFE5DACD),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          !_didIPay ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                          size: 16,
                                          color: !_didIPay ? Colors.white : widget.textMuted,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'No',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: !_didIPay ? Colors.white : widget.darkBrown,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 4. STEP 2: EXTRACTED ITEMS & CHOOSE WHAT YOU BOUGHT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Extracted Items',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: widget.darkBrown,
                            ),
                          ),
                          Text(
                            'Tap "I had this" for items you bought/ate',
                            style: TextStyle(fontSize: 11, color: widget.textMuted),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _addNewCustomItem,
                        icon: Icon(Icons.add_circle_outline_rounded, size: 14, color: widget.brandOrange),
                        label: Text(
                          'Add Item',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: widget.brandOrange),
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Items List with prominent "I had this" toggle & small member avatars!
                  ..._extractedItems.asMap().entries.map((entry) {
                    final itemIdx = entry.key;
                    final item = entry.value;
                    final didIHaveThis = item.assignedMemberIds.contains(currentUserId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: didIHaveThis ? const Color(0xFFFFFDF8) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: didIHaveThis ? widget.brandOrange.withValues(alpha: 0.4) : const Color(0xFFEDE3D7),
                          width: didIHaveThis ? 1.4 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.darkBrown.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Name, Price & Small Claimed Avatars
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '${item.quantity > 1 ? "${item.quantity}x " : ""}${item.title}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: widget.darkBrown,
                                            ),
                                          ),
                                        ),
                                        // Small Avatars Appear Right Next to the Extracted Item!
                                        if (item.assignedMemberIds.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: item.assignedMemberIds.map((mId) {
                                              final m = widget.service.getMemberById(mId);
                                              if (m == null) return const SizedBox();

                                              return Container(
                                                margin: const EdgeInsets.only(left: 2),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: m.isCurrentUser ? widget.brandOrange : Colors.white,
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.08),
                                                      blurRadius: 3,
                                                    ),
                                                  ],
                                                ),
                                                child: ClipOval(
                                                  child: Image.asset(
                                                    m.avatarPath,
                                                    width: 20,
                                                    height: 20,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 20),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      didIHaveThis
                                          ? 'Included in your share'
                                          : 'Not claimed by you',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: didIHaveThis ? widget.brandOrange : widget.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.service.budget.currency}${item.totalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: widget.darkBrown,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Interactive Claiming Button (User only)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                didIHaveThis
                                    ? '✓ Claimed by you'
                                    : 'Did you buy this item?',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: didIHaveThis ? FontWeight.w700 : FontWeight.w500,
                                  color: didIHaveThis ? widget.brandOrange : widget.textMuted,
                                ),
                              ),
                              // Toggle Button: "I bought this"
                              GestureDetector(
                                onTap: () => _toggleMemberForItem(itemIdx, currentUserId),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: didIHaveThis
                                        ? widget.brandOrange
                                        : const Color(0xFFF3ECE3),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: didIHaveThis ? widget.brandOrange : const Color(0xFFE5DACD),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        didIHaveThis ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                        size: 14,
                                        color: didIHaveThis ? Colors.white : widget.darkBrown,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        didIHaveThis ? 'Claimed ✓' : 'I bought this',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: didIHaveThis ? Colors.white : widget.darkBrown,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 14),

                  // 5. Service Charges & Taxes Retraction
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F3EC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEDE3D7), width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Retracted Service Fees & Taxes',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: widget.darkBrown,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Service Fee (${widget.service.budget.currency})', style: TextStyle(fontSize: 10, color: widget.textMuted)),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: _serviceChargeController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.darkBrown),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tax / VAT (${widget.service.budget.currency})', style: TextStyle(fontSize: 10, color: widget.textMuted)),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: _taxController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.darkBrown),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '✨ Automatically split in exact proportion to each person\'s claimed items.',
                          style: TextStyle(fontSize: 10, color: widget.textMuted, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 6. Real-time Summary Card (Highlighting YOUR share)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBF7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: widget.brandOrange.withValues(alpha: 0.35), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Share to Pay',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.darkBrown),
                            ),
                            Text(
                              '${widget.service.budget.currency}${yourShare.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: widget.brandOrange),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFFEDE3D7), height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Receipt Total (${_didIPay ? "Paid by You" : "Paid by friend"})',
                              style: TextStyle(fontSize: 11, color: widget.textMuted),
                            ),
                            Text(
                              '${widget.service.budget.currency}${_totalReceiptAmount.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: widget.darkBrown),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveReceiptExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.brandOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Confirm & Record Expense',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
