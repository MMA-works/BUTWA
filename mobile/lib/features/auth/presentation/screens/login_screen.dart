import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/services/biometric_service.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_event.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_state.dart';
import 'package:batwa_wallet/features/auth/presentation/screens/register_screen.dart';
import 'package:batwa_wallet/features/wallet/presentation/screens/main_3d_shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;


  @override
  void initState() {
    super.initState();
    // Default demo credentials prefilled for effortless testing
    _identifierController.text = 'batwa.tester2026@gmail.com';
    _passwordController.text = 'Test@123456';
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginSubmittedEvent(
              identifier: _identifierController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _showServerConfigDialog() {
    final serverController = TextEditingController(text: ApiConstants.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.dns_rounded, color: AppColors.accent),
            SizedBox(width: 10),
            Text('Server Settings', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your backend server API base URL:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: serverController,
              decoration: InputDecoration(
                hintText: 'http://172.16.69.143:8080/api/v1',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('172.16.91.130 (Wi-Fi)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.primaryMustard.withValues(alpha: 0.2),
                  onPressed: () => serverController.text = 'http://172.16.91.130:8080/api/v1',
                ),
                ActionChip(
                  label: const Text('Localhost (USB)', style: TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.background,
                  onPressed: () => serverController.text = 'http://127.0.0.1:8080/api/v1',
                ),
                ActionChip(
                  label: const Text('192.168.0.100', style: TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.background,
                  onPressed: () => serverController.text = 'http://192.168.0.100:8080/api/v1',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final newUrl = serverController.text.trim();
              if (newUrl.isNotEmpty) {
                ApiClient.updateBaseUrl(newUrl);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Server updated to: $newUrl'),
                    backgroundColor: Colors.black87,
                  ),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save & Apply', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated || state is PinSetSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const Main3DShellScreen()),
              (route) => false,
            );
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.settings_ethernet_rounded, color: AppColors.textSecondary),
                    tooltip: 'Server Settings',
                    onPressed: _showServerConfigDialog,
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0A382C).withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'BATWA',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Secure Next-Gen Digital Banking',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in with your email or phone number',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _identifierController,
                        decoration: const InputDecoration(
                          labelText: 'Email or Phone Number',
                          prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email or phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showForgotPasswordModal(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primaryYellow,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _onLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryYellow,
                                foregroundColor: const Color(0xFF042B1D),
                                minimumSize: const Size(double.infinity, 54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SpinKitThreeBounce(color: Color(0xFF042B1D), size: 24)
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF042B1D),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.fingerprint_rounded, color: AppColors.accent, size: 28),
                              tooltip: 'Quick Biometric Sign In',
                              onPressed: () async {
                                final service = BiometricService();
                                final result = await service.authenticate(
                                  reason: 'Scan fingerprint or Face ID to quickly log in to BATWA',
                                );
                                if (result.success) {
                                  _onLogin();
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result.message),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
      ),
    );
  }

  void _showForgotPasswordModal(BuildContext context) {
    final emailCtrl = TextEditingController(
      text: _identifierController.text.contains('@') ? _identifierController.text.trim() : '',
    );
    final otpCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();

    bool isOtpSent = false;
    bool isSubmitting = false;
    bool obscureNew = true;
    String? testOtp;

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
                          color: AppColors.primaryYellow.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_reset_rounded, color: AppColors.primaryYellow, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOtpSent ? 'Verify Code & Set Password' : 'Reset Password',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF1B1D28),
                              ),
                            ),
                            Text(
                              isOtpSent
                                  ? 'Enter 6-digit code sent to ${emailCtrl.text}'
                                  : 'Enter your registered email address',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (!isOtpSent) ...[
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Registered Email',
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryYellow),
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
                                final email = emailCtrl.text.trim();
                                if (email.isEmpty || !email.contains('@')) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter a valid email address.')),
                                  );
                                  return;
                                }

                                setModalState(() => isSubmitting = true);
                                try {
                                  final res = await ApiClient().client.post(
                                    ApiConstants.forgotPassword,
                                    data: {'email': email},
                                  );
                                  final data = res.data['data'] as Map<String, dynamic>?;
                                  setModalState(() {
                                    isSubmitting = false;
                                    isOtpSent = true;
                                    testOtp = data?['otp']?.toString();
                                  });
                                } catch (e) {
                                  setModalState(() => isSubmitting = false);
                                  String msg = 'Email not found or error occurred.';
                                  if (e.toString().contains('No BATWA account')) {
                                    msg = 'No BATWA account found with this email.';
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(msg), backgroundColor: AppColors.error),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: const Color(0xFF07482D),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SpinKitThreeBounce(color: Color(0xFF07482D), size: 20)
                            : const Text('Send Reset OTP Code', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      ),
                    ),
                  ] else ...[
                    if (testOtp != null) ...[
                      GestureDetector(
                        onTap: () {
                          otpCtrl.text = testOtp!;
                          setModalState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.mark_email_read_rounded, size: 14, color: Color(0xFF10B981)),
                              const SizedBox(width: 6),
                              Text(
                                'Sent Code: $testOtp (tap to auto-fill)',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextField(
                      controller: otpCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, letterSpacing: 6, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: '6-Digit Reset Code',
                        counterText: '',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: newPasswordCtrl,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryYellow),
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setModalState(() => obscureNew = !obscureNew),
                        ),
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
                                final code = otpCtrl.text.trim();
                                final newPass = newPasswordCtrl.text;
                                if (code.length != 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter the 6-digit reset code.')),
                                  );
                                  return;
                                }
                                if (newPass.length < 8) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Password must be at least 8 characters long.')),
                                  );
                                  return;
                                }

                                setModalState(() => isSubmitting = true);
                                try {
                                  await ApiClient().client.post(
                                    ApiConstants.resetPassword,
                                    data: {
                                      'email': emailCtrl.text.trim(),
                                      'code': code,
                                      'newPassword': newPass,
                                    },
                                  );
                                  if (modalCtx.mounted) Navigator.pop(modalCtx);
                                  _passwordController.text = newPass;
                                  _identifierController.text = emailCtrl.text.trim();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                                          SizedBox(width: 8),
                                          Text('Password reset successfully! Please sign in.'),
                                        ],
                                      ),
                                      backgroundColor: Color(0xFF07482D),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } catch (e) {
                                  setModalState(() => isSubmitting = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                            : const Text('Update & Reset Password', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
