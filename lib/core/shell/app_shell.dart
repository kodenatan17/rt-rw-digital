import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../module_registry/module_registry.dart';
import 'shell_version.dart';

class AppShell extends StatelessWidget {
  final ModuleRegistry registry;
  final Widget child;

  const AppShell({
    super.key,
    required this.registry,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final modules = registry.enabledModules
        .where((m) => registry.isVisible(m.name))
        .toList();

    return Scaffold(
      body: child,
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'RT-RW Digital',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v${shellVersion.asString}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/');
              },
            ),
            const Divider(),
            ...modules.map((module) => ListTile(
                  leading: const Icon(Icons.widgets_outlined),
                  title: Text(module.displayName),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/${module.name}');
                  },
                )),
          ],
        ),
      ),
    );
  }
}
