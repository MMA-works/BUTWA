import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/utils/secure_storage_helper.dart';
import 'package:batwa_wallet/features/auth/domain/entities/user_entity.dart';
import 'package:batwa_wallet/features/auth/domain/repositories/auth_repository.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_event.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<SetPinSubmittedEvent>(_onSetPinSubmitted);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        final token = await SecureStorageHelper.getAccessToken();
        final name = await SecureStorageHelper.getFullName();
        if (token != null && token.isNotEmpty && name != null && name.isNotEmpty) {
          final phone = await SecureStorageHelper.getUserPhone() ?? '';
          final email = await SecureStorageHelper.getUserEmail() ?? '';
          emit(Authenticated(
            user: UserEntity(
              id: 'usr_local',
              email: email,
              phoneNumber: phone,
              fullName: name,
              hasPinConfigured: true,
              isLocked: false,
            ),
          ));
        } else {
          emit(Unauthenticated());
        }
      }
    } catch (e) {
      final token = await SecureStorageHelper.getAccessToken();
      final name = await SecureStorageHelper.getFullName();
      if (token != null && token.isNotEmpty && name != null && name.isNotEmpty) {
        final phone = await SecureStorageHelper.getUserPhone() ?? '';
        final email = await SecureStorageHelper.getUserEmail() ?? '';
        emit(Authenticated(
          user: UserEntity(
            id: 'usr_local',
            email: email,
            phoneNumber: phone,
            fullName: name,
            hasPinConfigured: true,
            isLocked: false,
          ),
        ));
      } else {
        emit(Unauthenticated());
      }
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.identifier, event.password);
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.register(
        fullName: event.fullName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        password: event.password,
        customTag: event.customTag,
        cnicNumber: event.cnicNumber,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onSetPinSubmitted(
    SetPinSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.setPin(
        pin: event.pin,
        currentPassword: event.currentPassword,
      );
      UserEntity? user = await authRepository.getCurrentUser();
      if (user == null) {
        final name = await SecureStorageHelper.getFullName();
        final phone = await SecureStorageHelper.getUserPhone() ?? '';
        final email = await SecureStorageHelper.getUserEmail() ?? '';
        if (name != null && name.isNotEmpty) {
          user = UserEntity(
            id: 'usr_active',
            email: email,
            phoneNumber: phone,
            fullName: name,
            hasPinConfigured: true,
            isLocked: false,
          );
        }
      }
      if (user != null) {
        emit(PinSetSuccess(user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(Unauthenticated());
  }
}
