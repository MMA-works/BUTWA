import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_event.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_state.dart';
import 'package:batwa_wallet/features/wallet/presentation/screens/main_3d_shell_screen.dart';

class PinSetupScreen extends StatefulWidget {
  final bool isFromOnboarding;

  const PinSetupScreen({
    super.key,
    this.isFromOnboarding = false,
  });

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _errorMessage;

  void _onDigitPressed(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null;
      if (!_isConfirming) {
        if (_firstPin.length < 4) {
          _firstPin += digit;
          if (_firstPin.length == 4) {
            // Transition to confirmation after slight delay
            Future.delayed(const Duration(milliseconds: 220), () {
              if (mounted) {
                setState(() {
                  _isConfirming = true;
                });
              }
            });
          }
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin += digit;
          if (_confirmPin.length == 4) {
            _validateAndSubmit();
          }
        }
      }
    });
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null;
      if (!_isConfirming) {
        if (_firstPin.isNotEmpty) {
          _firstPin = _firstPin.substring(0, _firstPin.length - 1);
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          // Back to first PIN
          _isConfirming = false;
          _firstPin = '';
        }
      }
    });
  }

  void _validateAndSubmit() {
    if (_firstPin != _confirmPin) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage = 'PINs do not match. Please enter again.';
        _confirmPin = '';
        _firstPin = '';
        _isConfirming = false;
      });
      return;
    }

    // Submit PIN to backend
    context.read<AuthBloc>().add(
          SetPinSubmittedEvent(
            pin: _firstPin,
            currentPassword: '',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPin = _isConfirming ? _confirmPin : _firstPin;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isFromOnboarding ? 'Final Step: Set PIN' : 'Transaction PIN',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        leading: widget.isFromOnboarding
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            setState(() {
              _errorMessage = state.message;
              _firstPin = '';
              _confirmPin = '';
              _isConfirming = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is PinSetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFFF3D602)),
                    SizedBox(width: 8),
                    Text('Transaction PIN configured successfully!'),
                  ],
                ),
                backgroundColor: Color(0xFF07482D),
                behavior: SnackBarBehavior.floating,
              ),
            );

            if (widget.isFromOnboarding) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const Main3DShellScreen()),
                (route) => false,
              );
            } else {
              Navigator.of(context).pop();
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Shield Icon Header
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3D602).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF3D602), width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.shield_rounded, color: Color(0xFF07482D), size: 36),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  _isConfirming ? 'Confirm Your 4-Digit PIN' : 'Create 4-Digit Security PIN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Text(
                    _isConfirming
                        ? 'Re-enter your 4-digit PIN to confirm and secure your Batwa wallet.'
                        : 'Your PIN protects all outgoing bank transfers, 1Bill payments, and virtual card controls.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // 4 PIN Dot Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final bool isFilled = index < currentPin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled ? const Color(0xFF07482D) : Colors.transparent,
                        border: Border.all(
                          color: isFilled ? const Color(0xFFF3D602) : (isDark ? Colors.white30 : const Color(0xFFCBD5E1)),
                          width: 2.2,
                        ),
                        boxShadow: isFilled
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF07482D).withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),

                const Spacer(),

                // Loading Spinner or Numeric Keypad
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Color(0xFF07482D)),
                        SizedBox(height: 14),
                        Text('Setting your secure PIN...', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  )
                else
                  _buildNumericKeypad(isDark),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumericKeypad(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('1', isDark),
              _buildKeypadButton('2', isDark),
              _buildKeypadButton('3', isDark),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('4', isDark),
              _buildKeypadButton('5', isDark),
              _buildKeypadButton('6', isDark),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('7', isDark),
              _buildKeypadButton('8', isDark),
              _buildKeypadButton('9', isDark),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Clear All
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _firstPin = '';
                    _confirmPin = '';
                    _isConfirming = false;
                    _errorMessage = null;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
              _buildKeypadButton('0', isDark),
              // Backspace
              GestureDetector(
                onTap: _onBackspace,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Center(
                    child: Icon(
                      Icons.backspace_outlined,
                      size: 24,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String digit, bool isDark) {
    return GestureDetector(
      onTap: () => _onDigitPressed(digit),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }
}
