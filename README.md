<p align="center">
  <img src="https://raw.githubusercontent.com/ValdirGiorgi/mailfix/refs/heads/main/assets/logos/mailfix.png" width="100" height="100" alt="Mailfix Logo">
</p>

# Mailfix

A powerful Dart/Flutter package for email validation and correction suggestions using advanced string similarity algorithms.

---

## Features

- 📧 RFC 5322 compliant email validation (optional)
- 🔍 Smart domain suggestions for typos
- 🌐 Multiple similarity algorithms:
  - [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance)
  - [Damerau-Levenshtein distance](https://en.wikipedia.org/wiki/Damerau-Levenshtein_distance)
  - [Jaro-Winkler similarity](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance)
- 🎯 Customizable domain validation
- ⚙️ Configurable similarity threshold

## Installation

```yaml
dependencies:
  mailfix: ^0.0.5
```

![Mailfix Demo](https://valdir.dev.br/mailfix/print.png)

## Usage

### Simple Example

```dart
import 'package:mailfix/mailfix.dart';

void main() {
  final mailfix = Mailfix();
  final result = mailfix.validateEmail('user@gmal.com');
  print(result.suggestion); // Suggests: user@gmail.com
}
```

### Basic Usage

```dart
import 'package:mailfix/mailfix.dart';

void main() {
  final mailfix = Mailfix();
  
  final result = mailfix.validateEmail('user@gmal.com');
  if (!result.isValid) {
    if (result.suggestion != null) {
      print('Suggestion: \\${result.suggestion}'); // Will suggest gmail.com
    } else {
      print('Error: \\${result.error}');
    }
  }
}
```

### Custom Configuration

```dart
final mailfix = Mailfix(
  // Choose similarity algorithm
  algorithm: MailfixSimilarityAlgorithm.damerauLevenshtein,
  // Configure similarity threshold
  maxAllowedDistance: 3,
);

// Add custom domains
mailfix.addDomain('company.com');
mailfix.addDomains(['domain1.com', 'domain2.com']);
```

### Custom Validator

```dart
class MyEmailValidator implements EmailValidatorInterface {
  @override
  bool isValid(String email) {
    // Your custom validation logic
    return true;
  }
}
```

## Live Example

Test the Mailfix library right now:

1. Visit our [interactive demo](https://valdir.dev.br/mailfix/) 
2. Type an email with typos (e.g., "user@gmial.com")
3. See the correction suggestions in real time

The [complete example code](https://github.com/ValdirGiorgi/mailfix/tree/main/example/lib) is available in the repository for you to implement in your project.

## Algorithms

### Jaro-Winkler Similarity (Default)
Optimized for short strings and gives more favorable ratings to strings that match from the beginning. Good for catching subtle differences in domain names. [Read more](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance)

### Levenshtein Distance 
Best for general purpose use. Calculates the minimum number of single-character edits required to change one string into another. [Read more](https://en.wikipedia.org/wiki/Levenshtein_distance)

### Damerau-Levenshtein Distance
Better for catching transposition errors (when two adjacent characters are swapped). Particularly useful for email domains where typos often involve character swaps. [Read more](https://en.wikipedia.org/wiki/Damerau-Levenshtein_distance)



## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
