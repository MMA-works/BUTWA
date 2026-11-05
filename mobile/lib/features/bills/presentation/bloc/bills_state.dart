import 'package:equatable/equatable.dart';
import '../../domain/entities/bill_company_entity.dart';
import '../../domain/entities/bill_inquiry_entity.dart';
import '../../domain/entities/bill_payment_entity.dart';

abstract class BillsState extends Equatable {
  const BillsState();

  @override
  List<Object?> get props => [];
}

class BillsInitialState extends BillsState {
  const BillsInitialState();
}

class BillsLoadingState extends BillsState {
  const BillsLoadingState();
}

class BillsCompaniesLoadedState extends BillsState {
  final List<BillCompanyEntity> companies;
  final String? selectedCategory;

  const BillsCompaniesLoadedState({
    required this.companies,
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [companies, selectedCategory];
}

class BillInquiryLoadedState extends BillsState {
  final BillInquiryEntity inquiry;

  const BillInquiryLoadedState({required this.inquiry});

  @override
  List<Object?> get props => [inquiry];
}

class BillPaymentProcessingState extends BillsState {
  const BillPaymentProcessingState();
}

class BillPaymentSuccessState extends BillsState {
  final BillPaymentEntity payment;

  const BillPaymentSuccessState({required this.payment});

  @override
  List<Object?> get props => [payment];
}

class BillsErrorState extends BillsState {
  final String message;

  const BillsErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
