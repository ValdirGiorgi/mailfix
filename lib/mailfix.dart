library;

import 'src/algorithms/damerau_levenshtein.dart';
import 'src/algorithms/jaro_winkler.dart';
import 'src/domains/domains.dart';
import 'src/interfaces/email_validator.dart';
import 'src/interfaces/similarity_algorithm.dart';
import 'src/models/email_validation_result.dart';
import 'src/validators/default_email_validator.dart';

export 'src/algorithms/damerau_levenshtein.dart';
export 'src/algorithms/jaro_winkler.dart';
export 'src/algorithms/levenshtein.dart';
export 'src/domains/domains.dart';
export 'src/interfaces/email_validator.dart';
export 'src/interfaces/similarity_algorithm.dart';
export 'src/models/email_validation_result.dart';
export 'src/validators/default_email_validator.dart';

/// Available similarity algorithms for email validation
enum MailfixSimilarityAlgorithm { levenshtein, damerauLevenshtein, jaroWinkler }

/// Main service for email validation and suggestion
class Mailfix {
  Mailfix({
    EmailValidator? validator,
    SimilarityAlgorithm? similarityAlgorithm,
    MailfixSimilarityAlgorithm? algorithm,
    EmailDomains? domains,
    List<String>? extraDomains,
    int maxAllowedDistance = 3,
    this.allowSpecialChars = false,
  }) : _validator =
           validator ??
           DefaultEmailValidator(restrictSpecialChars: !allowSpecialChars),
       _similarityAlgorithm =
           similarityAlgorithm ?? _getAlgorithmInstance(algorithm),
       _domains = domains ?? EmailDomains(),
       _maxAllowedDistance = maxAllowedDistance {
    if (extraDomains != null) {
      _domains.addDomains(extraDomains);
    }
  }

  final EmailValidator _validator;
  final SimilarityAlgorithm _similarityAlgorithm;
  final EmailDomains _domains;
  final int _maxAllowedDistance;
  final bool allowSpecialChars;

  /// Returns all valid domains (default + extras)
  List<String> get domains => _domains.domains;

  /// Returns the configured similarity algorithm
  SimilarityAlgorithm get similarityAlgorithm => _similarityAlgorithm;

  static SimilarityAlgorithm _getAlgorithmInstance(
    MailfixSimilarityAlgorithm? algorithm,
  ) {
    switch (algorithm) {
      case MailfixSimilarityAlgorithm.damerauLevenshtein:
        return DamerauLevenshteinAlgorithm();
      case MailfixSimilarityAlgorithm.jaroWinkler:
        return JaroWinklerAlgorithm();
      case MailfixSimilarityAlgorithm.levenshtein:
      default:
        return JaroWinklerAlgorithm();
    }
  }

  /// Validates an email and returns result with status and suggestion
  EmailValidationResult validateEmail(String email) {
    if (email.isEmpty) {
      // Returns invalid if email is empty
      return const EmailValidationResult(isValid: false);
    }

    final isValid = _validator.isValid(email);
    final suggestion = _suggestEmailCorrection(email);
    return EmailValidationResult(isValid: isValid, suggestion: suggestion);
  }

  /// Returns a corrected email suggestion or null
  String? _suggestEmailCorrection(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return null;

    final username = parts[0];
    final domain = parts[1].toLowerCase();

    // If domain is already valid, no suggestion is needed
    if (_domains.containsDomain(domain)) return null;

    String? bestMatch;
    int minDistance = _maxAllowedDistance;

    for (final validDomain in _domains.domains) {
      final distance = _similarityAlgorithm.calculate(domain, validDomain);
      if (distance <= minDistance) {
        minDistance = distance;
        bestMatch = validDomain;
      }
    }

    // Returns suggestion if a close match is found
    if (bestMatch != null) {
      return '$username@$bestMatch';
    }

    return null;
  }

  void addDomain(String domain) {
    _domains.addDomain(domain);
  }

  void addDomains(List<String> domains) {
    _domains.addDomains(domains);
  }
}
