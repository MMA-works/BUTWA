import '../../domain/entities/bill_company_entity.dart';

class BillCompanyModel extends BillCompanyEntity {
  const BillCompanyModel({
    required super.id,
    required super.companyCode,
    required super.companyName,
    required super.category,
    required super.consumerNoLength,
    super.iconCode,
  });

  factory BillCompanyModel.fromJson(Map<String, dynamic> json) {
    return BillCompanyModel(
      id: json['id']?.toString() ?? '',
      companyCode: json['companyCode']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      category: json['category']?.toString() ?? 'OTHER',
      consumerNoLength: (json['consumerNoLength'] is num)
          ? (json['consumerNoLength'] as num).toInt()
          : int.tryParse(json['consumerNoLength']?.toString() ?? '10') ?? 10,
      iconCode: json['iconCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyCode': companyCode,
      'companyName': companyName,
      'category': category,
      'consumerNoLength': consumerNoLength,
      'iconCode': iconCode,
    };
  }
}
