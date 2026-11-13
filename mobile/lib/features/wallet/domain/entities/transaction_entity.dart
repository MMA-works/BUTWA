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

  bool isCreditFor(String currentWalletTag, [String? currentPhone]) {
    final type = transactionType.toUpperCase();
    if (type == 'TOPUP' || type == 'DEPOSIT') {
      return true;
    }

    final cleanMyTag = currentWalletTag.replaceAll(RegExp(r'^@+'), '').trim().toLowerCase();
    final cleanMyPhone = (currentPhone ?? '').replaceAll(RegExp(r'\D'), '');

    final dest = destinationWalletTag.toLowerCase();
    final destName = destinationUserFullName.toLowerCase();
    final src = sourceWalletTag.toLowerCase();
    final srcName = sourceUserFullName.toLowerCase();

    // 1. If destination matches my tag or phone, it's CREDIT (Money came in)
    if (cleanMyTag.isNotEmpty && (dest.contains(cleanMyTag) || destName.contains(cleanMyTag))) {
      return true;
    }
    if (cleanMyPhone.isNotEmpty && (dest.contains(cleanMyPhone) || destName.contains(cleanMyPhone))) {
      return true;
    }

    // 2. If source matches my tag or phone, it's DEBIT (Money went out)
    if (cleanMyTag.isNotEmpty && (src.contains(cleanMyTag) || srcName.contains(cleanMyTag))) {
      return false;
    }
    if (cleanMyPhone.isNotEmpty && (src.contains(cleanMyPhone) || srcName.contains(cleanMyPhone))) {
      return false;
    }

    // Fallback: If destination matches exactly
    return destinationWalletTag == currentWalletTag;
  }

  String getSenderDisplayTitle() {
    String raw = sourceUserFullName.isNotEmpty ? sourceUserFullName : sourceWalletTag;
    if (raw.contains('(')) {
      raw = raw.split('(')[0].trim();
    }
    return raw.isNotEmpty ? raw : 'BATWA User';
  }

  String getReceiverDisplayTitle() {
    String raw = destinationUserFullName.isNotEmpty ? destinationUserFullName : destinationWalletTag;
    if (raw.contains('(')) {
      raw = raw.split('(')[0].trim();
    }
    return raw.isNotEmpty ? raw : 'Recipient';
  }

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
