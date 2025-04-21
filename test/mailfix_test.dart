import 'package:flutter_test/flutter_test.dart';
import 'package:mailfix/mailfix.dart';

void main() {
  group('Mailfix - Parâmetros padrão', () {
    final mailfix = Mailfix();

    test('Valida email correto', () {
      final result = mailfix.validateEmail('user@gmail.com');
      expect(result.isValid, isTrue);
      expect(result.suggestion, isNull);
    });

    test('Sugere domínio correto para erro comum', () {
      final result = mailfix.validateEmail('user@gmil.com');
      expect(result.isValid, isTrue);
      expect(result.suggestion, 'user@gmail.com');
    });

    test('Email inválido sem arroba', () {
      final result = mailfix.validateEmail('usergmail.com');
      expect(result.isValid, isFalse);
      expect(result.suggestion, isNull);
    });
  });

  group('Mailfix - Algoritmos de similaridade', () {
    test('Damerau-Levenshtein sugere domínio com transposição', () {
      final mailfix = Mailfix(
        algorithm: MailfixSimilarityAlgorithm.damerauLevenshtein,
      );
      final result = mailfix.validateEmail('user@gmial.com');
      expect(result.suggestion, 'user@gmail.com');
    });

    test('Jaro-Winkler sugere domínio com erro sutil', () {
      final mailfix = Mailfix(
        algorithm: MailfixSimilarityAlgorithm.jaroWinkler,
      );
      final result = mailfix.validateEmail('user@gmali.com');
      expect(result.suggestion, 'user@gmail.com');
    });
  });

  group('Mailfix - Inclusão de domínios extras', () {
    test('Sugere domínio extra adicionado', () {
      final mailfix = Mailfix(extraDomains: ['empresa.com']);
      final result = mailfix.validateEmail('user@emrpesa.com');
      expect(result.suggestion, 'user@empresa.com');
    });

    test('Prioridade para último domínio em empate', () {
      final mailfix = Mailfix(extraDomains: ['dominio2.com', 'dominio1.com']);
      // Ambos têm distância igual para o erro abaixo
      final result = mailfix.validateEmail('user@dominioz.com');
      // O último da lista (dominio2.com) deve ser sugerido
      expect(result.suggestion, 'user@dominio2.com');
    });

    test('Adicionar domínio após instância', () {
      final mailfix = Mailfix();
      mailfix.addDomain('novodominio.com');
      final result = mailfix.validateEmail('user@novodomino.com');
      expect(result.suggestion, 'user@novodominio.com');
    });
  });

  group('Mailfix - Caracteres especiais', () {
    const emailWithSpecial = 'user!teste@gmail.com';

    test('Domínio com caractere especial não é aceito por padrão', () {
      final mailfix = Mailfix();
      final result = mailfix.validateEmail(emailWithSpecial);
      expect(result.isValid, isFalse);
      // Sugestão pode ser nula ou igual ao domínio especial, dependendo da validação
    });

    test(
      'Domínio com caractere especial é aceito com allowSpecialChars=true',
      () {
        final mailfix = Mailfix(allowSpecialChars: true);
        final result = mailfix.validateEmail(emailWithSpecial);
        expect(result.isValid, isTrue);
        expect(result.suggestion, isNull);
      },
    );
  });

  group('Mailfix - Casos adicionais', () {
    test('Múltiplos domínios', () {
      final mailfix = Mailfix(
        extraDomains: ['test.com', 'xpto.com.br'],
        allowSpecialChars: true,
      );
      final result1 = mailfix.validateEmail('user@teste.com');
      final result2 = mailfix.validateEmail('user@xpo.com');
      expect(result1.suggestion, 'user@test.com');
      expect(result2.suggestion, 'user@xpto.com.br');
    });

    test('Adicionar domínio duplicado não causa erro', () {
      final mailfix = Mailfix();
      mailfix.addDomain('gmail.com');
      final result = mailfix.validateEmail('user@gmail.com');
      expect(result.isValid, isTrue);
    });

    test('Email vazio é inválido', () {
      final mailfix = Mailfix();
      final result = mailfix.validateEmail('');
      expect(result.isValid, isFalse);
    });

    test('Email apenas com espaços é inválido', () {
      final mailfix = Mailfix();
      final result = mailfix.validateEmail('   ');
      expect(result.isValid, isFalse);
    });
  });
}
