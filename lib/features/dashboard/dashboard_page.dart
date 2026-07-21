import 'package:authentication_module/presentation/bloc/auth_bloc.dart';
import 'package:authentication_module/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth_token_store.dart';
import '../../core/module_registry/module_registry.dart';

class DashboardPage extends StatelessWidget {
  final ModuleRegistry registry;
  final AuthTokenStore? tokenStore;
  final VoidCallback? onLogout;

  const DashboardPage({
    super.key,
    required this.registry,
    this.tokenStore,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final modules = registry.enabledModules
        .where((m) => registry.isVisible(m.name))
        .toList();
    final authState = context.watch<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RT-RW Digital'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (authState is AuthAuthenticated)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  authState.user.name,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: onLogout,
          ),
        ],
      ),
      body: modules.isEmpty
          ? const Center(child: Text('No modules enabled'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return Card(
                  child: InkWell(
                    onTap: () => context.go('/${module.name}'),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.widgets, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            module.displayName,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'v${module.version.asString}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
