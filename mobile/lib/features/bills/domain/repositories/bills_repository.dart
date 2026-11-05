import '../entities/bill_company_entity.dart';
import '../entities/bill_inquiry_entity.dart';
import '../entities/bill_payment_entity.dart';

abstract class BillsRepository {
  Future<List<BillCompanyEntity>> getCompanies({String? category});
  Future<BillInquiryEntity> inquireBill({required String companyCode, required String consumerNumber});
  Future<BillPaymentEntity> payBill({required String billId, required String pin});
}
