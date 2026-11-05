import 'package:equatable/equatable.dart';

class BillCompanyEntity extends Equatable {
  final String id;
  final String companyCode;
  final String companyName;
  final String category;
  final int consumerNoLength;
  final String? iconCode;

  const BillCompanyEntity({
    required this.id,
    required this.companyCode,
    required this.companyName,
    required this.category,
    required this.consumerNoLength,
    this.iconCode,
  });

  @override
  List<Object?> get props => [id, companyCode, companyName, category, consumerNoLength, iconCode];
}
