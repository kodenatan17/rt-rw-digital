import 'package:flutter/material.dart';

import 'auth_token_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tokenStore = AuthTokenStore();
  await tokenStore.init();
  runApp(MyApp(tokenStore: tokenStore));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.tokenStore});

  final AuthTokenStore tokenStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Persistence Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: AuthDemoPage(tokenStore: tokenStore),
    );
  }
}

class AuthDemoPage extends StatefulWidget {
  const AuthDemoPage({super.key, required this.tokenStore});

  final AuthTokenStore tokenStore;

  @override
  State<AuthDemoPage> createState() => _AuthDemoPageState();
}

class _AuthDemoPageState extends State<AuthDemoPage> {
  final _accessController = TextEditingController();
  final _refreshController = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _accessController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _saveTokens() async {
    final saved = await widget.tokenStore.saveTokens(
      accessToken: _accessController.text,
      refreshToken: _refreshController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _message = saved
          ? 'Tokens saved to encrypted local storage.'
          : 'Both tokens are required. Blank values were rejected.';
    });
  }

  Future<void> _reloadTokens() async {
    final tokens = await widget.tokenStore.reload();

    if (!mounted) {
      return;
    }

    setState(() {
      _message = tokens == null
          ? 'No valid tokens found in storage.'
          : 'Valid persisted tokens loaded from storage.';
    });
  }

  Future<void> _clearTokens() async {
    await widget.tokenStore.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      _message = 'Stored tokens cleared.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Persistence Demo')),
      body: SafeArea(
        child: ValueListenableBuilder<AuthTokens?>(
          valueListenable: widget.tokenStore,
          builder: (context, tokens, _) {
            final hasTokens = tokens != null;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Encrypted token storage using Hive + flutter_secure_storage',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  hasTokens
                      ? 'Startup state: valid tokens are loaded.'
                      : 'Startup state: no valid tokens are stored.',
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _accessController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Access token',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _refreshController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Refresh token',
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton(
                      onPressed: _saveTokens,
                      child: const Text('Save'),
                    ),
                    OutlinedButton(
                      onPressed: _reloadTokens,
                      child: const Text('Reload'),
                    ),
                    TextButton(
                      onPressed: _clearTokens,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stored token summary',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasTokens
                              ? 'Access token present (${tokens.accessToken.length} chars)'
                              : 'Access token absent',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasTokens
                              ? 'Refresh token present (${tokens.refreshToken.length} chars)'
                              : 'Refresh token absent',
                        ),
                      ],
                    ),
                  ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 16),
                  Text(_message!),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
