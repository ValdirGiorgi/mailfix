import 'package:flutter/material.dart';
import 'param_validation_page.dart';
import 'simple_validation_page.dart';

/// Home page for navigation between validation examples
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MailFix Example'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Button to navigate to parameterized validation page
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ParamValidationPage(),
                    ),
                  );
                },
                child: const Text('Validation with parameters'),
              ),
              const SizedBox(height: 24),
              // Button to navigate to simple validation page
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleValidationPage(),
                    ),
                  );
                },
                child: const Text('Simple validation (default)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
