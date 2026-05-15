/// Input Validation Utilities
///
/// Contains regex patterns and validation methods for various input formats
///
class InputValidator {
  /// PMDC License Number regex pattern
  /// Format: 12345-P (5 digits + hyphen + 1 letter)
  static const String pmdcPattern = r'^\d{5}-[A-Za-z]$';

  /// CNIC Number regex pattern
  /// Format: 12345-1234567-1 (5 digits + hyphen + 7 digits + hyphen + 1 digit)
  static const String cnicPattern = r'^\d{5}-\d{7}-\d{1}$';

  /// Email regex pattern
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  /// Phone number regex pattern (Pakistan format)
  /// Format: +923001234567 or 03001234567
  static const String phonePattern = r'^(\+92|0)?[345]\d{9}$';

  /// Validate PMDC License Number format
  ///
  /// Accepts format: 12345-P
  /// - 5 digits
  /// - hyphen
  /// - 1 letter (A-Z or a-z)
  ///
  static bool validatePMDC(String pmdc) {
    return RegExp(pmdcPattern).hasMatch(pmdc);
  }

  /// Validate CNIC Number format
  ///
  /// Accepts format: 12345-1234567-1
  /// - 5 digits
  /// - hyphen
  /// - 7 digits
  /// - hyphen
  /// - 1 digit
  ///
  static bool validateCNIC(String cnic) {
    return RegExp(cnicPattern).hasMatch(cnic);
  }

  /// Validate Email format
  static bool validateEmail(String email) {
    return RegExp(emailPattern).hasMatch(email);
  }

  /// Validate Phone Number format
  static bool validatePhone(String phone) {
    return RegExp(phonePattern).hasMatch(phone);
  }

  /// Get PMDC validation error message
  static String getPMDCErrorMessage(String pmdc) {
    if (pmdc.isEmpty) {
      return 'PMDC License Number is required';
    }
    if (!validatePMDC(pmdc)) {
      return 'Invalid format. Use: 12345-P';
    }
    return '';
  }

  /// Get CNIC validation error message
  static String getCNICErrorMessage(String cnic) {
    if (cnic.isEmpty) {
      return 'CNIC Number is required';
    }
    if (!validateCNIC(cnic)) {
      return 'Invalid format. Use: 12345-1234567-1';
    }
    return '';
  }

  /// Get Email validation error message
  static String getEmailErrorMessage(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!validateEmail(email)) {
      return 'Invalid email format';
    }
    return '';
  }

  /// Get Phone validation error message
  static String getPhoneErrorMessage(String phone) {
    if (phone.isEmpty) {
      return 'Phone number is required';
    }
    if (!validatePhone(phone)) {
      return 'Invalid phone format. Use: 03001234567 or +923001234567';
    }
    return '';
  }
}
