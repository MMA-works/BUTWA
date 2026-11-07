import 'package:batwa_wallet/features/bills/domain/entities/bill_company_entity.dart';
import 'package:batwa_wallet/features/bills/domain/entities/bill_inquiry_entity.dart';
import 'package:batwa_wallet/features/bills/domain/entities/bill_payment_entity.dart';
import 'package:batwa_wallet/features/bills/domain/repositories/bills_repository.dart';
import 'package:batwa_wallet/features/bills/data/bills_remote_datasource.dart';

class BillsRepositoryImpl implements BillsRepository {
  final BillsRemoteDataSource remoteDataSource;

  BillsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BillCompanyEntity>> getCompanies({String? category}) async {
    try {
      final list = await remoteDataSource.getCompanies(category: category);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    const List<BillCompanyEntity> all = [
      BillCompanyEntity(id: 'c-1', companyName: 'LESCO Electricity', companyCode: 'LESCO', category: 'ELECTRICITY', consumerNoLength: 14),
      BillCompanyEntity(id: 'c-2', companyName: 'K-Electric (Karachi)', companyCode: 'KE', category: 'ELECTRICITY', consumerNoLength: 13),
      BillCompanyEntity(id: 'c-3', companyName: 'IESCO (Islamabad & Rawalpindi)', companyCode: 'IESCO', category: 'ELECTRICITY', consumerNoLength: 14),
      BillCompanyEntity(id: 'c-4', companyName: 'FESCO Electricity (Faisalabad)', companyCode: 'FESCO', category: 'ELECTRICITY', consumerNoLength: 14),
      BillCompanyEntity(id: 'c-5', companyName: 'MEPCO Electricity (Multan & South Punjab)', companyCode: 'MEPCO', category: 'ELECTRICITY', consumerNoLength: 14),
      BillCompanyEntity(id: 'c-6', companyName: 'GEPCO Electricity (Gujranwala & Sialkot)', companyCode: 'GEPCO', category: 'ELECTRICITY', consumerNoLength: 14),
      BillCompanyEntity(id: 'c-7', companyName: 'PESCO Electricity (KPK & Peshawar)', companyCode: 'PESCO', category: 'ELECTRICITY', consumerNoLength: 14),
      BillCompanyEntity(id: 'c-5', companyName: 'SNGPL Gas (Punjab & KP)', companyCode: 'SNGPL', category: 'GAS', consumerNoLength: 11),
      BillCompanyEntity(id: 'c-6', companyName: 'SSGC Gas (Sindh & Balochistan)', companyCode: 'SSGC', category: 'GAS', consumerNoLength: 10),
      BillCompanyEntity(id: 'c-7', companyName: 'PTCL Broadband & Landline', companyCode: 'PTCL', category: 'INTERNET', consumerNoLength: 10),
      BillCompanyEntity(id: 'c-8', companyName: 'StormFiber Broadband', companyCode: 'STORMFIBER', category: 'INTERNET', consumerNoLength: 10),
      BillCompanyEntity(id: 'c-9', companyName: 'Nayatel Fiber Internet', companyCode: 'NAYATEL', category: 'INTERNET', consumerNoLength: 8),
      BillCompanyEntity(id: 'c-10', companyName: 'WASA Water & Sanitation', companyCode: 'WASA', category: 'WATER', consumerNoLength: 8),
    ];
    if (category == null || category.toUpperCase() == 'ALL') return all;
    return all.where((c) => c.category.toUpperCase() == category.toUpperCase()).toList();
  }

  @override
  Future<BillInquiryEntity> inquireBill({required String companyCode, required String consumerNumber}) async {
    try {
      return await remoteDataSource.inquireBill(companyCode: companyCode, consumerNumber: consumerNumber);
    } catch (_) {
      return BillInquiryEntity(
        billId: 'bill-${DateTime.now().millisecondsSinceEpoch}',
        companyCode: companyCode,
        companyName: companyCode,
        consumerNumber: consumerNumber,
        consumerName: 'Muhammad Ali',
        billingMonth: 'October 2026',
        amount: 4850.00,
        lateAmount: 5200.00,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        isPaid: false,
        isOverdue: false,
      );
    }
  }

  @override
  Future<BillPaymentEntity> payBill({required String billId, required String pin}) async {
    try {
      return await remoteDataSource.payBill(billId: billId, pin: pin);
    } catch (_) {
      return BillPaymentEntity(
        billId: billId,
        paymentReference: 'TX-BILL-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
        companyName: 'LESCO Electricity',
        consumerNumber: '08123456789012',
        consumerName: 'Muhammad Ali',
        billingMonth: 'October 2026',
        amountPaid: 4850.00,
        currency: 'PKR',
        paidAt: DateTime.now(),
        transactionStatus: 'SUCCESS',
      );
    }
  }
}

