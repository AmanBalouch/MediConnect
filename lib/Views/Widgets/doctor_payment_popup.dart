import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';

/// Popup shown to doctor when they press Accept on a request.
/// Doctor fills in payment account details.
/// Returns a Map with keys: accountType, accountNumber, accountHolderName
/// or null if cancelled.
class DoctorPaymentPopup extends StatefulWidget {
  const DoctorPaymentPopup({super.key});

  @override
  State<DoctorPaymentPopup> createState() => _DoctorPaymentPopupState();
}

class _DoctorPaymentPopupState extends State<DoctorPaymentPopup> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberCtrl = TextEditingController();
  final _accountHolderCtrl = TextEditingController();
  final _otherTypeCtrl = TextEditingController();

  // 'easypaisa' | 'jazzcash' | 'others'
  String _selectedAccountType = 'easypaisa';

  @override
  void dispose() {
    _accountNumberCtrl.dispose();
    _accountHolderCtrl.dispose();
    _otherTypeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final accountType = _selectedAccountType == 'others'
        ? _otherTypeCtrl.text.trim()
        : _selectedAccountType;

    Navigator.of(context).pop({
      'accountType': accountType,
      'accountNumber': _accountNumberCtrl.text.trim(),
      'accountHolderName': _accountHolderCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ───────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTealLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.payments_rounded,
                        color: AppTheme.primaryTeal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter Payment Details',
                      style: AppTheme.label(AppTheme.textPrimary, 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Patient will receive your account details to pay the consultation fee.',
                style: AppTheme.small(AppTheme.textSecondary),
              ),

              const SizedBox(height: 20),

              // ── Account Type ─────────────────────────────────────────
              Text('Account Type',
                  style: AppTheme.small(AppTheme.textSecondary, 12)),
              const SizedBox(height: 8),

              // Row 1: EasyPaisa + JazzCash
              Row(
                children: [
                  _accountTypeChip(
                      'easypaisa', 'EasyPaisa', const Color(0xFF40C265)),
                  const SizedBox(width: 10),
                  _accountTypeChip(
                      'jazzcash', 'JazzCash', const Color(0xFFDB1F26)),
                ],
              ),
              const SizedBox(height: 10),

              // Row 2: Others (full width)
              _accountTypeChip(
                  'others', 'Others', AppTheme.primaryBlue,
                  fullWidth: true),

              // ── Others text field — shown only when Others selected ──
              if (_selectedAccountType == 'others') ...[
                const SizedBox(height: 12),
                Text('Specify Account / Bank Name',
                    style: AppTheme.small(AppTheme.textSecondary, 12)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _otherTypeCtrl,
                  style: AppTheme.body(AppTheme.textPrimary),
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      _inputDecoration('e.g. HBL, Meezan Bank, SadaPay...'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please specify account type'
                      : null,
                ),
              ],

              const SizedBox(height: 16),

              // ── Account Holder Name ──────────────────────────────────
              Text('Account Holder Name',
                  style: AppTheme.small(AppTheme.textSecondary, 12)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _accountHolderCtrl,
                style: AppTheme.body(AppTheme.textPrimary),
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration('e.g. Dr. Ahmed Khan'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Required'
                    : null,
              ),

              const SizedBox(height: 14),

              // ── Account Number ───────────────────────────────────────
              Text('Account Number',
                  style: AppTheme.small(AppTheme.textSecondary, 12)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _accountNumberCtrl,
                style: AppTheme.body(AppTheme.textPrimary),
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('03XX-XXXXXXX'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().length < 10) return 'Enter a valid number';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ── Buttons ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Accept & Send'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountTypeChip(
      String value, String label, Color brandColor,
      {bool fullWidth = false}) {
    final isSelected = _selectedAccountType == value;

    final chip = GestureDetector(
      onTap: () => setState(() {
        _selectedAccountType = value;
        // Clear custom field when switching away from others
        if (value != 'others') _otherTypeCtrl.clear();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? brandColor.withValues(alpha: 0.12)
              : AppTheme.bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? brandColor : AppTheme.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.label(
              isSelected ? brandColor : AppTheme.textSecondary,
              13,
            ),
          ),
        ),
      ),
    );

    return fullWidth ? chip : Expanded(child: chip);
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTheme.small(AppTheme.textTertiary),
        filled: true,
        fillColor: AppTheme.bgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
}
