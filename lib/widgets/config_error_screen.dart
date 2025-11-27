import 'package:flutter/material.dart';

class ConfigErrorScreen extends StatelessWidget {
  const ConfigErrorScreen({
    required this.errorMessage,
  });

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration required'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A `config.json` file must exist next to the executable.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create a `config.json` file with your personal values and restart the app.\n'
              'The file must be valid JSON, otherwise the simulator cannot run.',
            ),
            const SizedBox(height: 32),
            const Text(
              'Error details:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  errorMessage,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

