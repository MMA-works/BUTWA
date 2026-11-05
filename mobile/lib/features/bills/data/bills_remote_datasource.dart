import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'package:batwa_wallet/features/bills/data/models/bill_company_model.dart';
import 'package:batwa_wallet/features/bills/data/models/bill_inquiry_model.dart';
import 'package:batwa_wallet/features/bills/data/models/bill_payment_model.dart';

abstract class BillsRemoteDataSource {
  Future<List<BillCompanyModel>> getCompanies({String? category});
  Future<BillInquiryModel> inquireBill({required String companyCode, required String consumerNumber});
  Future<BillPaymentModel> payBill({required String billId, required String pin});
}

class BillsRemoteDataSourceImpl implements BillsRemoteDataSource {
  final ApiClient apiClient;

  BillsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<BillCompanyModel>> getCompanies({String? category}) async {
    try {
      final response = await apiClient.client.get(
        ApiConstants.billCompanies,
        queryParameters: category != null && category.isNotEmpty ? {'category': category} : null,
      );
      if (response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((json) => BillCompanyModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to fetch bill companies');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<BillInquiryModel> inquireBill({
    required String companyCode,
    required String consumerNumber,
  }) async {
    try {
      final response = await apiClient.client.get(
        ApiConstants.billInquiry,
        queryParameters: {
          'companyCode': companyCode,
          'consumerNumber': consumerNumber,
        },
      );
      if (response.data['success'] == true) {
        return BillInquiryModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to fetch bill details');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<BillPaymentModel> payBill({
    required String billId,
    required String pin,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.payBill,
        data: {
          'billId': billId,
          'pin': pin,
        },
      );
      if (response.data['success'] == true) {
        return BillPaymentModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to process bill payment');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
