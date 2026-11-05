import 'package:equatable/equatable.dart';

abstract class BillsEvent extends Equatable {
  const BillsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCompaniesEvent extends BillsEvent {
  final String? category;

  const FetchCompaniesEvent({this.category});

  @override
  List<Object?> get props => [category];
}

class InquireBillEvent extends BillsEvent {
  final String companyCode;
  final String consumerNumber;

  const InquireBillEvent({
    required this.companyCode,
    required this.consumerNumber,
  });

  @override
  List<Object?> get props => [companyCode, consumerNumber];
}

class PayBillEvent extends BillsEvent {
  final String billId;
  final String pin;

  const PayBillEvent({
    required this.billId,
    required this.pin,
  });

  @override
  List<Object?> get props => [billId, pin];
}

class ResetBillStateEvent extends BillsEvent {
  const ResetBillStateEvent();
}
