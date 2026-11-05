import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';

class ChangePinDialog extends StatefulWidget {
  final bool isReset;

  const ChangePinDialog({super.key, this.isReset = false});

  @override
  State<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<ChangePinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentAuthCtrl = TextEditingController();
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _currentAuthCtrl.dispose();
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.isReset) {
        context.read<SecurityBloc>().add(
              ResetPinEvent(
                accountPassword: _currentAuthCtrl.text.trim(),
                newPin: _newPinCtrl.text.trim(),
              ),
            );
      } else {
        context.read<SecurityBloc>().add(
              ChangePinEvent(
                currentPinOrPassword: _currentAuthCtrl.text.trim(),
                newPin: _newPinCtrl.text.trim(),
              ),
            );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.pin_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.isReset ? 'Reset MPIN' : 'Change MPIN',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.isReset
                    ? 'Enter your account password to authorize MPIN reset.'
                    : 'Enter your current MPIN or account password, followed by your new 4-digit PIN.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Current PIN / Password
              Text(
                widget.isReset ? 'ACCOUNT PASSWORD' : 'CURRENT MPIN / PASSWORD',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _currentAuthCtrl,
                obscureText: _obscureCurrent,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.isReset ? 'Enter password' : 'Enter current PIN or password',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted, size: 18),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // New PIN
              const Text('NEW 4-DIGIT MPIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _newPinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: _obscureNew,
                style: const TextStyle(color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 4),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted, size: 18),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 4) return 'PIN must be at least 4 digits';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Confirm New PIN
              const Text('CONFIRM NEW MPIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _confirmPinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                style: const TextStyle(color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 4),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 18),
                ),
                validator: (val) {
                  if (val != _newPinCtrl.text) return 'PINs do not match';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    widget.isReset ? 'Reset MPIN Now' : 'Update MPIN',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}