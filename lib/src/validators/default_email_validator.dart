import 'package:email_validator/email_validator.dart' as validator;

import '../interfaces/email_validator.dart';

/// Default email validator implementation using email_validator package
class DefaultEmailValidator implements EmailValidator {
  DefaultEmailValidator({this.restrictSpecialChars = false});
  final bool restrictSpecialChars;

  @override
  String get name => 'default';

  @override
  bool isValid(String email) {
    if (email.isEmpty) return false;

    if (!validator.EmailValidator.validate(email)) {
      return false;
    }

    if (restrictSpecialChars) {
      final parts = email.split('@');
      if (parts.length != 2) return false;

      final local = parts[0];
      const specialChars = r'!#$%&*/=?^`{|}~';
      for (var char in specialChars.runes.toList().map(
        (r) => String.fromCharCode(r),
      )) {
        if (local.contains(char)) {
          return false;
        }
      }
    }

    return true;
  }
}
