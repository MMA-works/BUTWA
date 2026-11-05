import 'package:batwa_wallet/features/merchant/domain/entities/merchant_entities.dart';

abstract class MerchantState {
  const MerchantState();
}

class MerchantInitial extends MerchantState {}

class MerchantLoading extends MerchantState {}

class MerchantDashboardLoaded extends MerchantState {
  final MerchantDashboardEntity dashboard;
  final String? message;

  const MerchantDashboardLoaded({required this.dashboard, this.message});
}

class PosOrderCreatedState extends MerchantState {
  final InvoiceEntity invoice;

  const PosOrderCreatedState({required this.invoice});
}

class InvoiceCreatedState extends MerchantState {
  final InvoiceEntity invoice;

  const InvoiceCreatedState({required this.invoice});
}

class InvoicePaidState extends MerchantState {
  final InvoiceEntity invoice;

  const InvoicePaidState({required this.invoice});
}

class MerchantError extends MerchantState {
  final String message;

  const MerchantError(this.message);
}
