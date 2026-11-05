import '../../domain/entities/bill_payment_entity.dart';

class BillPaymentModel extends BillPaymentEntity {
  const BillPaymentModel({
    required super.billId,
    required super.paymentReference,
    required super.companyName,
    required super.consumerNumber,
    required super.consumerName,
    required super.billingMonth,
    required super.amountPaid,
    required super.currency,
    required super.paidAt,
    required super.transactionStatus,
  });

  factory BillPaymentModel.fromJson(Map<String, dynamic> json) {
    return BillPaymentModel(
      billId: json['billId']?.toString() ?? '',
      paymentReference: json['paymentReference']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      consumerNumber: json['consumerNumber']?.toString() ?? '',
      consumerName: json['consumerName']?.toString() ?? '',
      billingMonth: json['billingMonth']?.toString() ?? '',
      amountPaid: (json['amountPaid'] is num)
          ? (json['amountPaid'] as num).toDouble()
          : double.tryParse(json['amountPaid']?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      paidAt: json['paidAt'] != null
          ? DateTime.tryParse(json['paidAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      transactionStatus: json['transactionStatus']?.toString() ?? 'SUCCESS',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billId': billId,
      'paymentReference': paymentReference,
      'companyName': companyName,
      'consumerNumber': consumerNumber,
      'consumerName': consumerName,
      'billingMonth': billingMonth,
      'amountPaid': amountPaid,
      'currency': currency,
      'paidAt': paidAt.toIso8601String(),
      'transactionStatus': transactionStatus,
    };
  }
}
