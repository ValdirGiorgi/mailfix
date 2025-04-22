import 'package:flutter/material.dart';
import 'package:mailfix/mailfix.dart';

/// Example page demonstrating email validation with customizable parameters using Mailfix package.
/// This page showcases:
/// - Different similarity algorithms (Jaro-Winkler, Levenshtein)
/// - Custom distance threshold configuration
/// - RFC 5322 email format validation
/// - Extra domains management
/// - Real-time domain distance calculation
class ParamValidationPage extends StatefulWidget {
  const ParamValidationPage({super.key});

  @override
  State<ParamValidationPage> createState() => _ParamValidationPageState();
}

class _ParamValidationPageState extends State<ParamValidationPage> {
  final _controller = TextEditingController();
  int _maxAllowedDistance = 3;
  MailfixSimilarityAlgorithm _selectedAlgorithm =
      MailfixSimilarityAlgorithm.jaroWinkler;
  bool _allowSpecialChars = false;
  Mailfix _mailfix = Mailfix();
  bool? _isValid;
  String? _suggestion;

  final List<String> _extraDomains = [];
  List<Map<String, dynamic>> _domainDistances = [];
  bool _showDomainDistances =
      false; // State to toggle visibility of domain distances

  /// Updates the Mailfix service with current configuration
  /// This method reinitializes the Mailfix instance with:
  /// - maxAllowedDistance: threshold for domain similarity
  /// - algorithm: selected similarity algorithm
  /// - allowSpecialChars: RFC 5322 email format validation
  /// - extraDomains: custom domain list
  void _updateMailfixService() {
    setState(() {
      _mailfix = Mailfix(
        maxAllowedDistance: _maxAllowedDistance,
        algorithm: _selectedAlgorithm,
        allowSpecialChars: _allowSpecialChars,
        extraDomains: _extraDomains, // Ensures extra domains are retained
      );
    });
    _updateDomainDistances();
  }

  /// Calculates and updates the similarity distance between the input domain
  /// and all available domains (built-in + custom domains).
  /// This provides real-time feedback about domain similarity scores.
  void _updateDomainDistances() {
    final email = _controller.text.trim();
    final parts = email.split('@');
    if (parts.length == 2) {
      final domain = parts[1].toLowerCase();
      setState(() {
        _domainDistances =
            _mailfix.domains.map((d) {
              final distance = _mailfix.similarityAlgorithm.calculate(
                domain,
                d,
              );
              return {'domain': d, 'distance': distance};
            }).toList();
        _domainDistances.sort((a, b) => a['distance'].compareTo(b['distance']));
      });
    } else {
      setState(() {
        _domainDistances = [];
      });
    }
  }

  /// Validates the email using Mailfix and updates the UI with the result
  /// The validation includes:
  /// - Email format check
  /// - Domain similarity calculation
  /// - Suggestion generation for similar domains
  void _validateEmail() {
    final result = _mailfix.validateEmail(_controller.text);
    setState(() {
      _isValid = result.isValid;
      _suggestion = result.suggestion;
    });
    _updateDomainDistances();
  }

  /// Shows a modal dialog for managing extra domains
  /// Features:
  /// - Add custom domains
  /// - Remove custom domains
  /// - View all available domains (built-in + custom)
  /// - Reset to default domains
  Future<void> _showDomainConfigModal() async {
    final tempDomains = List<String>.from(_extraDomains);
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            // allDomains is recalculated on each rebuild
            final allDomains = [
              ..._mailfix.domains,
              ...tempDomains.where((d) => !_mailfix.domains.contains(d)),
            ];
            return Dialog(
              insetPadding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 420,
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Add extra domain',
                                hintText: 'example.com',
                              ),
                              onSubmitted: (value) {
                                final domain = value.trim();
                                if (domain.isNotEmpty &&
                                    !tempDomains.contains(domain) &&
                                    !_mailfix.domains.contains(domain)) {
                                  setStateModal(() {
                                    tempDomains.add(domain);
                                    controller.clear();
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final domain = controller.text.trim();
                              if (domain.isNotEmpty &&
                                  !tempDomains.contains(domain) &&
                                  !_mailfix.domains.contains(domain)) {
                                setStateModal(() {
                                  tempDomains.add(domain);
                                  controller.clear();
                                });
                              }
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Configured domains:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child:
                            allDomains.isEmpty
                                ? const Text('No domains configured.')
                                : ListView.builder(
                                  itemCount: allDomains.length,
                                  itemBuilder: (context, index) {
                                    final domain = allDomains[index];
                                    final isSuggested = _mailfix.domains
                                        .contains(domain);
                                    return ListTile(
                                      title: Text(domain),
                                      trailing:
                                          isSuggested
                                              ? null
                                              : IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setStateModal(() {
                                                    tempDomains.remove(domain);
                                                  });
                                                },
                                              ),
                                    );
                                  },
                                ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _mailfix = Mailfix(
                                  maxAllowedDistance: _maxAllowedDistance,
                                  algorithm: _selectedAlgorithm,
                                  allowSpecialChars: _allowSpecialChars,
                                );
                                _extraDomains.clear();
                                _updateMailfixService();
                              });
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[200],
                              foregroundColor: Colors.red[900],
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _extraDomains
                                      ..clear()
                                      ..addAll(tempDomains);
                                    _updateMailfixService();
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validation with parameters')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width > 600 ? 32.0 : 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width > 600 ? 24.0 : 16.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _showDomainConfigModal,
                                icon: const Icon(Icons.settings),
                                label: Text(
                                  MediaQuery.of(context).size.width > 400
                                      ? 'Configure domains'
                                      : 'Configure',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[200],
                                  foregroundColor: Colors.blue[900],
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal:
                                        MediaQuery.of(context).size.width > 400
                                            ? 16.0
                                            : 8.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          // Parameter selection row
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              DropdownButton<MailfixSimilarityAlgorithm>(
                                value: _selectedAlgorithm,
                                items:
                                    MailfixSimilarityAlgorithm.values.map((
                                      algo,
                                    ) {
                                      return DropdownMenuItem(
                                        value: algo,
                                        child: Text(
                                          algo.name[0].toUpperCase() +
                                              algo.name.substring(1),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedAlgorithm = value;
                                      _updateMailfixService();
                                    });
                                  }
                                },
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width > 400
                                        ? 200
                                        : 160,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Dist.: '),
                                    Expanded(
                                      child: Slider(
                                        value: _maxAllowedDistance.toDouble(),
                                        min: 1,
                                        max: 7,
                                        divisions: 7,
                                        label: _maxAllowedDistance.toString(),
                                        onChanged: (value) {
                                          setState(() {
                                            _maxAllowedDistance = value.round();
                                            _updateMailfixService();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('RFC 5322'),
                                  Switch(
                                    value: _allowSpecialChars,
                                    onChanged: (value) {
                                      setState(() {
                                        _allowSpecialChars = value;
                                        _updateMailfixService();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Email input field
                          TextFormField(
                            controller: _controller,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'example@email.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => _updateDomainDistances(),
                            onFieldSubmitted: (_) => _validateEmail(),
                          ),
                          const SizedBox(height: 10),
                          // Button to toggle domain distances visibility
                          if (_domainDistances.isNotEmpty)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showDomainDistances =
                                        !_showDomainDistances;
                                  });
                                },
                                icon: Icon(
                                  _showDomainDistances
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                label: Text(
                                  _showDomainDistances
                                      ? 'Hide distances'
                                      : 'Show distances',
                                ),
                              ),
                            ),
                          // Domain distance feedback
                          if (_domainDistances.isNotEmpty &&
                              _showDomainDistances)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Distance to each suggested domain:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 120,
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children:
                                        _domainDistances.map((item) {
                                          final isWithin =
                                              item['distance'] <=
                                              _maxAllowedDistance;
                                          return Container(
                                            constraints: BoxConstraints(
                                              maxWidth:
                                                  MediaQuery.of(
                                                            context,
                                                          ).size.width >
                                                          400
                                                      ? 160
                                                      : 120,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isWithin
                                                      ? Colors.green[100]
                                                      : Colors.red[50],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    isWithin
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  item['domain'],
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'Dist.: ${item['distance']}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        isWithin
                                                            ? Colors.green[900]
                                                            : Colors.red[900],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 10),
                          // Validate button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _validateEmail,
                              icon: const Icon(
                                Icons.check_circle_outline,
                                size: 28,
                              ),
                              label: const Text(
                                'VALIDATE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  letterSpacing: 1,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                foregroundColor: Colors.white,
                                elevation: 6,
                                shadowColor: Colors.blue[900],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 22,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Validation result
                          if (_isValid != null)
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isValid!
                                          ? Icons.check_circle
                                          : Icons.error_outline,
                                      color:
                                          _isValid! ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        _isValid!
                                            ? 'The email format is correct.'
                                            : 'The email format is incorrect.',
                                        style: TextStyle(
                                          color:
                                              _isValid!
                                                  ? Colors.green[900]
                                                  : Colors.red[900],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  children: [
                                    const Icon(
                                      Icons.tips_and_updates_outlined,
                                      color: Colors.blueGrey,
                                    ),
                                    Text(
                                      _suggestion != null
                                          ? 'Your email domain may be incorrect, did you mean: ${_suggestion!} ?'
                                          : 'No suggestion',
                                      style: TextStyle(
                                        color: Colors.blueGrey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Info text
                Text(
                  'Mailfix - Email domain validation and suggestion',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Type an email and see automatic suggestions for common mistyped domains.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
