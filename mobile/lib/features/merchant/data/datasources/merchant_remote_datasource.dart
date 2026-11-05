import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'package:batwa_wallet/features/merchant/data/models/merchant_models.dart';

abstract class MerchantRemoteDataSource {
  Future<MerchantProfileModel> registerOrUpdateProfile({
    required String businessName,
    required String businessCategory,
    String? taxId,
    String? storeAddress,
  });
  Future<MerchantProfileModel> getProfile();
  Future<MerchantDashboardModel> getDashboard();
  Future<InvoiceModel> createInvoice({
    String? customerIdentifier,
    String? customerName,
    String? description,
    double? taxRatePercentage,
    required List<Map<String, dynamic>> items,
  });
  Future<InvoiceModel> createPosOrder({
    required double amount,
    String? note,
    String? orderReference,
  });
  Future<List<InvoiceModel>> getInvoices();
  Future<InvoiceModel> getInvoiceByNumber(String invoiceNumber);
  Future<InvoiceModel> payInvoice({
    required String invoiceIdentifier,
    required String pin,
  });
}

class MerchantRemoteDataSourceImpl implements MerchantRemoteDataSource {
  final ApiClient apiClient;

  MerchantRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MerchantProfileModel> registerOrUpdateProfile({
    required String businessName,
    required String businessCategory,
    String? taxId,
    String? storeAddress,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.merchantProfile,
        data: {
          'businessName': businessName,
          'businessCategory': businessCategory,
          if (taxId != null) 'taxId': taxId,
          if (storeAddress != null) 'storeAddress': storeAddress,
        },
      );
      if (response.data['success'] == true) {
        return MerchantProfileModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to update merchant profile');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<MerchantProfileModel> getProfile() async {
    try {
      final response = await apiClient.client.get(ApiConstants.merchantProfile);
      if (response.data['success'] == true) {
        return MerchantProfileModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to get merchant profile');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<MerchantDashboardModel> getDashboard() async {
    try {
      final response = await apiClient.client.get(ApiConstants.merchantDashboard);
      if (response.data['success'] == true) {
        return MerchantDashboardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to get merchant dashboard');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<InvoiceModel> createInvoice({
    String? customerIdentifier,
    String? customerName,
    String? description,
    double? taxRatePercentage,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.merchantInvoices,
        data: {
          if (customerIdentifier != null) 'customerIdentifier': customerIdentifier,
          if (customerName != null) 'customerName': customerName,
          if (description != null) 'description': description,
          if (taxRatePercentage != null) 'taxRatePercentage': taxRatePercentage,
          'items': items,
        },
      );
      if (response.data['success'] == true) {
        return InvoiceModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to create invoice');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<InvoiceModel> createPosOrder({
    required double amount,
    String? note,
    String? orderReference,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.merchantPosOrder,
        data: {
          'amount': amount,
          if (note != null) 'note': note,
          if (orderReference != null) 'orderReference': orderReference,
        },
      );
      if (response.data['success'] == true) {
        return InvoiceModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to create POS order');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<List<InvoiceModel>> getInvoices() async {
    try {
      final response = await apiClient.client.get(ApiConstants.merchantInvoices);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to get invoices');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<InvoiceModel> getInvoiceByNumber(String invoiceNumber) async {
    try {
      final response = await apiClient.client.get(ApiConstants.merchantInvoiceByNumber(invoiceNumber));
      if (response.data['success'] == true) {
        return InvoiceModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to find invoice');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<InvoiceModel> payInvoice({
    required String invoiceIdentifier,
    required String pin,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.merchantPayInvoice,
        data: {
          'invoiceIdentifier': invoiceIdentifier,
          'pin': pin,
        },
      );
      if (response.data['success'] == true) {
        return InvoiceModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to pay invoice');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
