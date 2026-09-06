import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../services/google_ai_service.dart';
import '../models/finance_models.dart';
import '../services/finance_service.dart';

/// Smart Receipt Scanner & Interactive Item Claiming Modal Sheet.
/// Connects to Google AI (credentials/google.json) to extract receipt items from
/// uploaded receipt photos (Camera / Gallery) or demo presets.
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
      useRootNavigator: true,
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
  final ImagePicker _picker = ImagePicker();

  final GoogleAIService _aiService = GoogleAIService();
  List<ExpenseItem> _extractedItems = [];
  bool _didIPay = true;
  late String _selectedPayerId;
  ExpenseCategory _category = ExpenseCategory.food;
  bool _isScanning = false;
  Uint8List? _uploadedImageBytes;
  String? _uploadedImageName;

  @override
  void initState() {
    super.initState();
    _selectedPayerId = widget.service.currentUser.id;
    _didIPay = true;
    _aiService.initialize();
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _taxController.dispose();
    _serviceChargeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _uploadedImageBytes = bytes;
          _uploadedImageName = file.name;
          _isScanning = true;
        });

        final result = await _aiService.analyzeReceipt(
          imageBytes: bytes,
          imagePath: file.path,
          members: widget.service.members,
        );

        if (mounted) {
          setState(() {
            _merchantController.text = result.merchant;
            _category = result.category;
            _taxController.text = result.taxAmount.toStringAsFixed(2);
            _serviceChargeController.text = result.serviceCharge.toStringAsFixed(2);
            _extractedItems = result.items;
            _isScanning = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✨ Google AI successfully extracted items from your receipt!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: widget.darkBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load image: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
          title: 'Custom Dish / Item',
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
                  // 1. UPLOAD RECEIPT OPTIONS (Gallery / Camera / Presets)
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
                            Text(
                              'Upload Receipt Image',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: widget.darkBrown,
                              ),
                            ),
                            if (_isScanning)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: widget.brandOrange,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Google AI Scanning...',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: widget.brandOrange,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Action Buttons: Gallery, Camera
                        Row(
                          children: [
                            // Gallery Upload Button
                            Expanded(
                              child: InkWell(
                                onTap: _isScanning ? null : () => _pickImage(ImageSource.gallery),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: widget.brandOrange,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: widget.brandOrange.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.photo_library_rounded, size: 16, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'Upload Photo',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Camera Button
                            Expanded(
                              child: InkWell(
                                onTap: _isScanning ? null : () => _pickImage(ImageSource.camera),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF453026),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'Take Photo',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // If user uploaded a custom image, show thumbnail preview
                        if (_uploadedImageBytes != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: widget.brandOrange.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _uploadedImageBytes!,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _uploadedImageName ?? 'Uploaded Receipt',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: widget.darkBrown,
                                        ),
                                      ),
                                      Text(
                                        '✓ Processed with Google AI',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: widget.brandOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

                  // 3. STEP 1: DID YOU PAY FOR THIS BILL?
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
                            // Option: No
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

                        // If user did not pay (No is selected), show other members' avatars to choose from
                        if (!_didIPay) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Who paid upfront?',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: widget.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: widget.service.members
                                .where((m) => !m.isCurrentUser)
                                .map((friend) {
                              final isSelected = _selectedPayerId == friend.id;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedPayerId = friend.id;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected ? widget.brandOrange.withValues(alpha: 0.15) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? widget.brandOrange : const Color(0xFFE5DACD),
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Stack(
                                          children: [
                                            ClipOval(
                                              child: Image.asset(
                                                friend.avatarPath,
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 32),
                                              ),
                                            ),
                                            if (isSelected)
                                              Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.all(1.5),
                                                  decoration: BoxDecoration(
                                                    color: widget.brandOrange,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.check, size: 9, color: Colors.white),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          friend.name,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
                        ],
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

                  if (_extractedItems.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEDE3D7), width: 1.0),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_rounded, size: 36, color: widget.textMuted.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text(
                            'No items extracted yet',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.darkBrown),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Upload or take a photo above to let Google AI extract all items automatically.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: widget.textMuted),
                          ),
                        ],
                      ),
                    )
                  else
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
                                        // Small Avatar Appears Right Next to the Extracted Item when selected!
                                        if (didIHaveThis) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: widget.brandOrange,
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
                                                widget.service.currentUser.avatarPath,
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 20),
                                              ),
                                            ),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${widget.service.budget.currency}${item.totalPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: widget.darkBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '≈ ${widget.service.targetCurrency.symbol}${widget.service.convert(item.totalPrice, widget.service.baseCurrencyCode, widget.service.targetCurrencyCode).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: widget.textMuted,
                                    ),
                                  ),
                                ],
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${widget.service.budget.currency}${yourShare.toStringAsFixed(0)}',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: widget.brandOrange),
                                ),
                                Text(
                                  '≈ ${widget.service.targetCurrency.symbol}${widget.service.convert(yourShare, widget.service.baseCurrencyCode, widget.service.targetCurrencyCode).toStringAsFixed(2)} ${widget.service.targetCurrencyCode}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: widget.brandOrange.withValues(alpha: 0.85)),
                                ),
                              ],
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${widget.service.budget.currency}${_totalReceiptAmount.toStringAsFixed(0)}',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: widget.darkBrown),
                                ),
                                Text(
                                  '≈ ${widget.service.targetCurrency.symbol}${widget.service.convert(_totalReceiptAmount, widget.service.baseCurrencyCode, widget.service.targetCurrencyCode).toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: widget.textMuted),
                                ),
                              ],
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
