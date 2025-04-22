import 'package:mailfix/mailfix.dart';
import 'package:test/test.dart';

void main() {
  group('Mailfix - Default parameters', () {
    final mailfix = Mailfix();

    test('Valid email', () {
      final result = mailfix.validateEmail('user@gmail.com');
      expect(result.isValid, isTrue);
      expect(result.suggestion, isNull);
    });

    test('Suggests correct domain for common typo', () {
      final result = mailfix.validateEmail('user@gmil.com');
      expect(result.isValid, isTrue);
      expect(result.suggestion, 'user@gmail.com');
    });

    test('Invalid email without @', () {
      final result = mailfix.validateEmail('usergmail.com');
      expect(result.isValid, isFalse);
      expect(result.suggestion, isNull);
    });
  });

  group('Mailfix - Similarity algorithms', () {
    test('Damerau-Levenshtein suggests domain with transposition', () {
      final mailfix = Mailfix(
        algorithm: MailfixSimilarityAlgorithm.damerauLevenshtein,
      );
      final result = mailfix.validateEmail('user@gmial.com');
      expect(result.suggestion, 'user@gmail.com');
    });

    test('Jaro-Winkler suggests domain with subtle typo', () {
      final mailfix = Mailfix(
        algorithm: MailfixSimilarityAlgorithm.jaroWinkler,
      );
      final result = mailfix.validateEmail('user@gmali.com');
      expect(result.suggestion, 'user@gmail.com');
    });
  });

  group('Mailfix - Extra domains', () {
    test('Suggests added extra domain', () {
      final mailfix = Mailfix(extraDomains: ['empresa.com']);
      final result = mailfix.validateEmail('user@emrpesa.com');
      expect(result.suggestion, 'user@empresa.com');
    });

    test('Last domain has priority in tie', () {
      final mailfix = Mailfix(extraDomains: ['dominio2.com', 'dominio1.com']);
      // Both have same distance for the typo below
      final result = mailfix.validateEmail('user@dominioz.com');
      // The last in the list (dominio2.com) should be suggested
      expect(result.suggestion, 'user@dominio1.com');
    });

    test('Add domain after instance', () {
      final mailfix = Mailfix();
      mailfix.addDomain('novodominio.com');
      final result = mailfix.validateEmail('user@novodomino.com');
      expect(result.suggestion, 'user@novodominio.com');
    });
  });

  group('Mailfix - Special characters', () {
    const emailWithSpecial = 'user!teste@gmail.com';

    test('Domain with special char is not accepted by default', () {
      final mailfix = Mailfix();
      final result = mailfix.validateEmail(emailWithSpecial);
      expect(result.isValid, isFalse);
      // Suggestion may be null or same as special domain, depending on validation
    });

    test(
      'Domain with special char is accepted with allowSpecialChars=true',
      () {
        final mailfix = Mailfix(allowSpecialChars: true);
        final result = mailfix.validateEmail(emailWithSpecial);
        expect(result.isValid, isTrue);
        expect(result.suggestion, isNull);
      },
    );
  });

  group('Mailfix - Additional cases', () {
    test('Multiple domains', () {
      final mailfix = Mailfix(
        extraDomains: ['test.com', 'xpto.com.br'],
        allowSpecialChars: true,
      );
      final result1 = mailfix.validateEmail('user@teste.com');
      final result2 = mailfix.validateEmail('user@xpo.com');
      expect(result1.suggestion, 'user@test.com');
      expect(result2.suggestion, 'user@xpto.com.br');
    });

    test('Adding duplicate domain does not cause error', () {
      final mailfix = Mailfix();
      mailfix.addDomain('gmail.com');
      final result = mailfix.validateEmail('user@gmail.com');
      expect(result.isValid, isTrue);
    });

    test('Empty email is invalid', () {
      final mailfix = Mailfix();
      final result = mailfix.validateEmail('');
      expect(result.isValid, isFalse);
    });

    test('Email with only spaces is invalid', () {
      final mailfix = Mailfix();
      final result = mailfix.validateEmail('   ');
      expect(result.isValid, isFalse);
    });
  });
}
