import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import '../../domain/entities/security_settings_entity.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';

class EditLimitsDialog extends StatefulWidget {
  final SecuritySettingsEntity settings;

  const EditLimitsDialog({super.key, required this.settings});

  @override
  State<EditLimitsDialog> createState() => _EditLimitsDialogState();
}

class _EditLimitsDialogState extends State<EditLimitsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dailyLimitCtrl;
  late final TextEditingController _monthlyLimitCtrl;
  final _pinCtrl = TextEditingController();

  late bool _loginAlerts;
  late bool _requirePinTransfers;

  @override
  void initState() {
    super.initState();
    _dailyLimitCtrl = TextEditingController(text: widget.settings.dailySpendingLimit.toStringAsFixed(0));
    _monthlyLimitCtrl = TextEditingController(text: widget.settings.monthlySpendingLimit.toStringAsFixed(0));
    _loginAlerts = widget.settings.loginAlertsEnabled;
    _requirePinTransfers = widget.settings.requirePinForAllTransfers;
  }

  @override
  void dispose() {
    _dailyLimitCtrl.dispose();
    _monthlyLimitCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final daily = double.tryParse(_dailyLimitCtrl.text.trim());
      final monthly = double.tryParse(_monthlyLimitCtrl.text.trim());

      context.read<SecurityBloc>().add(
            UpdateLimitsEvent(
              dailyLimit: daily,
              monthlyLimit: monthly,
              loginAlerts: _loginAlerts,
              requirePinForAllTransfers: _requirePinTransfers,
              pin: _pinCtrl.text.trim(),
            ),
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
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
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Spending Limits & Controls',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
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
              const SizedBox(height: 14),

              // Daily Limit
              const Text('DAILY SPENDING LIMIT (PKR)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _dailyLimitCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.today_rounded, color: AppColors.primary, size: 18),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter daily limit';
                  final numVal = double.tryParse(val.trim());
                  if (numVal == null || numVal < 500) return 'Min limit is 500';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Monthly Limit
              const Text('MONTHLY SPENDING LIMIT (PKR)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _monthlyLimitCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 18),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter monthly limit';
                  final numVal = double.tryParse(val.trim());
                  if (numVal == null || numVal < 5000) return 'Min limit is 5000';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Toggles
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _loginAlerts,
                onChanged: (val) => setState(() => _loginAlerts = val),
                title: const Text('Login Notifications', style: TextStyle(fontSize: 13, color: Colors.white)),
                subtitle: const Text('Alert when new device signs in', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                activeColor: AppColors.primary,
              ),

              const Divider(color: AppColors.cardBorder, height: 20),

              // PIN confirmation
              const Text('ENTER YOUR 4-DIGIT MPIN TO SAVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _pinCtrl,
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
                  prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.primary, size: 18),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'PIN required' : null,
              ),
              const SizedBox(height: 18),

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
                  child: const Text('Save Limit Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}