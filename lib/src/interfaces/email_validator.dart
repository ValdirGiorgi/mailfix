// Interface for email validators
abstract class EmailValidator {
  String get name;
  bool isValid(String email);
}
