import 'package:flutter/material.dart';
import 'package:mailfix/mailfix.dart';

/// Page for email validation with customizable parameters
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
      false; // Novo estado para exibir/ocultar distâncias

  /// Atualiza o serviço Mailfix e recalcula as distâncias dos domínios
  void _updateMailfixService() {
    setState(() {
      _mailfix = Mailfix(
        maxAllowedDistance: _maxAllowedDistance,
        algorithm: _selectedAlgorithm,
        allowSpecialChars: _allowSpecialChars,
        extraDomains:
            _extraDomains, // Garante que os domínios extras sejam mantidos
      );
    });
    _updateDomainDistances();
  }

  /// Update domain distances for feedback
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

  /// Validate the email and update the result
  void _validateEmail() {
    final result = _mailfix.validateEmail(_controller.text);
    setState(() {
      _isValid = result.isValid;
      _suggestion = result.suggestion;
    });
    _updateDomainDistances();
  }

  /// Exibe um modal melhorado para configuração dos domínios extras
  Future<void> _showDomainConfigModal() async {
    final tempDomains = List<String>.from(_extraDomains);
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            // allDomains agora é recalculado a cada rebuild
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
                                labelText: 'Adicionar domínio extra',
                                hintText: 'exemplo.com',
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
                            child: const Text('Adicionar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Domínios configurados:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child:
                            allDomains.isEmpty
                                ? const Text('Nenhum domínio configurado.')
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            label: const Text('Resetar domínios'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[200],
                              foregroundColor: Colors.red[900],
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                              const SizedBox(width: 8),
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
                                child: const Text('Salvar'),
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
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _showDomainConfigModal,
                              icon: const Icon(Icons.settings),
                              label: const Text('Configurar domínios'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[200],
                                foregroundColor: Colors.blue[900],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const SizedBox(height: 18),
                        // Parameter selection row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton<MailfixSimilarityAlgorithm>(
                              value: _selectedAlgorithm,
                              items:
                                  MailfixSimilarityAlgorithm.values.map((algo) {
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
                            const SizedBox(width: 24),
                            Row(
                              children: [
                                const Text('Distância máxima: '),
                                SizedBox(
                                  width: 120,
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
                            const SizedBox(width: 24),
                            Row(
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
                        // Botão para exibir/ocultar distâncias
                        if (_domainDistances.isNotEmpty)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showDomainDistances = !_showDomainDistances;
                                });
                              },
                              icon: Icon(
                                _showDomainDistances
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              label: Text(
                                _showDomainDistances
                                    ? 'Ocultar distâncias'
                                    : 'Exibir distâncias',
                              ),
                            ),
                          ),
                        // Feedback de distância dos domínios
                        if (_domainDistances.isNotEmpty && _showDomainDistances)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Distância para cada domínio sugerido:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 80,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children:
                                      _domainDistances.map((item) {
                                        final isWithin =
                                            item['distance'] <=
                                            _maxAllowedDistance;
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isWithin
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item['domain'],
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                'Distância: ${item['distance']}',
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
                              'VALIDAR',
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
                              padding: const EdgeInsets.symmetric(vertical: 22),
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
                                  Text(
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
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.tips_and_updates_outlined,
                                    color: Colors.blueGrey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _suggestion != null
                                        ? 'Your email domain may be incorrect, did you mean: ${_suggestion!} ?'
                                        : 'No suggestion',
                                    style: TextStyle(
                                      color: Colors.blueGrey[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
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
