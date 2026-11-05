import '../../domain/entities/bill_inquiry_entity.dart';

class BillInquiryModel extends BillInquiryEntity {
  const BillInquiryModel({
    required super.billId,
    required super.companyCode,
    required super.companyName,
    required super.consumerNumber,
    required super.consumerName,
    required super.billingMonth,
    required super.amount,
    super.lateAmount,
    required super.dueDate,
    required super.isPaid,
    required super.isOverdue,
  });

  factory BillInquiryModel.fromJson(Map<String, dynamic> json) {
    return BillInquiryModel(
      billId: json['billId']?.toString() ?? '',
      companyCode: json['companyCode']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      consumerNumber: json['consumerNumber']?.toString() ?? '',
      consumerName: json['consumerName']?.toString() ?? '',
      billingMonth: json['billingMonth']?.toString() ?? '',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      lateAmount: json['lateAmount'] != null
          ? (json['lateAmount'] is num
              ? (json['lateAmount'] as num).toDouble()
              : double.tryParse(json['lateAmount'].toString()))
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isPaid: json['isPaid'] ?? json['paid'] ?? false,
      isOverdue: json['isOverdue'] ?? json['overdue'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billId': billId,
      'companyCode': companyCode,
      'companyName': companyName,
      'consumerNumber': consumerNumber,
      'consumerName': consumerName,
      'billingMonth': billingMonth,
      'amount': amount,
      'lateAmount': lateAmount,
      'dueDate': dueDate.toIso8601String(),
      'isPaid': isPaid,
      'isOverdue': isOverdue,
    };
  }
}
