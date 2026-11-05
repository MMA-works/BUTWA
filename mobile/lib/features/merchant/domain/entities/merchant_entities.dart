class MerchantProfileEntity {
  final String id;
  final String userId;
  final String businessName;
  final String businessCategory;
  final String? taxId;
  final String? storeAddress;
  final String? merchantWalletTag;
  final String? merchantFullName;
  final bool isActive;
  final DateTime? createdAt;

  const MerchantProfileEntity({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.businessCategory,
    this.taxId,
    this.storeAddress,
    this.merchantWalletTag,
    this.merchantFullName,
    required this.isActive,
    this.createdAt,
  });
}

class InvoiceItemEntity {
  final String id;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const InvoiceItemEntity({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

class InvoiceEntity {
  final String id;
  final String invoiceNumber;
  final String merchantUserId;
  final String merchantBusinessName;
  final String? merchantWalletTag;
  final String? customerUserId;
  final String? customerName;
  final String? customerIdentifier;
  final double subtotal;
  final double taxRatePercentage;
  final double taxAmount;
  final double grandTotal;
  final String currency;
  final String status;
  final String? description;
  final String? qrCodePayload;
  final String? transactionReference;
  final DateTime? paidAt;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final List<InvoiceItemEntity> items;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.merchantUserId,
    required this.merchantBusinessName,
    this.merchantWalletTag,
    this.customerUserId,
    this.customerName,
    this.customerIdentifier,
    required this.subtotal,
    required this.taxRatePercentage,
    required this.taxAmount,
    required this.grandTotal,
    required this.currency,
    required this.status,
    this.description,
    this.qrCodePayload,
    this.transactionReference,
    this.paidAt,
    this.dueDate,
    this.createdAt,
    required this.items,
  });
}

class MerchantDashboardEntity {
  final MerchantProfileEntity? profile;
  final double todayGrossSales;
  final int todayOrdersCount;
  final double monthGrossSales;
  final int monthOrdersCount;
  final double averageTicketSize;
  final int pendingInvoicesCount;
  final List<InvoiceEntity> recentInvoices;

  const MerchantDashboardEntity({
    this.profile,
    required this.todayGrossSales,
    required this.todayOrdersCount,
    required this.monthGrossSales,
    required this.monthOrdersCount,
    required this.averageTicketSize,
    required this.pendingInvoicesCount,
    required this.recentInvoices,
  });
}
