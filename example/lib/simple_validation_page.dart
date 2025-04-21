import 'package:flutter/material.dart';
import 'package:mailfix/mailfix.dart';

/// Minimal page for simple email validation using default Mailfix parameters
class SimpleValidationPage extends StatefulWidget {
  const SimpleValidationPage({super.key});

  @override
  State<SimpleValidationPage> createState() => _SimpleValidationPageState();
}

class _SimpleValidationPageState extends State<SimpleValidationPage> {
  final _controller = TextEditingController();
  String? _validity;
  String? _suggestion;

  /// Validate email using Mailfix with default parameters
  void _validate() {
    final mailfix = Mailfix();
    final res = mailfix.validateEmail(_controller.text);
    setState(() {
      _validity = res.isValid ? 'Valid' : 'Invalid';
      if (res.suggestion != null) {
        _suggestion = 'Suggestion: \'${res.suggestion}\'';
      } else {
        _suggestion = 'No suggestion available.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple validation')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email input field
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Email'),
              onSubmitted: (_) => _validate(),
            ),
            const SizedBox(height: 16),
            // Validate button
            ElevatedButton(onPressed: _validate, child: const Text('Validate')),
            const SizedBox(height: 16),
            // Validation result
            if (_validity != null) Text(_validity!),
            if (_suggestion != null) Text(_suggestion!),
          ],
        ),
      ),
    );
  }
}
