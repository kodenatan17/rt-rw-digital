import 'package:flutter/material.dart';

class ForcedUpdateApp extends StatelessWidget {
  final String? message;

  const ForcedUpdateApp({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Application Update Required',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(message ?? 'A compatibility issue was detected.'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Update Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
