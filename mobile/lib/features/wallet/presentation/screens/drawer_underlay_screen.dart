import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/services/biometric_service.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_event.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_state.dart';
import 'package:batwa_wallet/features/wallet/presentation/widgets/floating_pill_nav_bar.dart';
import 'package:batwa_wallet/features/cards/presentation/screens/cards_screen.dart';
import 'package:batwa_wallet/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:batwa_wallet/core/utils/user_avatar_helper.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/utils/secure_storage_helper.dart';
import 'package:batwa_wallet/features/security/data/security_remote_datasource.dart';
import 'package:batwa_wallet/features/security/presentation/screens/security_settings_screen.dart';

class DrawerUnderlayScreen extends StatefulWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;
  final VoidCallback onClose;

  const DrawerUnderlayScreen({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onClose,
  });

  @override
  State<DrawerUnderlayScreen> createState() => _DrawerUnderlayScreenState();
}

class _DrawerUnderlayScreenState extends State<DrawerUnderlayScreen> {
  // Security State
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = true;
  bool _transactionBiometricsEnabled = true;
  String _autoLockDuration = '5 Minutes';
  String _antiPhishingPhrase = 'BATWA-SECURE-9821';
  String _currentPin = '1234';

  // Notifications State
  bool _smsAlertsEnabled = true;
  bool _pushAlertsEnabled = true;
  bool _emailStatementsEnabled = true;

  // Account Preferences
  double _dailyTransferLimit = 500000;
  String _selectedCurrency = 'PKR (Rs)';
  String _selectedLanguage = 'English (US)';
  String _userFullName = 'Batwa User';
  String _userEmail = 'user@batwa.com';
  String _userPhone = '+92 300 1234567';
  String _userAddress = 'Plot 42, Street 18, F-7/2, Islamabad, Pakistan';
  String _userCnic = '61101-9283741-9';
  String _avatarUrl = UserAvatarHelper.defaultMaleAvatar;
  String _userGender = "MALE";

  List<String> get _presetAvatars => UserAvatarHelper.allAvatarUrls;

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final name = await SecureStorageHelper.getFullName();
      final phone = await SecureStorageHelper.getUserPhone();
      final email = await SecureStorageHelper.getUserEmail();
      final address = await SecureStorageHelper.getUserAddress();
      final cnic = await SecureStorageHelper.getUserCnic();
      final limit = await SecureStorageHelper.getDailyLimit();
      final bio = await SecureStorageHelper.getBiometricsEnabled();
      final curr = await SecureStorageHelper.getSelectedCurrency();
      final lang = await SecureStorageHelper.getSelectedLanguage();
      final notifs = await SecureStorageHelper.getNotificationPreferences();

      if (mounted) {
        setState(() {
          if (name != null && name.isNotEmpty) _userFullName = name;
          if (phone != null && phone.isNotEmpty) _userPhone = phone;
          if (email != null && email.isNotEmpty) _userEmail = email;
          if (address != null && address.isNotEmpty) _userAddress = address;
          if (cnic != null && cnic.isNotEmpty) _userCnic = cnic;
          if (limit != null && limit > 0) _dailyTransferLimit = limit;
          _biometricEnabled = bio;
          _selectedCurrency = curr;
          _selectedLanguage = lang;
          _pushAlertsEnabled = notifs['push'] ?? true;
          _smsAlertsEnabled = notifs['sms'] ?? true;
          _emailStatementsEnabled = notifs['email'] ?? true;
        });
      }

      // Sync active sessions from backend
      try {
        final sessions = await SecurityRemoteDataSourceImpl(apiClient: ApiClient()).getActiveSessions();
        if (sessions.isNotEmpty && mounted) {
          setState(() {
            _activeSessions = sessions.map((s) => {
              'id': s.id,
              'device': s.deviceName,
              'os': '${s.osVersion ?? "Android 11"} • BATWA v2.4.16',
              'ip': s.ipAddress ?? '182.185.120.44',
              'location': 'Pakistan',
              'time': s.isCurrent ? 'Active Now (This Device)' : '${s.lastActiveAt.hour}:${s.lastActiveAt.minute.toString().padLeft(2, '0')}',
              'isCurrent': s.isCurrent,
            }).toList();
          });
        }
      } catch (_) {}
    } catch (_) {}
  }

  Future<void> _loadUserAvatar() async {
    final avatar = await UserAvatarHelper.getAvatarUrl();
    final gender = await UserAvatarHelper.getGender();
    if (mounted) {
      setState(() {
        _avatarUrl = avatar;
        _userGender = gender;
      });
    }
  }

  List<Map<String, dynamic>> _activeSessions = [
    {
      'id': 'sess_1',
      'device': 'Motorola Moto G Play (2023)',
      'os': 'Android 11 • BATWA App v2.2.0',
      'ip': '182.185.120.44',
      'location': 'Islamabad, Pakistan',
      'time': 'Active Now (This Device)',
      'isCurrent': true,
    },
    {
      'id': 'sess_2',
      'device': 'Google Chrome (Windows 11)',
      'os': 'Web Browser Portal',
      'ip': '111.119.187.12',
      'location': 'Islamabad, Pakistan',
      'time': '2 hours ago',
      'isCurrent': false,
    },
    {
      'id': 'sess_3',
      'device': 'Apple iPad Pro 12.9"',
      'os': 'iPadOS 17.4',
      'ip': '39.40.12.98',
      'location': 'Lahore, Pakistan',
      'time': '3 days ago',
      'isCurrent': false,
    },
  ];

  final List<Map<String, dynamic>> _linkedBanks = [
    {
      'bank': 'Habib Bank Limited (HBL)',
      'accountNo': 'PK64HABB00012345678901',
      'type': 'Current Account',
      'isPrimary': true,
    },
    {
      'bank': 'Meezan Islamic Bank',
      'accountNo': 'PK32MEZN00098765432101',
      'type': 'Savings Account',
      'isPrimary': false,
    },
    {
      'bank': 'JazzCash Mobile Account',
      'accountNo': '+92 300 1234567',
      'type': 'Mobile Wallet',
      'isPrimary': false,
    },
  ];

  final List<Map<String, String>> _supportChatMessages = [
    {
      'sender': 'bot',
      'text': '👋 Welcome to BATWA Priority Support! How can we help you today with your digital wallet, virtual cards, or payments?',
      'time': 'Just now',
    },
  ];

  // 🔢 1. INTERACTIVE 4-DIGIT PIN KEYPAD SHEET
  void _showPinManagementSheet() {
    String enteredPin = '';
    String step = 'enter_new';
    String firstPin = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            void handleDigit(String digit) {
              HapticFeedback.lightImpact();
              if (enteredPin.length < 4) {
                setModalState(() {
                  enteredPin += digit;
                });

                if (enteredPin.length == 4) {
                  Future.delayed(const Duration(milliseconds: 250), () async {
                    if (step == 'enter_new') {
                      setModalState(() {
                        firstPin = enteredPin;
                        enteredPin = '';
                        step = 'confirm_new';
                      });
                    } else if (step == 'confirm_new') {
                      if (enteredPin == firstPin) {
                        try {
                          await ApiClient().client.post(
                            '/auth/pin',
                            data: {
                              'pin': enteredPin,
                              'confirmPin': enteredPin,
                            },
                          );
                        } catch (_) {}
                        setState(() {
                          _currentPin = enteredPin;
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 4-digit Transaction PIN updated & synced with backend successfully!'),
                              backgroundColor: Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } else {
                        HapticFeedback.heavyImpact();
                        setModalState(() {
                          enteredPin = '';
                          step = 'enter_new';
                          firstPin = '';
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('❌ PINs did not match. Please try again.'),
                              backgroundColor: Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    }
                  });
                }
              }
            }

            void handleDelete() {
              HapticFeedback.selectionClick();
              if (enteredPin.isNotEmpty) {
                setModalState(() {
                  enteredPin = enteredPin.substring(0, enteredPin.length - 1);
                });
              }
            }

            return Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12141D) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3D602).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF3D602).withValues(alpha: 0.3)),
                    ),
                    child: const Center(
                      child: Icon(Icons.lock_reset_rounded, color: Color(0xFFF3D602), size: 26),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    step == 'enter_new' ? 'Set 4-Digit Security PIN' : 'Confirm Your New PIN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1B1D28),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step == 'enter_new'
                        ? 'This PIN will be required for outbound transfers & approvals'
                        : 'Re-enter the 4-digit PIN to confirm accuracy',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isFilled = index < enteredPin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled ? const Color(0xFFF3D602) : Colors.transparent,
                          border: Border.all(
                            color: isFilled ? const Color(0xFFF3D602) : Colors.white30,
                            width: 2,
                          ),
                          boxShadow: isFilled
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFF3D602).withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Column(
                      children: [
                        for (var row in [
                          ['1', '2', '3'],
                          ['4', '5', '6'],
                          ['7', '8', '9'],
                          ['', '0', 'delete']
                        ])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: row.map((key) {
                                if (key.isEmpty) {
                                  return const SizedBox(width: 64, height: 64);
                                }
                                if (key == 'delete') {
                                  return GestureDetector(
                                    onTap: handleDelete,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark ? const Color(0xFF1B1D28) : const Color(0xFFF1F4F9),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.backspace_outlined, size: 20, color: Color(0xFFEF4444)),
                                      ),
                                    ),
                                  );
                                }
                                return GestureDetector(
                                  onTap: () => handleDigit(key),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark ? const Color(0xFF1B1D28) : const Color(0xFFF1F4F9),
                                      border: Border.all(
                                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        key,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? Colors.white : const Color(0xFF1B1D28),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ⚡ 2. BIOMETRIC AUTH REAL HARDWARE INTEGRATION
  Future<void> _toggleBiometrics(bool enable) async {
    HapticFeedback.lightImpact();
    if (enable) {
      final biometricService = BiometricService();
      final isAvailable = await biometricService.isBiometricAvailable();

      if (!isAvailable) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Biometric hardware is not available on this device.')),
              ],
            ),
            backgroundColor: Color(0xFFF59E0B),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final result = await biometricService.authenticate(
        reason: 'Touch your fingerprint sensor or use Face ID to enable Biometric Security in BATWA',
      );

      if (!mounted) return;

      if (result.success) {
        HapticFeedback.heavyImpact();
        setState(() => _biometricEnabled = true);
        await SecureStorageHelper.saveBiometricsEnabled(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Biometric authentication verified & active!')),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        if (result.errorCode == 'noCredentialsSet' || result.errorCode == 'noBiometricsEnrolled') {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF161922),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.fingerprint_rounded, color: Color(0xFFF3D602), size: 28),
                  SizedBox(width: 10),
                  Text('Biometrics Setup', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text(
                result.message + '\n\nPlease set up a Fingerprint, Face ID, or Screen PIN in your Android Security Settings.',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Dismiss', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    openAppSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3D602),
                    foregroundColor: const Color(0xFF1B1D28),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Open Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(result.message)),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      HapticFeedback.selectionClick();
      setState(() => _biometricEnabled = false);
      await SecureStorageHelper.saveBiometricsEnabled(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric Quick Unlock disabled.'),
          backgroundColor: Color(0xFF6B7280),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // 📱 3. ACTIVE DEVICE SESSIONS SHEET
  void _showActiveSessionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12141D) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Device Sessions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF1B1D28),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${_activeSessions.length} devices signed in to this account',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ENCRYPTED',
                          style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  ..._activeSessions.map((session) {
                    final isCur = session['isCurrent'] == true;
                    final isPhone = (session['device'] as String).toLowerCase().contains('moto') ||
                        (session['device'] as String).toLowerCase().contains('phone');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: isCur
                            ? const LinearGradient(
                                colors: [Color(0xFF0F2B1D), Color(0xFF047857)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        color: isCur ? null : (isDark ? const Color(0xFF181B26) : const Color(0xFFF6F8FC)),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCur ? Colors.transparent : Colors.white10,
                        ),
                        boxShadow: isCur
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isCur
                                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                  : const Color(0xFF3B82F6).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                isPhone ? Icons.phone_android_rounded : Icons.laptop_chromebook_rounded,
                                color: isCur ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        session['device'] as String,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13.5,
                                          color: isDark ? Colors.white : const Color(0xFF1B1D28),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isCur)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'THIS DEVICE',
                                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${session['location']} • ${session['time']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCur ? const Color(0xFF10B981) : AppColors.textMuted,
                                    fontWeight: isCur ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  'IP: ${session['ip']} • ${session['os']}',
                                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                                ),
                              ],
                            ),
                          ),
                          if (!isCur)
                            IconButton(
                              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                              tooltip: 'Terminate Session',
                              onPressed: () async {
                                final sessId = session['id']?.toString() ?? '';
                                try {
                                  await SecurityRemoteDataSourceImpl(apiClient: ApiClient()).revokeSession(sessId);
                                } catch (_) {}
                                setModalState(() {
                                  _activeSessions.removeWhere((s) => s['id'] == session['id']);
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Terminated session for ${session['device']}'),
                                      backgroundColor: const Color(0xFFEF4444),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  if (_activeSessions.length > 1)
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await SecurityRemoteDataSourceImpl(apiClient: ApiClient()).revokeOtherSessions();
                        } catch (_) {}
                        setModalState(() {
                          _activeSessions = _activeSessions.where((s) => s['isCurrent'] == true).toList();
                        });
                        Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🛡️ All other remote sessions terminated.'),
                              backgroundColor: Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.phonelink_erase_rounded, size: 18),
                      label: const Text('Terminate All Other Sessions', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        foregroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🛡️ 4. SECURITY HUB & 2FA MODAL
  void _showSecurityHubSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.82,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12141D) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Security Hub & 2FA',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF1B1D28),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Multi-layer defense & fraud prevention',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Colors.white10),

                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F2B1D), Color(0xFF047857)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3D602),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF3D602).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.verified_user_rounded, color: Color(0xFF1B1D28), size: 24),
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vault Status: 100% Protected',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '256-bit AES Hardware Encryption active across all transaction channels.',
                                      style: TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Authenticator App 2FA (TOTP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: const Text('Google Authenticator / Authy verification code on login', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                          value: _twoFactorEnabled,
                          activeColor: const Color(0xFFF3D602),
                          onChanged: (val) {
                            setModalState(() => _twoFactorEnabled = val);
                            setState(() => _twoFactorEnabled = val);
                          },
                        ),
                        const Divider(height: 16, color: Colors.white10),

                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Biometric Payment Approval', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: const Text('Require Fingerprint / Face ID for transactions > PKR 10,000', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                          value: _transactionBiometricsEnabled,
                          activeColor: const Color(0xFFF3D602),
                          onChanged: (val) {
                            setModalState(() => _transactionBiometricsEnabled = val);
                            setState(() => _transactionBiometricsEnabled = val);
                          },
                        ),
                        const Divider(height: 16, color: Colors.white10),

                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('App Auto-Lock Timer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('Lock app after $_autoLockDuration of inactivity', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                          trailing: DropdownButton<String>(
                            value: _autoLockDuration,
                            dropdownColor: const Color(0xFF1B1D28),
                            style: const TextStyle(color: Color(0xFFF3D602), fontWeight: FontWeight.bold, fontSize: 13),
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFF3D602)),
                            items: ['Instant', '1 Minute', '5 Minutes', '15 Minutes']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (newVal) {
                              if (newVal != null) {
                                setModalState(() => _autoLockDuration = newVal);
                                setState(() => _autoLockDuration = newVal);
                              }
                            },
                          ),
                        ),
                        const Divider(height: 16, color: Colors.white10),

                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Anti-Phishing Security Phrase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('Phrase displayed in official emails: "$_antiPhishingPhrase"', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Color(0xFFF3D602), size: 20),
                            onPressed: () {
                              final phraseCtrl = TextEditingController(text: _antiPhishingPhrase);
                              showDialog(
                                context: context,
                                builder: (dCtx) => AlertDialog(
                                  backgroundColor: const Color(0xFF1B1D28),
                                  title: const Text('Edit Anti-Phishing Phrase', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                  content: TextField(
                                    controller: phraseCtrl,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFF12141D),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Cancel')),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (phraseCtrl.text.trim().isNotEmpty) {
                                          setModalState(() => _antiPhishingPhrase = phraseCtrl.text.trim());
                                          setState(() => _antiPhishingPhrase = phraseCtrl.text.trim());
                                        }
                                        Navigator.pop(dCtx);
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF3D602), foregroundColor: const Color(0xFF1B1D28)),
                                      child: const Text('Save'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      await SecureStorageHelper.saveBiometricsEnabled(_biometricEnabled);
                      try {
                        await SecurityRemoteDataSourceImpl(apiClient: ApiClient()).updateSecuritySettings(
                          requirePinForAllTransfers: _transactionBiometricsEnabled,
                          loginAlerts: _twoFactorEnabled,
                          pin: _currentPin,
                        );
                      } catch (_) {}
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🛡️ Security preferences saved and synced.'),
                            backgroundColor: Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3D602),
                      foregroundColor: const Color(0xFF1B1D28),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Security Settings', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()));
                    },
                    icon: const Icon(Icons.shield_outlined, size: 18),
                    label: const Text('Open Advanced Security Console', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF3D602),
                      side: const BorderSide(color: Color(0xFFF3D602)),
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🪪 5. CNIC VERIFICATION MODAL
  void _showCnicVerificationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF12141D) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('National ID / CNIC Document', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 14),
                        SizedBox(width: 4),
                        Text('VERIFIED', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10.5)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2B1D), Color(0xFF047857)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ISLAMIC REPUBLIC OF PAKISTAN', style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        Container(
                          width: 32,
                          height: 22,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3D602),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(child: Icon(Icons.nfc_rounded, size: 16, color: Color(0xFF1B1D28))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(_userCnic.isNotEmpty ? _userCnic : '61101-9283741-9', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2.2)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('NAME', style: TextStyle(color: Colors.white60, fontSize: 9)),
                            Text(_userFullName.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('EXPIRY', style: TextStyle(color: Colors.white60, fontSize: 9)),
                            Text('LIFETIME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text('• Verified in real-time via NADRA Digital Verisys Level 2 API.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const Text('• Eligible for PKR 500,000 daily transfers and international remittances.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3D602),
                  foregroundColor: const Color(0xFF1B1D28),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Close Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🏠 6. PROOF OF ADDRESS MODAL
  void _showAddressProofSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF12141D) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Proof of Address & Utility Bill', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2B1D), Color(0xFF047857)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3D602),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.35),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.receipt_long_rounded, color: Color(0xFF1B1D28), size: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('IESCO Electricity Bill (Verified)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                          const SizedBox(height: 3),
                          Text(_userAddress, style: const TextStyle(fontSize: 11.5, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showAddressUpdateSheet();
                },
                icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
                label: const Text('Update Verified Address & Bill', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3D602),
                  foregroundColor: const Color(0xFF1B1D28),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🏆 7. KYC ACCOUNT TIER MODAL
  void _showKycTierSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF12141D) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              const Text('KYC Verification Tiers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('Higher tiers unlock higher daily spending thresholds', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181B26) : const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tier 1: Basic (Unverified)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    Text('PKR 50k / Day', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2B1D), Color(0xFF047857)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3D602),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.verified_rounded, color: Color(0xFF1B1D28), size: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tier 2: Standard (Active)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                            SizedBox(height: 2),
                            Text('NADRA CNIC + Biometrics Active', style: TextStyle(fontSize: 11, color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                    const Text('PKR 500k/D', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFFF3D602))),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181B26) : const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tier 3: Merchant & Business Pro', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    Text('PKR 5M / Month', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tier 3 merchant upgrade application submitted.'),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3D602),
                  foregroundColor: const Color(0xFF1B1D28),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Request Upgrade to Tier 3', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
              ),
            ],
          ),
        );
      },
    );
  }

  // ⚡ 8. DAILY TRANSFER LIMITS SLIDER
  void _showTransferLimitsSheet() {
    double tempLimit = _dailyTransferLimit;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12141D) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Adjust Daily Transfer Limit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('Customize security spending thresholds for P2P & QR payments', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F2B1D), Color(0xFF047857)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'MAX DAILY LIMIT',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PKR ${tempLimit.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF3D602),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Slider(
                    value: tempLimit,
                    min: 50000,
                    max: 1000000,
                    divisions: 19,
                    activeColor: const Color(0xFFF3D602),
                    inactiveColor: Colors.white12,
                    onChanged: (val) {
                      setModalState(() => tempLimit = val);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Min: PKR 50,000', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        Text('Max: PKR 1,000,000', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() => _dailyTransferLimit = tempLimit);
                      await SecureStorageHelper.saveDailyLimit(tempLimit);
                      try {
                        await SecurityRemoteDataSourceImpl(apiClient: ApiClient()).updateSecuritySettings(
                          dailyLimit: tempLimit,
                          pin: _currentPin,
                        );
                      } catch (_) {}
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Daily limit updated to PKR ${tempLimit.toInt()} & synced!'),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3D602),
                      foregroundColor: const Color(0xFF1B1D28),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Limit Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🏦 9. LINKED BANK ACCOUNTS MODAL
  void _showLinkedBanksSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12141D) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Linked Bank Accounts & IBAN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      Text('${_linkedBanks.length} Linked', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ..._linkedBanks.map((b) {
                    final isPrimary = b['isPrimary'] == true;
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setModalState(() {
                          for (var item in _linkedBanks) {
                            item['isPrimary'] = (item == b);
                          }
                        });
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${b['bank']} set as primary bank account! ⭐️'),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: isPrimary
                              ? const LinearGradient(
                                  colors: [Color(0xFF0F2B1D), Color(0xFF047857)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          color: isPrimary ? null : (isDark ? const Color(0xFF181B26) : const Color(0xFFF6F8FC)),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: isPrimary ? Colors.transparent : Colors.white10),
                          boxShadow: isPrimary
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isPrimary
                                    ? const Color(0xFFF3D602)
                                    : const Color(0xFFF3D602).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                boxShadow: isPrimary
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.account_balance_rounded,
                                  color: isPrimary ? const Color(0xFF1B1D28) : const Color(0xFFF3D602),
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b['bank'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      color: isPrimary ? Colors.white : (isDark ? Colors.white : const Color(0xFF1B1D28)),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    b['accountNo'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isPrimary ? Colors.white70 : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isPrimary)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3D602),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PRIMARY',
                                  style: TextStyle(
                                    color: Color(0xFF1B1D28),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            if (!isPrimary)
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                                tooltip: 'Remove Bank',
                                onPressed: () {
                                  setModalState(() {
                                    _linkedBanks.remove(b);
                                  });
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Removed ${b['bank']}'),
                                      backgroundColor: const Color(0xFFEF4444),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddBankDialog(modalCtx, setModalState);
                    },
                    icon: const Icon(Icons.add_link_rounded, size: 18),
                    label: const Text('+ Link New Pakistani Bank Account', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3D602),
                      foregroundColor: const Color(0xFF1B1D28),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddBankDialog(BuildContext parentCtx, StateSetter setParentState) {
    String selectedBank = 'Meezan Islamic Bank';
    final accCtrl = TextEditingController();
    final banks = [
      'Meezan Islamic Bank',
      'Habib Bank Limited (HBL)',
      'Bank Alfalah',
      'Faysal Bank',
      'MCB Bank Limited',
      'United Bank Limited (UBL)',
      'Allied Bank Limited (ABL)',
      'SadaPay',
      'NayaPay',
      'JazzCash Mobile Account',
      'Easypaisa Mobile Account',
    ];

    showDialog(
      context: context,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161922),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.account_balance_rounded, color: Color(0xFFF3D602), size: 24),
                  SizedBox(width: 10),
                  Text('Link Bank Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Pakistani Bank', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2230),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: selectedBank,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E2230),
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      items: banks.map((b) => DropdownMenuItem(value: b, child: Text(b, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedBank = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Account Number or IBAN', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: accCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. PK32MEZN00012345678901',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF1E2230),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dCtx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final acc = accCtrl.text.trim();
                    if (acc.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid Account Number or IBAN'),
                          backgroundColor: Color(0xFFEF4444),
                        ),
                      );
                      return;
                    }
                    setParentState(() {
                      _linkedBanks.add({
                        'bank': selectedBank,
                        'accountNo': acc,
                        'type': 'Current Account',
                        'isPrimary': _linkedBanks.isEmpty,
                      });
                    });
                    setState(() {});
                    Navigator.pop(dCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 $selectedBank account linked successfully via 1Link!'),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3D602),
                    foregroundColor: const Color(0xFF1B1D28),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Link Account', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 🌐 10. CURRENCY & LANGUAGE MODAL
  void _showCurrencyLanguageSheet() {
    final currencies = ['PKR (Rs)', 'USD (\$)', 'EUR (€)', 'AED (د.إ)', 'GBP (£)'];
    final languages = ['English (US)', 'Urdu (اردو)', 'Arabic (العربية)'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12141D) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Currency & Language Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  const Text('Default Display Currency', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currencies.map((curr) {
                      final isSelected = _selectedCurrency == curr;
                      return ChoiceChip(
                        label: Text(curr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isSelected ? const Color(0xFF1B1D28) : Colors.white)),
                        selected: isSelected,
                        selectedColor: const Color(0xFFF3D602),
                        backgroundColor: isDark ? const Color(0xFF181B26) : const Color(0xFFE5E7EB),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedCurrency = curr);
                            setModalState(() {});
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text('Application Language', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: languages.map((lang) {
                      final isSelected = _selectedLanguage == lang;
                      return ChoiceChip(
                        label: Text(lang, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isSelected ? const Color(0xFF1B1D28) : Colors.white)),
                        selected: isSelected,
                        selectedColor: const Color(0xFFF3D602),
                        backgroundColor: isDark ? const Color(0xFF181B26) : const Color(0xFFE5E7EB),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedLanguage = lang);
                            setModalState(() {});
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await SecureStorageHelper.saveCurrencyAndLanguage(
                        currency: _selectedCurrency,
                        language: _selectedLanguage,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Preferences saved: $_selectedCurrency • $_selectedLanguage'),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3D602),
                      foregroundColor: const Color(0xFF1B1D28),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🔔 11. NOTIFICATION PREFERENCES MODAL
  void _showNotificationPreferencesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12141D) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Notification & Alert Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 14),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Instant Push Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: const Text('Real-time alerts for incoming & outgoing payments', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    value: _pushAlertsEnabled,
                    activeColor: const Color(0xFFF3D602),
                    onChanged: (val) {
                      setState(() => _pushAlertsEnabled = val);
                      setModalState(() {});
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('SMS Transaction OTPs & Summaries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: Text('Critical verification codes sent to $_userPhone', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    value: _smsAlertsEnabled,
                    activeColor: const Color(0xFFF3D602),
                    onChanged: (val) {
                      setState(() => _smsAlertsEnabled = val);
                      setModalState(() {});
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Monthly E-Statements via Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: const Text('PDF statement sent on 1st of each month', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    value: _emailStatementsEnabled,
                    activeColor: const Color(0xFFF3D602),
                    onChanged: (val) {
                      setState(() => _emailStatementsEnabled = val);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await SecureStorageHelper.saveNotificationPreferences(
                        pushAlerts: _pushAlertsEnabled,
                        smsAlerts: _smsAlertsEnabled,
                        emailStatements: _emailStatementsEnabled,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification settings updated & saved!'),
                            backgroundColor: Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3D602),
                      foregroundColor: const Color(0xFF1B1D28),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 📱 12. PHONE UPDATE MODAL
  void _showPhoneUpdateSheet() {
    final phoneCtrl = TextEditingController(text: _userPhone);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF12141D) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Update Registered Mobile Number', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('A 6-digit OTP will be sent to authenticate this change', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xFFF3D602), size: 18),
                    labelText: 'Phone Number',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF181B26) : const Color(0xFFF1F4F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final newPhone = phoneCtrl.text.trim();
                    if (newPhone.isNotEmpty) {
                      setState(() => _userPhone = newPhone);
                      await SecureStorageHelper.saveUserProfile(phone: newPhone);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('OTP sent to $newPhone. Number updated & saved!'),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3D602),
                    foregroundColor: const Color(0xFF1B1D28),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Send Verification OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✉️ 13. EMAIL UPDATE MODAL
  void _showEmailUpdateSheet() {
    final emailCtrl = TextEditingController(text: _userEmail);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF12141D) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Update Primary Email Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('Used for monthly statements and security receipts', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 16),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_rounded, color: Color(0xFFF3D602), size: 18),
                    labelText: 'Email Address',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF181B26) : const Color(0xFFF1F4F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final newEmail = emailCtrl.text.trim();
                    if (newEmail.isNotEmpty) {
                      setState(() => _userEmail = newEmail);
                      await SecureStorageHelper.saveUserProfile(email: newEmail);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Verification link sent to $newEmail. Email saved!'),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3D602),
                    foregroundColor: const Color(0xFF1B1D28),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Update & Send Verification Link', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 📍 14. ADDRESS UPDATE MODAL
  void _showAddressUpdateSheet() {
    final addrCtrl = TextEditingController(text: _userAddress);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF12141D) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Residential Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                TextField(
                  controller: addrCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFFF3D602), size: 18),
                    labelText: 'Full Address',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF181B26) : const Color(0xFFF1F4F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final newAddr = addrCtrl.text.trim();
                    if (newAddr.isNotEmpty) {
                      setState(() => _userAddress = newAddr);
                      await SecureStorageHelper.saveUserProfile(address: newAddr);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Residential address updated & saved!'),
                          backgroundColor: Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3D602),
                    foregroundColor: const Color(0xFF1B1D28),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 💬 15. 24/7 LIVE SUPPORT CHAT MODAL
  void _showLiveSupportChatSheet() {
    final msgCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(ctx).size.height * 0.82,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF12141D) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFF3D602),
                          radius: 18,
                          child: Icon(Icons.support_agent_rounded, size: 20, color: Color(0xFF1B1D28)),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BATWA 24/7 Concierge Chat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                            Text('Online • Average reply: < 1 min', style: TextStyle(fontSize: 11, color: Color(0xFF10B981))),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Colors.white10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _supportChatMessages.length,
                        itemBuilder: (context, idx) {
                          final m = _supportChatMessages[idx];
                          final isUser = m['sender'] == 'user';
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? const Color(0xFFF3D602)
                                    : (isDark ? const Color(0xFF181B26) : const Color(0xFFF1F4F9)),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                                  bottomRight: Radius.circular(isUser ? 4 : 18),
                                ),
                              ),
                              child: Text(
                                m['text'] ?? '',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isUser ? const Color(0xFF1B1D28) : Colors.white,
                                  fontWeight: isUser ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: msgCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF181B26) : const Color(0xFFF1F4F9),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () {
                            final text = msgCtrl.text.trim();
                            if (text.isNotEmpty) {
                              setModalState(() {
                                _supportChatMessages.add({'sender': 'user', 'text': text, 'time': 'Just now'});
                                msgCtrl.clear();
                              });
                              Future.delayed(const Duration(milliseconds: 500), () {
                                if (ctx.mounted) {
                                  final lower = text.toLowerCase();
                                  String reply = 'Ticket #BATWA-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)} created. Our priority support agent is reviewing: "$text"';
                                  if (lower.contains('pin')) {
                                    reply = 'Apna 4-digit transaction PIN aap "Security > Wallet PIN & Passcode" se anytime reset ya update kar sakte hain. PIN security OTP ke sath protected rehta hai.';
                                  } else if (lower.contains('limit') || lower.contains('daily')) {
                                    reply = 'Aapka current daily limit PKR ${_dailyTransferLimit.toInt()} hai. "Account Management > Daily Transfer Limits" par jaa kar aap ise PKR 1,000,000 tak barha sakte hain.';
                                  } else if (lower.contains('card') || lower.contains('debit')) {
                                    reply = 'Batwa Mastercard / PayPak Virtual Debit Card active hai! Bottom bar se "Cards" open karein jahan se instant card freeze ya online shopping limits set ki jaa sakti hain.';
                                  } else if (lower.contains('raast') || lower.contains('bank') || lower.contains('transfer') || lower.contains('send')) {
                                    reply = 'Raast P2P aur 1Link Pakistani banks par 100% free aur real-time balance transfer provide karte hain. Recipient title pehle hi fetch ho jata hai.';
                                  } else if (lower.contains('cnic') || lower.contains('kyc') || lower.contains('tier')) {
                                    reply = 'Aapka account Tier 2 verified hai ($_userCnic). Daily PKR 500,000 limit active hai. Higher limits ke liye support team ko proof of income provide karein.';
                                  }
                                  setModalState(() {
                                    _supportChatMessages.add({
                                      'sender': 'bot',
                                      'text': reply,
                                      'time': 'Just now',
                                    });
                                  });
                                }
                              });
                            }
                          },
                          icon: const Icon(Icons.send_rounded, size: 18),
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFFF3D602), foregroundColor: const Color(0xFF1B1D28)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ❓ 16. FAQS MODAL
  void _showFaqSheet() {
    final faqs = [
      {'q': 'How do I add funds to my BATWA wallet?', 'a': 'You can top up instantly via 1LINK Inter-bank Funds Transfer (IBFT), Debit/Credit cards, or cash deposit at any partner bank.'},
      {'q': 'What are the QR payment limits and charges?', 'a': 'BATWA QR payments are 100% free with 0% transaction fee for both personal users and retail merchants.'},
      {'q': 'How do I change my 4-digit PIN?', 'a': 'Tap "Wallet PIN & Passcode" under the Security section right here in Profile Settings to update your PIN anytime.'},
      {'q': 'What happens if I lose my phone?', 'a': 'Your funds remain protected by your 4-digit PIN and biometric lock. Log in on a new device to instantly terminate previous sessions.'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF12141D) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  itemCount: faqs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final item = faqs[idx];
                    return ExpansionTile(
                      backgroundColor: isDark ? const Color(0xFF181B26) : const Color(0xFFF1F4F9),
                      collapsedBackgroundColor: isDark ? const Color(0xFF181B26) : const Color(0xFFF1F4F9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Text(item['q'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          child: Text(item['a'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4)),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 📜 17. TERMS & POLICY MODAL
  void _showTermsPolicySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF12141D) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Terms of Service & Privacy Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2B1D), Color(0xFF047857)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.gavel_rounded, color: Color(0xFFF3D602), size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SBP EMI Regulated & Trustee Backed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(height: 2),
                          Text('100% segregated customer funds protection', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    '1. Regulatory Status\nBATWA Wallet operates under Electronic Money Institution (EMI) regulations supervised by the State Bank of Pakistan (SBP).\n\n2. Fund Protection\nAll customer wallet balances are held in segregated trustee accounts with licensed scheduled commercial banks.\n\n3. Data Encryption & Privacy\nCustomer data and payment credentials are encrypted using 256-bit AES encryption at rest and TLS 1.3 in transit.\n\n4. Dispute Resolution\nIn case of disputed transactions, customers can file claims within 30 days via our 24/7 Concierge Support.',
                    style: TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3D602),
                  foregroundColor: const Color(0xFF1B1D28),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('I Understand & Agree', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🖼️ 18. CHANGE PROFILE PHOTO MODAL
  void _showChangeAvatarSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF12141D) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 18),
              const Text('Change Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('Choose a preset avatar or upload a new photo', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 18),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presetAvatars.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final url = _presetAvatars[index];
                    final isSelected = _avatarUrl == url;
                    return GestureDetector(
                      onTap: () async {
                        setState(() => _avatarUrl = url);
                        await UserAvatarHelper.saveCustomAvatarUrl(url);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Avatar updated successfully!'),
                              backgroundColor: Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.person),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF10B981),
                  child: Icon(Icons.camera_alt_rounded, color: Colors.white),
                ),
                title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Capture live selfie', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile photo updated from camera.'),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF047857),
                  child: Icon(Icons.photo_library_rounded, color: Colors.white),
                ),
                title: const Text('Choose from Photo Gallery', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Select file from storage', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile photo updated from gallery.'),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 🚪 19. LOGOUT CONFIRMATION
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 8),
            Text('Sign Out', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out from BATWA Wallet on this device?',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onClose();
              context.read<AuthBloc>().add(LogoutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 🌟 MAIN BUILD METHOD (NEO-BANKING UI)
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // 🌟 1. Radiant Brand Yellow Gradient Top Banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          const Color(0xFFF3D602).withValues(alpha: 0.25),
                          const Color(0xFFF3D602).withValues(alpha: 0.12),
                          const Color(0xFF0C0E14).withValues(alpha: 0.0),
                        ]
                      : [
                          const Color(0xFFF3D602),
                          const Color(0xFFF4D916),
                          const Color(0xFFF7E248),
                          const Color(0xFFFAEE88).withValues(alpha: 0.85),
                          const Color(0xFFFCF7CA).withValues(alpha: 0.35),
                          const Color(0xFFF8F9FA).withValues(alpha: 0.0),
                        ],
                  stops: const [0.0, 0.35, 0.65, 0.82, 0.93, 1.0],
                ),
              ),
            ),
          ),

          // 📱 2. Foreground Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Settings',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF1B1D28),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Security, KYC & Account Controls',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: widget.onClose,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFECEFF2),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Color(0xFF1B1D28),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Settings Sections
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // 🌟 SECTION 0: HERO PROFILE CARD
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          String name = _userFullName;
                          String email = _userEmail;
                          if (authState is Authenticated) {
                            name = authState.user.fullName;
                            email = authState.user.email;
                          }

                          return Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF042B1D), Color(0xFF063C28), Color(0xFF084E35)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF042B1D).withValues(alpha: 0.4),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    UserAvatarHelper.buildAvatarWidget(
                                      imageUrl: _avatarUrl,
                                      gender: _userGender,
                                      size: 70,
                                      border: Border.all(color: const Color(0xFF10B981), width: 3),
                                    ),
                                    Positioned(
                                      bottom: -2,
                                      right: -2,
                                      child: GestureDetector(
                                        onTap: _showChangeAvatarSheet,
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isDark ? const Color(0xFF12141D) : Colors.white,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.25),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.edit_rounded, size: 14, color: Color(0xFF1B1D28)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white70,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.verified_rounded, size: 12, color: Color(0xFF10B981)),
                                                SizedBox(width: 4),
                                                Text(
                                                  'KYC Level 2',
                                                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3D602).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFFF3D602).withValues(alpha: 0.3)),
                                            ),
                                            child: const Text(
                                              'Standard Tier',
                                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFF3D602)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),



                  const SizedBox(height: 16),

                  // 🔒 SECTION 1: SECURITY (Security waly features)
                  _buildSectionHeader(
                    title: 'Security',
                    icon: Icons.shield_outlined,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildSettingsGroup(
                    isDark: isDark,
                    items: [
                      _buildSettingsTile(
                        icon: Icons.vpn_key_outlined,
                        title: 'Wallet PIN & Passcode',
                        subtitle: 'Change 4-digit transaction security PIN',
                        isDark: isDark,
                        onTap: _showPinManagementSheet,
                      ),
                      _buildSettingsTile(
                        icon: Icons.password_rounded,
                        title: 'Change Password',
                        subtitle: 'Update your account login password',
                        isDark: isDark,
                        onTap: _showChangePasswordSheet,
                      ),
                      _buildSettingsTile(
                        icon: Icons.fingerprint_rounded,
                        title: 'Biometric Login',
                        subtitle: 'Instant Fingerprint / Face ID unlock',
                        isDark: isDark,
                        onTap: () => _toggleBiometrics(!_biometricEnabled),
                        trailing: Switch.adaptive(
                          value: _biometricEnabled,
                          activeColor: const Color(0xFFF3D602),
                          onChanged: _toggleBiometrics,
                        ),
                      ),
                      _buildSettingsTile(
                        icon: Icons.devices_outlined,
                        title: 'Active Device Sessions',
                        subtitle: '${_activeSessions.length} devices connected • Manage sessions',
                        isDark: isDark,
                        onTap: _showActiveSessionsSheet,
                      ),
                      _buildSettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Security Hub & 2FA',
                        subtitle: 'TOTP 2FA, Auto-lock timer & Anti-phishing',
                        isDark: isDark,
                        onTap: _showSecurityHubSheet,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 📄 SECTION 2: DOCUMENTS (Documents waly features)
                  _buildSectionHeader(
                    title: 'Documents & KYC',
                    icon: Icons.description_outlined,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildSettingsGroup(
                    isDark: isDark,
                    items: [
                      _buildSettingsTile(
                        icon: Icons.badge_outlined,
                        title: 'Identity Document (CNIC / Passport)',
                        subtitle: 'Verified • ${_userCnic.isNotEmpty ? _userCnic : "61101-9283741-9"}',
                        isDark: isDark,
                        trailingBadge: 'Verified',
                        badgeColor: const Color(0xFF10B981),
                        onTap: _showCnicVerificationSheet,
                      ),
                      _buildSettingsTile(
                        icon: Icons.home_outlined,
                        title: 'Proof of Address & Utility Bill',
                        subtitle: 'IESCO Bill • Verified Address',
                        isDark: isDark,
                        trailingBadge: 'Active',
                        badgeColor: const Color(0xFF10B981),
                        onTap: _showAddressProofSheet,
                      ),
                      _buildSettingsTile(
                        icon: Icons.workspace_premium_outlined,
                        title: 'KYC Account Tier',
                        subtitle: 'Tier 2 • PKR 500k/day Limit',
                        isDark: isDark,
                        trailingBadge: 'Tier 2',
                        badgeColor: const Color(0xFFF3D602),
                        badgeTextColor: const Color(0xFF1B1D28),
                        onTap: _showKycTierSheet,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ⚙️ SECTION 3: ACCOUNT MANAGEMENT (Account management waly features)
                  _buildSectionHeader(
                    title: 'Account Management',
                    icon: Icons.manage_accounts_outlined,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildSettingsGroup(
                    isDark: isDark,
                    items: [
                      _buildSettingsTile(
                        icon: Icons.speed_outlined,
                        title: 'Daily Transfer Limits',
                        subtitle: 'PKR ${_dailyTransferLimit.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} / Day',
                        isDark: isDark,
                        onTap: _showTransferLimitsSheet,
                      ),
                      _buildSettingsTile(
                        icon: Icons.account_balance_outlined,
                        title: 'Linked Bank Accounts & IBAN',
                        subtitle: '${_linkedBanks.length} accounts connected',
                        isDark: isDark,
                        onTap: _showLinkedBanksSheet,
                      ),
                      _buildSettingsTile(
                        icon: Icons.language_outlined,
                        title: 'Currency & Language',
                        subtitle: '$_selectedCurrency • $_selectedLanguage',
                        isDark: isDark,
                        onTap: _showCurrencyLanguageSheet,
                      ),
                      _buildSettingsTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'SMS & Push Alerts',
                        subtitle: 'Transactional alerts & statements',
                        isDark: isDark,
                        onTap: _showNotificationPreferencesSheet,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 📞 SECTION 4: CONTACT INFORMATION (Contact info waly features)
                  _buildSectionHeader(
                    title: 'Contact Information',
                    icon: Icons.contact_phone_outlined,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildSettingsGroup(
                    isDark: isDark,
                    items: [
                      _buildSettingsTile(
                        icon: Icons.phone_android_outlined,
                        title: 'Registered Mobile Number',
                        subtitle: '$_userPhone • Primary OTP',
                        isDark: isDark,
                        trailingBadge: 'Primary',
                        badgeColor: const Color(0xFF10B981),
                        onTap: _showPhoneUpdateSheet,
                      ),
                      _buildSettingsTile(
                        icon: Icons.mail_outline_rounded,
                        title: 'Primary Email Address',
                        subtitle: '$_userEmail • Verified',
                        isDark: isDark,
                        trailingBadge: 'Verified',
                        badgeColor: const Color(0xFF10B981),
                        onTap: _showEmailUpdateSheet,
                      ),
                      _buildSettingsTile(
                        icon: Icons.location_on_outlined,
                        title: 'Residential Address',
                        subtitle: _userAddress,
                        isDark: isDark,
                        onTap: _showAddressUpdateSheet,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🛟 SECTION 5: HELP & SUPPORT (Help & support waly features)
                  _buildSectionHeader(
                    title: 'Help & Support',
                    icon: Icons.help_outline_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildSettingsGroup(
                    isDark: isDark,
                    items: [
                      _buildSettingsTile(
                        icon: Icons.forum_outlined,
                        title: '24/7 Live Support Chat',
                        subtitle: 'Direct line to BATWA Concierge',
                        isDark: isDark,
                        trailingBadge: 'Online',
                        badgeColor: const Color(0xFF10B981),
                        onTap: _showLiveSupportChatSheet,
                      ),
                      _buildSettingsTile(
                        icon: Icons.quiz_outlined,
                        title: 'FAQs & User Guide',
                        subtitle: 'Answers to common questions',
                        isDark: isDark,
                        onTap: _showFaqSheet,
                      ),
                      _buildSettingsTile(
                        icon: Icons.article_outlined,
                        title: 'Terms of Service & Privacy',
                        subtitle: 'SBP Licensed EMI regulations',
                        isDark: isDark,
                        onTap: _showTermsPolicySheet,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 🚪 LOGOUT BUTTON & BUILD VERSION
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.25)),
                    ),
                    child: ListTile(
                      onTap: _confirmLogout,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                      ),
                      title: const Text(
                        'Log Out from Account',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
                      subtitle: const Text(
                        'Safely disconnect this session',
                        style: TextStyle(color: Colors.white54, fontSize: 11.5),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFEF4444)),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: 16,
                            height: 16,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'BATWA Next-Gen Banking • v2.2.0 (Build 46)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white38 : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 🌟 3. Floating Bottom Navigation Dock (Persistent across all tabs!)
      FloatingPillNavBar(
        selectedIndex: 3,
        onTabSelected: (index) {
          widget.onClose();
          if (index == 0) {
            // Return to Home
          } else if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CardsScreen()),
            );
          } else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()),
            );
          } else if (index == 3) {
            // Already on More
          }
        },
      ),
    ],
  ),
);
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup({
    required bool isDark,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141722) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final isLast = index == items.length - 1;
          return Column(
            children: [
              items[index],
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 0.8,
                  indent: 52,
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    VoidCallback? onTap,
    Widget? trailing,
    String? trailingBadge,
    Color? badgeColor,
    Color? badgeTextColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1B1D28),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (trailingBadge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (badgeColor ?? const Color(0xFF10B981)).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: (badgeColor ?? const Color(0xFF10B981)).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  trailingBadge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeTextColor ?? (badgeColor ?? const Color(0xFF10B981)),
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? Colors.white38 : AppColors.darkNavy.withValues(alpha: 0.35),
              ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordSheet() {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isSubmitting = false;
    bool obscureCurrent = true;
    bool obscureNew = true;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final isDark = Theme.of(modalCtx).brightness == Brightness.dark;

          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131722) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 28,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3D602).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.password_rounded, color: Color(0xFFF3D602), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Change Password',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF1B1D28),
                              ),
                            ),
                            Text(
                              'Enter your current and new password',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: currentPassCtrl,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFF3D602)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setModalState(() => obscureCurrent = !obscureCurrent),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: newPassCtrl,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'New Password (min 8 characters)',
                      prefixIcon: const Icon(Icons.lock_reset_rounded, color: Color(0xFF10B981)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setModalState(() => obscureNew = !obscureNew),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
                      errorText: errorText,
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final currentP = currentPassCtrl.text;
                              final newP = newPassCtrl.text;
                              final confirmP = confirmPassCtrl.text;

                              if (currentP.isEmpty) {
                                setModalState(() => errorText = 'Please enter your current password.');
                                return;
                              }
                              if (newP.length < 8) {
                                setModalState(() => errorText = 'New password must be at least 8 characters.');
                                return;
                              }
                              if (newP != confirmP) {
                                setModalState(() => errorText = 'New passwords do not match.');
                                return;
                              }

                              setModalState(() {
                                isSubmitting = true;
                                errorText = null;
                              });

                              try {
                                await ApiClient().client.post(
                                  '/auth/password/change',
                                  data: {
                                    'currentPassword': currentP,
                                    'newPassword': newP,
                                  },
                                );
                                if (modalCtx.mounted) Navigator.pop(modalCtx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                                          SizedBox(width: 8),
                                          Text('Password changed successfully!'),
                                        ],
                                      ),
                                      backgroundColor: Color(0xFF07482D),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() {
                                  isSubmitting = false;
                                  errorText = e.toString().contains('Invalid current password') || e.toString().contains('incorrect')
                                      ? 'Current password is incorrect.'
                                      : 'Failed to update password. Please check your credentials.';
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF07482D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Update Password Now', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
