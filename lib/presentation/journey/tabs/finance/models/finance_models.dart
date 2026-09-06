import 'package:flutter/material.dart';

/// Represents a participant in the trip.
class TripMember {
  final String id;
  final String name;
  final String avatarPath;
  final bool isCurrentUser;

  const TripMember({
    required this.id,
    required this.name,
    required this.avatarPath,
    this.isCurrentUser = false,
  });

  TripMember copyWith({
    String? id,
    String? name,
    String? avatarPath,
    bool? isCurrentUser,
  }) {
    return TripMember(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

/// Expense categories with custom icons and color schemes.
enum ExpenseCategory {
  food('Food & Dining', Icons.restaurant_rounded, Color(0xFFE65100), Color(0xFFFFF3E0)),
  transport('Transport', Icons.directions_subway_rounded, Color(0xFF1565C0), Color(0xFFE3F2FD)),
  activities('Activities & Sightseeing', Icons.local_activity_rounded, Color(0xFF2E7D32), Color(0xFFE8F5E9)),
  shopping('Shopping', Icons.shopping_bag_rounded, Color(0xFF6A1B9A), Color(0xFFF3E5F5)),
  lodging('Lodging', Icons.hotel_rounded, Color(0xFFC2185B), Color(0xFFFCE4EC)),
  entertainment('Nightlife & Drinks', Icons.local_bar_rounded, Color(0xFFEF6C00), Color(0xFFFFF8E1)),
  miscellaneous('Other', Icons.receipt_long_rounded, Color(0xFF455A64), Color(0xFFECEFF1));

  final String label;
  final IconData icon;
  final Color primaryColor;
  final Color bgColor;

  const ExpenseCategory(this.label, this.icon, this.primaryColor, this.bgColor);
}

/// A line item extracted from a receipt or manually entered.
class ExpenseItem {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final List<String> assignedMemberIds;

  const ExpenseItem({
    required this.id,
    required this.title,
    required this.price,
    this.quantity = 1,
    this.assignedMemberIds = const [],
  });

  double get totalPrice => price * quantity;

  ExpenseItem copyWith({
    String? id,
    String? title,
    double? price,
    int? quantity,
    List<String>? assignedMemberIds,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      assignedMemberIds: assignedMemberIds ?? this.assignedMemberIds,
    );
  }
}

/// Split mode for an expense.
enum ExpenseSplitType {
  equal,
  itemized,
}

/// An expense recorded in the trip ledger.
class Expense {
  final String id;
  final String title;
  final double totalAmount;
  final ExpenseCategory category;
  final DateTime date;
  final String payerId;
  final ExpenseSplitType splitType;
  final List<String> splitMemberIds; // For equal split
  final List<ExpenseItem> items; // For itemized split
  final double serviceChargeAmount; // Service charge (e.g. 10%)
  final double taxAmount; // VAT/GST
  final String? receiptMerchant;
  final String? receiptImage;
  final String currency;

  const Expense({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.category,
    required this.date,
    required this.payerId,
    this.splitType = ExpenseSplitType.equal,
    this.splitMemberIds = const [],
    this.items = const [],
    this.serviceChargeAmount = 0.0,
    this.taxAmount = 0.0,
    this.receiptMerchant,
    this.receiptImage,
    this.currency = '¥',
  });

  /// Computes how much each member owes for this expense.
  Map<String, double> calculateMemberShares(List<TripMember> allMembers) {
    final Map<String, double> shares = {};
    for (final member in allMembers) {
      shares[member.id] = 0.0;
    }

    if (splitType == ExpenseSplitType.equal) {
      final activeMembers = splitMemberIds.isNotEmpty
          ? splitMemberIds
          : allMembers.map((m) => m.id).toList();

      if (activeMembers.isNotEmpty) {
        final perPerson = totalAmount / activeMembers.length;
        for (final memberId in activeMembers) {
          shares[memberId] = perPerson;
        }
      }
    } else {
      // Itemized split with proportional tax and service charge
      final Map<String, double> itemSubtotals = {};
      for (final member in allMembers) {
        itemSubtotals[member.id] = 0.0;
      }

      double totalItemsCost = 0.0;
      for (final item in items) {
        final itemCost = item.totalPrice;
        totalItemsCost += itemCost;

        final assigned = item.assignedMemberIds.isNotEmpty
            ? item.assignedMemberIds
            : allMembers.map((m) => m.id).toList();

        final perMemberCost = itemCost / (assigned.isEmpty ? 1 : assigned.length);
        for (final memberId in assigned) {
          itemSubtotals[memberId] = (itemSubtotals[memberId] ?? 0.0) + perMemberCost;
        }
      }

      final extraFees = serviceChargeAmount + taxAmount;

      for (final member in allMembers) {
        final subtotal = itemSubtotals[member.id] ?? 0.0;
        double feeShare = 0.0;
        if (totalItemsCost > 0) {
          feeShare = extraFees * (subtotal / totalItemsCost);
        } else if (allMembers.isNotEmpty) {
          feeShare = extraFees / allMembers.length;
        }
        shares[member.id] = subtotal + feeShare;
      }
    }

    return shares;
  }

  Expense copyWith({
    String? id,
    String? title,
    double? totalAmount,
    ExpenseCategory? category,
    DateTime? date,
    String? payerId,
    ExpenseSplitType? splitType,
    List<String>? splitMemberIds,
    List<ExpenseItem>? items,
    double? serviceChargeAmount,
    double? taxAmount,
    String? receiptMerchant,
    String? receiptImage,
    String? currency,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      totalAmount: totalAmount ?? this.totalAmount,
      category: category ?? this.category,
      date: date ?? this.date,
      payerId: payerId ?? this.payerId,
      splitType: splitType ?? this.splitType,
      splitMemberIds: splitMemberIds ?? this.splitMemberIds,
      items: items ?? this.items,
      serviceChargeAmount: serviceChargeAmount ?? this.serviceChargeAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      receiptMerchant: receiptMerchant ?? this.receiptMerchant,
      receiptImage: receiptImage ?? this.receiptImage,
      currency: currency ?? this.currency,
    );
  }
}

/// Budget configuration for the trip.
class TripBudget {
  final double totalBudget;
  final String currency;
  final Map<ExpenseCategory, double> categoryAllocations;

  const TripBudget({
    required this.totalBudget,
    this.currency = '¥',
    this.categoryAllocations = const {},
  });

  TripBudget copyWith({
    double? totalBudget,
    String? currency,
    Map<ExpenseCategory, double>? categoryAllocations,
  }) {
    return TripBudget(
      totalBudget: totalBudget ?? this.totalBudget,
      currency: currency ?? this.currency,
      categoryAllocations: categoryAllocations ?? this.categoryAllocations,
    );
  }
}

/// A simplified pairwise debt settlement transaction ("A owes B amount").
class DebtSettlement {
  final String fromMemberId;
  final String toMemberId;
  final double amount;
  final bool isSettled;

  const DebtSettlement({
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
    this.isSettled = false,
  });

  DebtSettlement copyWith({
    String? fromMemberId,
    String? toMemberId,
    double? amount,
    bool? isSettled,
  }) {
    return DebtSettlement(
      fromMemberId: fromMemberId ?? this.fromMemberId,
      toMemberId: toMemberId ?? this.toMemberId,
      amount: amount ?? this.amount,
      isSettled: isSettled ?? this.isSettled,
    );
  }
}

/// Currency conversion information.
class CurrencyRate {
  final String code;
  final String name;
  final String symbol;
  final String flag;
  final double rateToUSD; // 1 USD = X in this currency

  const CurrencyRate({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    required this.rateToUSD,
  });
}
