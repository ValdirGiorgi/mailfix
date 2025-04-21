/// Manages a collection of valid email domains
class EmailDomains {
  /// Creates a new EmailDomains instance with optional initial domains
  EmailDomains([List<String>? initialDomains])
    : _domains = <String>{
        'gmail.com',
        'yahoo.com',
        'hotmail.com',
        'outlook.com',
        'live.com',
        'aol.com',
        'icloud.com',
        if (initialDomains != null)
          ...initialDomains.map((d) => d.toLowerCase()),
      };
  final Set<String> _domains;

  /// Adds a new valid domain (lowercase)
  void addDomain(String domain) {
    if (_isValidDomain(domain)) {
      _domains.add(domain.toLowerCase());
    }
  }

  /// Adds multiple valid domains
  void addDomains(List<String> domains) {
    for (final domain in domains) {
      addDomain(domain);
    }
  }

  /// Checks if the domain exists in the collection
  bool containsDomain(String domain) => _domains.contains(domain.toLowerCase());

  /// Immutable list of all domains
  List<String> get domains => List.unmodifiable(_domains);

  /// Checks if the domain format is valid
  bool _isValidDomain(String domain) {
    if (domain.isEmpty || domain.length > 255) return false;
    final parts = domain.split('.');
    if (parts.length < 2) return false;
    for (final part in parts) {
      if (part.isEmpty || part.length > 63) return false;
      if (!RegExp(r'^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$').hasMatch(part)) {
        return false;
      }
    }
    return true;
  }
}
