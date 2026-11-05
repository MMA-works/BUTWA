import 'package:batwa_wallet/features/merchant/domain/entities/merchant_entities.dart';

abstract class MerchantRepository {
  Future<MerchantProfileEntity> registerOrUpdateProfile({
    required String businessName,
    required String businessCategory,
    String? taxId,
    String? storeAddress,
  });
  Future<MerchantProfileEntity> getProfile();
  Future<MerchantDashboardEntity> getDashboard();
  Future<InvoiceEntity> createInvoice({
    String? customerIdentifier,
    String? customerName,
    String? description,
    double? taxRatePercentage,
    required List<Map<String, dynamic>> items,
  });
  Future<InvoiceEntity> createPosOrder({
    required double amount,
    String? note,
    String? orderReference,
  });
  Future<List<InvoiceEntity>> getInvoices();
  Future<InvoiceEntity> getInvoiceByNumber(String invoiceNumber);
  Future<InvoiceEntity> payInvoice({
    required String invoiceIdentifier,
    required String pin,
  });
}
