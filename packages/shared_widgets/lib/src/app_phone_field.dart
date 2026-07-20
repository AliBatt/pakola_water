import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

/// Reusable phone input with country selector and E.164-style validation.
class AppPhoneField extends StatelessWidget {
  const AppPhoneField({
    super.key,
    this.initialValue,
    this.initialCountryCode = 'PK',
    this.labelText = 'Phone number',
    this.enabled = true,
    this.onChanged,
    this.onSaved,
    this.validator,
  });

  final String? initialValue;
  final String initialCountryCode;
  final String labelText;
  final bool enabled;
  final ValueChanged<PhoneNumber>? onChanged;
  final ValueChanged<PhoneNumber?>? onSaved;
  final String? Function(PhoneNumber?)? validator;

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      initialValue: _nationalNumber(initialValue),
      initialCountryCode: initialCountryCode,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
      disableLengthCheck: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: (phone) {
        if (validator != null) {
          return validator!(phone);
        }
        if (phone == null || phone.number.trim().isEmpty) {
          return 'Phone number is required';
        }
        if (phone.number.trim().length < 7) {
          return 'Enter a valid phone number';
        }
        return null;
      },
    );
  }

  static String? _nationalNumber(String? value) {
    if (value == null || value.isEmpty) return null;
    // Keep digits only for the national part when editing.
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('92') && digits.length > 10) {
      return digits.substring(2);
    }
    return digits;
  }
}
