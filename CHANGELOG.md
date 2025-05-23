# Changelog

## 0.37.1

### Changed
- Updated the list of restricted special characters in the default email validator
- Removed hyphen (`-`), underscore (`_`), and plus (`+`) from the restricted characters list
- Improved compatibility with common corporate email addresses and email aliasing practices that frequently use these characters

## 0.0.4
### Changed
- Change for package DART
## 0.0.1 - Initial Release

### Added
- Core email validation functionality
- Multiple similarity algorithms:
  - Levenshtein distance
  - Damerau-Levenshtein distance
  - Jaro-Winkler similarity
- Internationalization support (en, pt-br)
- Customizable domain validation
- Configurable similarity threshold
- Flutter example application
- Comprehensive test coverage
- Documentation in English

### Features
- Email format validation following RFC 5322
- Smart domain suggestions for typos
- Extensible architecture for custom validators
- Built-in common email domain list
- Case-insensitive domain matching
- Dependency injection support
- Flexible configuration options
