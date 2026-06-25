import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecurityBlockedApp extends StatelessWidget {
  const SecurityBlockedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _SecurityBlockedScreen(),
    );
  }
}

class _SecurityBlockedScreen extends StatelessWidget {
  const _SecurityBlockedScreen();

  void _closeApp() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.gpp_bad_rounded,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  'Security Warning',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'This app cannot run on jailbroken or rooted devices '
                  'to protect the security of your community data.',
                  style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Divider(height: 1),
                const SizedBox(height: 20),
                Text(
                  'Please use a device that has not been modified.',
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _closeApp,
                    icon: const Icon(Icons.exit_to_app_rounded),
                    label: const Text('Exit App'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
