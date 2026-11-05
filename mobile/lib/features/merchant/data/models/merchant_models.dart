import 'package:batwa_wallet/features/merchant/domain/entities/merchant_entities.dart';

class MerchantProfileModel extends MerchantProfileEntity {
  const MerchantProfileModel({
    required super.id,
    required super.userId,
    required super.businessName,
    required super.businessCategory,
    super.taxId,
    super.storeAddress,
    super.merchantWalletTag,
    super.merchantFullName,
    required super.isActive,
    super.createdAt,
  });

  factory MerchantProfileModel.fromJson(Map<String, dynamic> json) {
    return MerchantProfileModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      businessName: json['businessName'] ?? '',
      businessCategory: json['businessCategory'] ?? 'RETAIL',
      taxId: json['taxId'],
      storeAddress: json['storeAddress'],
      merchantWalletTag: json['merchantWalletTag'],
      merchantFullName: json['merchantFullName'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

class InvoiceItemModel extends InvoiceItemEntity {
  const InvoiceItemModel({
    required super.id,
    required super.itemName,
    required super.quantity,
    required super.unitPrice,
    required super.totalPrice,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] ?? '',
      itemName: json['itemName'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}

class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.merchantUserId,
    required super.merchantBusinessName,
    super.merchantWalletTag,
    super.customerUserId,
    super.customerName,
    super.customerIdentifier,
    required super.subtotal,
    required super.taxRatePercentage,
    required super.taxAmount,
    required super.grandTotal,
    required super.currency,
    required super.status,
    super.description,
    super.qrCodePayload,
    super.transactionReference,
    super.paidAt,
    super.dueDate,
    super.createdAt,
    required super.items,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return InvoiceModel(
      id: json['id'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      merchantUserId: json['merchantUserId'] ?? '',
      merchantBusinessName: json['merchantBusinessName'] ?? 'Merchant',
      merchantWalletTag: json['merchantWalletTag'],
      customerUserId: json['customerUserId'],
      customerName: json['customerName'],
      customerIdentifier: json['customerIdentifier'],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxRatePercentage: (json['taxRatePercentage'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'PENDING',
      description: json['description'],
      qrCodePayload: json['qrCodePayload'],
      transactionReference: json['transactionReference'],
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt']) : null,
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      items: itemsList,
    );
  }
}

class MerchantDashboardModel extends MerchantDashboardEntity {
  const MerchantDashboardModel({
    super.profile,
    required super.todayGrossSales,
    required super.todayOrdersCount,
    required super.monthGrossSales,
    required super.monthOrdersCount,
    required super.averageTicketSize,
    required super.pendingInvoicesCount,
    required super.recentInvoices,
  });

  factory MerchantDashboardModel.fromJson(Map<String, dynamic> json) {
    MerchantProfileModel? profileModel;
    if (json['profile'] != null) {
      profileModel = MerchantProfileModel.fromJson(json['profile'] as Map<String, dynamic>);
    }

    final invoicesList = (json['recentInvoices'] as List<dynamic>?)
            ?.map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return MerchantDashboardModel(
      profile: profileModel,
      todayGrossSales: (json['todayGrossSales'] as num?)?.toDouble() ?? 0.0,
      todayOrdersCount: (json['todayOrdersCount'] as num?)?.toInt() ?? 0,
      monthGrossSales: (json['monthGrossSales'] as num?)?.toDouble() ?? 0.0,
      monthOrdersCount: (json['monthOrdersCount'] as num?)?.toInt() ?? 0,
      averageTicketSize: (json['averageTicketSize'] as num?)?.toDouble() ?? 0.0,
      pendingInvoicesCount: (json['pendingInvoicesCount'] as num?)?.toInt() ?? 0,
      recentInvoices: invoicesList,
    );
  }
}
