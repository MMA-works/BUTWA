import 'package:equatable/equatable.dart';

class BillPaymentEntity extends Equatable {
  final String billId;
  final String paymentReference;
  final String companyName;
  final String consumerNumber;
  final String consumerName;
  final String billingMonth;
  final double amountPaid;
  final String currency;
  final DateTime paidAt;
  final String transactionStatus;

  const BillPaymentEntity({
    required this.billId,
    required this.paymentReference,
    required this.companyName,
    required this.consumerNumber,
    required this.consumerName,
    required this.billingMonth,
    required this.amountPaid,
    required this.currency,
    required this.paidAt,
    required this.transactionStatus,
  });

  @override
  List<Object?> get props => [
        billId,
        paymentReference,
        companyName,
        consumerNumber,
        consumerName,
        billingMonth,
        amountPaid,
        currency,
        paidAt,
        transactionStatus,
      ];
}
