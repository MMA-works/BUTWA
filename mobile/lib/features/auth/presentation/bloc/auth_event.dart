import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String identifier;
  final String password;

  const LoginSubmittedEvent({required this.identifier, required this.password});

  @override
  List<Object?> get props => [identifier, password];
}

class RegisterSubmittedEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String? customTag;

  const RegisterSubmittedEvent({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.customTag,
  });

  @override
  List<Object?> get props => [fullName, email, phoneNumber, password, customTag];
}

class SetPinSubmittedEvent extends AuthEvent {
  final String pin;
  final String currentPassword;

  const SetPinSubmittedEvent({required this.pin, required this.currentPassword});

  @override
  List<Object?> get props => [pin, currentPassword];
}

class LogoutEvent extends AuthEvent {}
