import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String referenceNumber;
  final String sourceWalletTag;
  final String sourceUserFullName;
  final String destinationWalletTag;
  final String destinationUserFullName;
  final String transactionType;
  final String status;
  final double amount;
  final double fee;
  final double totalDebited;
  final String currency;
  final String? description;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.referenceNumber,
    required this.sourceWalletTag,
    required this.sourceUserFullName,
    required this.destinationWalletTag,
    required this.destinationUserFullName,
    required this.transactionType,
    required this.status,
    required this.amount,
    required this.fee,
    required this.totalDebited,
    required this.currency,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        referenceNumber,
        sourceWalletTag,
        destinationWalletTag,
        transactionType,
        status,
        amount,
        fee,
        totalDebited,
        currency,
        description,
        createdAt,
      ];
}
