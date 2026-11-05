import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.referenceNumber,
    required super.sourceWalletTag,
    required super.sourceUserFullName,
    required super.destinationWalletTag,
    required super.destinationUserFullName,
    required super.transactionType,
    required super.status,
    required super.amount,
    required super.fee,
    required super.totalDebited,
    required super.currency,
    super.description,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    DateTime parsedDate = DateTime.now();
    if (json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    return TransactionModel(
      id: json['id']?.toString() ?? '',
      referenceNumber: json['referenceNumber']?.toString() ?? '',
      sourceWalletTag: json['sourceWalletTag']?.toString() ?? '',
      sourceUserFullName: json['sourceUserFullName']?.toString() ?? '',
      destinationWalletTag: json['destinationWalletTag']?.toString() ?? '',
      destinationUserFullName: json['destinationUserFullName']?.toString() ?? '',
      transactionType: json['transactionType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      amount: parseNum(json['amount']),
      fee: parseNum(json['fee']),
      totalDebited: parseNum(json['totalDebited']),
      currency: json['currency']?.toString() ?? 'USD',
      description: json['description']?.toString(),
      createdAt: parsedDate,
    );
  }
}
