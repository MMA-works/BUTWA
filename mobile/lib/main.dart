import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_theme.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/features/auth/data/auth_remote_datasource.dart';
import 'package:batwa_wallet/features/auth/data/auth_repository_impl.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_event.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_state.dart';
import 'package:batwa_wallet/features/wallet/data/wallet_remote_datasource.dart';
import 'package:batwa_wallet/features/wallet/data/wallet_repository_impl.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:batwa_wallet/features/qr/data/datasources/qr_remote_datasource.dart';
import 'package:batwa_wallet/features/qr/data/repositories/qr_repository_impl.dart';
import 'package:batwa_wallet/features/qr/presentation/bloc/qr_bloc.dart';
import 'package:batwa_wallet/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:batwa_wallet/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:batwa_wallet/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:batwa_wallet/features/merchant/data/datasources/merchant_remote_datasource.dart';
import 'package:batwa_wallet/features/merchant/data/repositories/merchant_repository_impl.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_bloc.dart';

import 'package:batwa_wallet/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:batwa_wallet/features/wallet/presentation/screens/main_3d_shell_screen.dart';
import 'package:batwa_wallet/core/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.initializeServerUrl();
  runApp(const BattwaaApp());
}

class BattwaaApp extends StatelessWidget {
  const BattwaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final authDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
    final authRepository = AuthRepositoryImpl(remoteDataSource: authDataSource);

    final walletDataSource = WalletRemoteDataSourceImpl(apiClient: apiClient);
    final walletRepository = WalletRepositoryImpl(remoteDataSource: walletDataSource);

    final qrDataSource = QrRemoteDataSourceImpl(apiClient: apiClient);
    final qrRepository = QrRepositoryImpl(remoteDataSource: qrDataSource);

    final analyticsDataSource = AnalyticsRemoteDataSourceImpl(apiClient: apiClient);
    final analyticsRepository = AnalyticsRepositoryImpl(remoteDataSource: analyticsDataSource);

    final merchantDataSource = MerchantRemoteDataSourceImpl(apiClient: apiClient);
    final merchantRepository = MerchantRepositoryImpl(remoteDataSource: merchantDataSource);

    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository: authRepository)..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<WalletBloc>(
          create: (_) => WalletBloc(walletRepository: walletRepository),
        ),
        BlocProvider<QrBloc>(
          create: (_) => QrBloc(qrRepository: qrRepository),
        ),
        BlocProvider<AnalyticsBloc>(
          create: (_) => AnalyticsBloc(analyticsRepository: analyticsRepository),
        ),
        BlocProvider<MerchantBloc>(
          create: (_) => MerchantBloc(merchantRepository: merchantRepository),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'BATWA',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated || state is PinSetSuccess) {
          return const Main3DShellScreen();
        }
        return const OnboardingScreen();
      },
    );
  }
}
