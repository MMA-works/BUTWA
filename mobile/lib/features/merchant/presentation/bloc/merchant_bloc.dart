import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_event.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_state.dart';

class MerchantBloc extends Bloc<MerchantEvent, MerchantState> {
  final MerchantRepository merchantRepository;

  MerchantBloc({required this.merchantRepository}) : super(MerchantInitial()) {
    on<LoadMerchantDashboardEvent>(_onLoadDashboard);
    on<RegisterMerchantProfileEvent>(_onRegisterProfile);
    on<CreatePosOrderEvent>(_onCreatePosOrder);
    on<CreateInvoiceEvent>(_onCreateInvoice);
    on<PayInvoiceEvent>(_onPayInvoice);
  }

  Future<void> _onLoadDashboard(
    LoadMerchantDashboardEvent event,
    Emitter<MerchantState> emit,
  ) async {
    emit(MerchantLoading());
    try {
      final dashboard = await merchantRepository.getDashboard();
      emit(MerchantDashboardLoaded(dashboard: dashboard));
    } catch (e) {
      emit(MerchantError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterProfile(
    RegisterMerchantProfileEvent event,
    Emitter<MerchantState> emit,
  ) async {
    emit(MerchantLoading());
    try {
      await merchantRepository.registerOrUpdateProfile(
        businessName: event.businessName,
        businessCategory: event.businessCategory,
        taxId: event.taxId,
        storeAddress: event.storeAddress,
      );
      final dashboard = await merchantRepository.getDashboard();
      emit(MerchantDashboardLoaded(dashboard: dashboard, message: 'Merchant profile registered successfully!'));
    } catch (e) {
      emit(MerchantError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreatePosOrder(
    CreatePosOrderEvent event,
    Emitter<MerchantState> emit,
  ) async {
    emit(MerchantLoading());
    try {
      final invoice = await merchantRepository.createPosOrder(
        amount: event.amount,
        note: event.note,
      );
      emit(PosOrderCreatedState(invoice: invoice));
    } catch (e) {
      emit(MerchantError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateInvoice(
    CreateInvoiceEvent event,
    Emitter<MerchantState> emit,
  ) async {
    emit(MerchantLoading());
    try {
      final invoice = await merchantRepository.createInvoice(
        customerIdentifier: event.customerIdentifier,
        customerName: event.customerName,
        description: event.description,
        taxRatePercentage: event.taxRatePercentage,
        items: event.items,
      );
      emit(InvoiceCreatedState(invoice: invoice));
    } catch (e) {
      emit(MerchantError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onPayInvoice(
    PayInvoiceEvent event,
    Emitter<MerchantState> emit,
  ) async {
    emit(MerchantLoading());
    try {
      final invoice = await merchantRepository.payInvoice(
        invoiceIdentifier: event.invoiceIdentifier,
        pin: event.pin,
      );
      emit(InvoicePaidState(invoice: invoice));
    } catch (e) {
      emit(MerchantError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
