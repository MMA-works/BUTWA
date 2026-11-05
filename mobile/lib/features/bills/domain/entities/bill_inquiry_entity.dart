import 'package:equatable/equatable.dart';

class BillInquiryEntity extends Equatable {
  final String billId;
  final String companyCode;
  final String companyName;
  final String consumerNumber;
  final String consumerName;
  final String billingMonth;
  final double amount;
  final double? lateAmount;
  final DateTime dueDate;
  final bool isPaid;
  final bool isOverdue;

  const BillInquiryEntity({
    required this.billId,
    required this.companyCode,
    required this.companyName,
    required this.consumerNumber,
    required this.consumerName,
    required this.billingMonth,
    required this.amount,
    this.lateAmount,
    required this.dueDate,
    required this.isPaid,
    required this.isOverdue,
  });

  @override
  List<Object?> get props => [
        billId,
        companyCode,
        companyName,
        consumerNumber,
        consumerName,
        billingMonth,
        amount,
        lateAmount,
        dueDate,
        isPaid,
        isOverdue,
      ];
}
