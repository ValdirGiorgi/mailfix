# Mailfix

A powerful Dart/Flutter package for email validation and correction suggestions using advanced string similarity algorithms.

## Features

- 📧 RFC 5322 compliant email validation
- 🔍 Smart domain suggestions for typos
- 🌐 Multiple similarity algorithms:
  - Levenshtein distance
  - Damerau-Levenshtein distance
  - Jaro-Winkler similarity
- 🌍 Internationalization support
- 🎯 Customizable domain validation
- ⚙️ Configurable similarity threshold
- 🧩 Dependency injection support

## Installation

```yaml
dependencies:
  mailfix: ^0.0.1
```

## Usage

### Basic Usage

```dart
import 'package:mailfix/mailfix.dart';

void main() {
  final mailfix = Mailfix();
  
  final result = mailfix.validateEmail('user@gmal.com');
  if (!result.isValid) {
    if (result.suggestion != null) {
      print('Suggestion: ${result.suggestion}'); // Will suggest gmail.com
    } else {
      print('Error: ${result.error}');
    }
  }
}
```

### Custom Configuration

```dart
final mailfix = Mailfix(
  // Choose similarity algorithm
  algorithm: MailfixSimilarityAlgorithm.damerauLevenshtein,
  
  // Set language
  locale: 'pt-br', // Supports 'en' (default), 'pt-br'
  
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

final mailfix = Mailfix(validator: MyEmailValidator());
```

### Custom Messages

```dart
final messages = MailfixMessages(
  emptyEmail: 'Email cannot be empty',
  invalidEmail: 'Please enter a valid email',
  suggestionTemplate: 'Did you mean to type: {email}?',
);

final mailfix = Mailfix(messages: messages);
```

## Example

Check out the [example](example) directory for a complete Flutter application demonstrating all features.

## Algorithms

### Levenshtein Distance (Default)
Best for general purpose use. Calculates the minimum number of single-character edits required to change one string into another.

### Damerau-Levenshtein Distance
Better for catching transposition errors (when two adjacent characters are swapped). Particularly useful for email domains where typos often involve character swaps.

### Jaro-Winkler Similarity
Optimized for short strings and gives more favorable ratings to strings that match from the beginning. Good for catching subtle differences in domain names.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
