/// Result of an email validation operation.
/// Contains validation status, potential suggestions and error messages.
class EmailValidationResult {
  /// Creates a validation result
  const EmailValidationResult({
    required this.isValid,
    this.suggestion,
    this.error,
  }) : assert(
         isValid ? (error == null) : true,
         'Valid emails cannot have errors when isValid=true',
       );

  /// Whether the email is valid according to the validation rules
  final bool isValid;

  /// Suggestion for correction if the email seems to have a typo
  final String? suggestion;

  /// Error message if the email is invalid
  final String? error;

  /// Creates a copy of this result with modified fields
  EmailValidationResult copyWith({
    bool? isValid,
    String? suggestion,
    String? error,
  }) {
    return EmailValidationResult(
      isValid: isValid ?? this.isValid,
      suggestion: suggestion ?? this.suggestion,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    if (isValid) {
      return 'EmailValidationResult(valid)';
    }
    if (suggestion != null) {
      return 'EmailValidationResult(invalid, suggestion: $suggestion)';
    }
    if (error != null) {
      return 'EmailValidationResult(invalid, error: $error)';
    }
    return 'EmailValidationResult(invalid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmailValidationResult &&
        other.isValid == isValid &&
        other.suggestion == suggestion &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(isValid, suggestion, error);
}
