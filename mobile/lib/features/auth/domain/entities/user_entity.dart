import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String phoneNumber;
  final String fullName;
  final bool hasPinConfigured;
  final bool isLocked;

  const UserEntity({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    required this.hasPinConfigured,
    required this.isLocked,
  });

  @override
  List<Object?> get props => [id, email, phoneNumber, fullName, hasPinConfigured, isLocked];
}
