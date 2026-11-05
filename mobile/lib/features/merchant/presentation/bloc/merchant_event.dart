abstract class MerchantEvent {
  const MerchantEvent();
}

class LoadMerchantDashboardEvent extends MerchantEvent {}

class RegisterMerchantProfileEvent extends MerchantEvent {
  final String businessName;
  final String businessCategory;
  final String? taxId;
  final String? storeAddress;

  const RegisterMerchantProfileEvent({
    required this.businessName,
    required this.businessCategory,
    this.taxId,
    this.storeAddress,
  });
}

class CreatePosOrderEvent extends MerchantEvent {
  final double amount;
  final String? note;

  const CreatePosOrderEvent({
    required this.amount,
    this.note,
  });
}

class CreateInvoiceEvent extends MerchantEvent {
  final String? customerIdentifier;
  final String? customerName;
  final String? description;
  final double? taxRatePercentage;
  final List<Map<String, dynamic>> items;

  const CreateInvoiceEvent({
    this.customerIdentifier,
    this.customerName,
    this.description,
    this.taxRatePercentage,
    required this.items,
  });
}

class PayInvoiceEvent extends MerchantEvent {
  final String invoiceIdentifier;
  final String pin;

  const PayInvoiceEvent({
    required this.invoiceIdentifier,
    required this.pin,
  });
}
