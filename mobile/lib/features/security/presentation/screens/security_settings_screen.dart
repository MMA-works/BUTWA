import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/services/biometric_service.dart';
import 'package:batwa_wallet/core/utils/currency_formatters.dart';
import '../../data/security_remote_datasource.dart';
import '../../data/security_repository_impl.dart';
import '../../domain/entities/security_audit_log_entity.dart';
import '../../domain/entities/security_settings_entity.dart';
import '../../domain/entities/user_session_entity.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';
import '../widgets/change_pin_dialog.dart';
import '../widgets/edit_limits_dialog.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SecurityBloc(
        repository: SecurityRepositoryImpl(
          remoteDataSource: SecurityRemoteDataSourceImpl(
            apiClient: ApiClient(),
          ),
        ),
      )..add(const FetchSecurityOverviewEvent()),
      child: const _SecuritySettingsContent(),
    );
  }
}

class _SecuritySettingsContent extends StatefulWidget {
  const _SecuritySettingsContent();

  @override
  State<_SecuritySettingsContent> createState() => _SecuritySettingsContentState();
}

class _SecuritySettingsContentState extends State<_SecuritySettingsContent> {
  bool _biometricsEnabled = true;

  void _openChangePinDialog(BuildContext context, {bool isReset = false}) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<SecurityBloc>(),
        child: ChangePinDialog(isReset: isReset),
      ),
    );
  }

  void _openEditLimitsDialog(BuildContext context, SecuritySettingsEntity settings) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<SecurityBloc>(),
        child: EditLimitsDialog(settings: settings),
      ),
    );
  }

  void _confirmRevokeOtherSessions(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
            SizedBox(width: 8),
            Text('Log Out Other Devices?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'This will immediately terminate all active sessions on any other phones, tablets, or web browsers except this one.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<SecurityBloc>().add(const RevokeOtherSessionsEvent());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Log Out Others', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
            ),
          ),
        ),
        title: const Text(
          'Security & Devices',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<SecurityBloc, SecurityState>(
        listener: (context, state) {
          if (state is SecurityActionSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is SecurityErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SecurityLoadingState) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          SecuritySettingsEntity? settings;
          List<UserSessionEntity> sessions = [];
          List<SecurityAuditLogEntity> logs = [];

          if (state is SecurityOverviewLoadedState) {
            settings = state.settings;
            sessions = state.sessions;
            logs = state.auditLogs;
          } else if (state is SecurityActionSuccessState) {
            settings = state.settings;
            sessions = state.sessions;
            logs = state.auditLogs;
          } else if (state is SecurityActionLoadingState) {
            settings = state.currentSettings;
            sessions = state.currentSessions ?? [];
            logs = state.currentLogs ?? [];
          } else if (state is SecurityErrorState) {
            settings = state.cachedSettings;
            sessions = state.cachedSessions ?? [];
            logs = state.cachedLogs ?? [];
          }

          if (settings == null) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () => context.read<SecurityBloc>().add(const FetchSecurityOverviewEvent()),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Loading Security Center'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              context.read<SecurityBloc>().add(const FetchSecurityOverviewEvent());
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // 1. Hero Shield Status Card (Matte Deep Obsidian)
                _buildHeroStatusCard(settings),
                const SizedBox(height: 20),

                // 2. Section: In-App MPIN & Authentication
                const Text('AUTHENTICATION & MPIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                _buildAuthSection(context, settings),
                const SizedBox(height: 20),

                // 3. Section: Spending Limits & Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TRANSACTION SPENDING LIMITS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => _openEditLimitsDialog(context, settings!),
                      child: const Text('Adjust Limits', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildLimitsSection(context, settings),
                const SizedBox(height: 20),

                // 4. Section: Active Devices & Sessions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('LOGGED-IN DEVICES & SESSIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: AppColors.textSecondary)),
                    if (sessions.length > 1)
                      GestureDetector(
                        onTap: () => _confirmRevokeOtherSessions(context),
                        child: const Text('Log Out Others', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.error)),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSessionsSection(context, sessions),
                const SizedBox(height: 20),

                // 5. Section: Security Activity Audit Log
                const Text('SECURITY ACTIVITY AUDIT TRAIL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                _buildAuditLogsSection(logs),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroStatusCard(SecuritySettingsEntity settings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded, color: AppColors.accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('System Status: ', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: settings.isAccountLocked ? AppColors.error.withOpacity(0.3) : AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        settings.isAccountLocked ? 'LOCKED' : 'SECURE & ACTIVE',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: settings.isAccountLocked ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Institutional cold-lock encryption & multi-device session protection enabled.',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthSection(BuildContext context, SecuritySettingsEntity settings) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.password_rounded, color: AppColors.primary, size: 18),
            ),
            title: const Text('Change Transaction MPIN', style: TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w800)),
            subtitle: const Text('Update 4-digit security code for transactions', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
            onTap: () => _openChangePinDialog(context, isReset: false),
          ),
          const Divider(color: AppColors.cardBorder, height: 1, indent: 56),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset_rounded, color: Color(0xFFD97706), size: 18),
            ),
            title: const Text('Reset Forgotten MPIN', style: TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w800)),
            subtitle: const Text('Reset PIN using your account password', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
            onTap: () => _openChangePinDialog(context, isReset: true),
          ),
          const Divider(color: AppColors.cardBorder, height: 1, indent: 56),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 18),
            ),
            title: const Text('Biometric Quick Unlock', style: TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w800)),
            subtitle: const Text('Fingerprint / Face ID for instant app login', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
            value: _biometricsEnabled,
            onChanged: (val) async {
              if (val) {
                final service = BiometricService();
                final result = await service.authenticate(
                  reason: 'Verify fingerprint or Face ID to enable Biometric Quick Unlock',
                );
                if (!mounted) return;
                if (result.success) {
                  setState(() => _biometricsEnabled = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Biometric login successfully enabled!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                setState(() => _biometricsEnabled = false);
              }
            },
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildLimitsSection(BuildContext context, SecuritySettingsEntity settings) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Daily Limit Row
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Spending Limit', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('Reset every midnight', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${CurrencyFormatters.formatPkr(settings.todaySpent)} / ${CurrencyFormatters.formatPkr(settings.dailySpendingLimit)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text('${settings.dailyUsagePercentage.toStringAsFixed(1)}% used', style: const TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (settings.dailyUsagePercentage / 100.0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                settings.dailyUsagePercentage > 85 ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 16),

          // Monthly Limit Row
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Spending Limit', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('Reset on 1st of each month', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${CurrencyFormatters.formatPkr(settings.monthSpent)} / ${CurrencyFormatters.formatPkr(settings.monthlySpendingLimit)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text('${settings.monthlyUsagePercentage.toStringAsFixed(1)}% used', style: const TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (settings.monthlyUsagePercentage / 100.0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                settings.monthlyUsagePercentage > 85 ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsSection(BuildContext context, List<UserSessionEntity> sessions) {
    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.cardBorder)),
        child: const Center(child: Text('No active devices found.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sessions.length,
        separatorBuilder: (_, __) => const Divider(color: AppColors.cardBorder, height: 1, indent: 56),
        itemBuilder: (context, index) {
          final s = sessions[index];
          final isPhone = s.deviceName.toLowerCase().contains('phone') || s.deviceName.toLowerCase().contains('infinix') || s.deviceName.toLowerCase().contains('android');

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: s.isCurrent ? AppColors.accent.withOpacity(0.2) : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPhone ? Icons.phone_android_rounded : Icons.laptop_mac_rounded,
                color: s.isCurrent ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Text(s.deviceName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w800)),
                const SizedBox(width: 6),
                if (s.isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(6)),
                    child: const Text('THIS DEVICE', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
            subtitle: Text(
              '${s.osVersion ?? 'Android'} • IP: ${s.ipAddress ?? '127.0.0.1'} • Active now',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w500),
            ),
            trailing: !s.isCurrent
                ? IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    onPressed: () => context.read<SecurityBloc>().add(RevokeSessionEvent(sessionId: s.id)),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildAuditLogsSection(List<SecurityAuditLogEntity> logs) {
    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.cardBorder)),
        child: const Center(child: Text('No security events recorded yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length > 5 ? 5 : logs.length,
        separatorBuilder: (_, __) => const Divider(color: AppColors.cardBorder, height: 1, indent: 56),
        itemBuilder: (context, index) {
          final log = logs[index];
          IconData icon;
          Color color;

          switch (log.eventType.toUpperCase()) {
            case 'LOGIN':
              icon = Icons.login_rounded;
              color = AppColors.primary;
              break;
            case 'PIN_CHANGED':
              icon = Icons.pin_rounded;
              color = const Color(0xFFD97706);
              break;
            case 'LIMITS_UPDATED':
              icon = Icons.tune_rounded;
              color = const Color(0xFF2563EB);
              break;
            case 'SESSION_REVOKED':
              icon = Icons.logout_rounded;
              color = AppColors.error;
              break;
            default:
              icon = Icons.security_rounded;
              color = AppColors.textSecondary;
          }

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            title: Text(log.description, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w700)),
            subtitle: Text(
              '${log.timestamp.day}/${log.timestamp.month}/${log.timestamp.year} ${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')} • ${log.deviceInfo ?? 'Mobile'}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w500),
            ),
          );
        },
      ),
    );
  }
}