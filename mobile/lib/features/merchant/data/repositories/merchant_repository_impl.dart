import 'package:batwa_wallet/features/merchant/data/datasources/merchant_remote_datasource.dart';
import 'package:batwa_wallet/features/merchant/domain/entities/merchant_entities.dart';
import 'package:batwa_wallet/features/merchant/domain/repositories/merchant_repository.dart';

class MerchantRepositoryImpl implements MerchantRepository {
  final MerchantRemoteDataSource remoteDataSource;

  MerchantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<MerchantProfileEntity> registerOrUpdateProfile({
    required String businessName,
    required String businessCategory,
    String? taxId,
    String? storeAddress,
  }) {
    return remoteDataSource.registerOrUpdateProfile(
      businessName: businessName,
      businessCategory: businessCategory,
      taxId: taxId,
      storeAddress: storeAddress,
    );
  }

  @override
  Future<MerchantProfileEntity> getProfile() {
    return remoteDataSource.getProfile();
  }

  @override
  Future<MerchantDashboardEntity> getDashboard() {
    return remoteDataSource.getDashboard();
  }

  @override
  Future<InvoiceEntity> createInvoice({
    String? customerIdentifier,
    String? customerName,
    String? description,
    double? taxRatePercentage,
    required List<Map<String, dynamic>> items,
  }) {
    return remoteDataSource.createInvoice(
      customerIdentifier: customerIdentifier,
      customerName: customerName,
      description: description,
      taxRatePercentage: taxRatePercentage,
      items: items,
    );
  }

  @override
  Future<InvoiceEntity> createPosOrder({
    required double amount,
    String? note,
    String? orderReference,
  }) {
    return remoteDataSource.createPosOrder(
      amount: amount,
      note: note,
      orderReference: orderReference,
    );
  }

  @override
  Future<List<InvoiceEntity>> getInvoices() {
    return remoteDataSource.getInvoices();
  }

  @override
  Future<InvoiceEntity> getInvoiceByNumber(String invoiceNumber) {
    return remoteDataSource.getInvoiceByNumber(invoiceNumber);
  }

  @override
  Future<InvoiceEntity> payInvoice({
    required String invoiceIdentifier,
    required String pin,
  }) {
    return remoteDataSource.payInvoice(
      invoiceIdentifier: invoiceIdentifier,
      pin: pin,
    );
  }
}
