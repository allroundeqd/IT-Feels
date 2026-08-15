import 'package:flutter/material.dart';

import 'package:it_feels_music/data/services/addon_manager.dart';

class AddonManagerCard extends StatelessWidget {
  const AddonManagerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AddonManager().hasPluginsNotifier,
      builder: (context, hasPlugins, child) {
        if (hasPlugins) {
          return const SizedBox.shrink(); // Hide if already installed to keep UI clean, or show a tiny badge
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.extension_rounded, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Enhance Your Experience',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'IT-Feels is a powerful neutral media player. To search and stream content, install community-developed provider addons.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      final success = await AddonManager().installDefaultPlugin();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Addon installed successfully!' : 'Failed to install addon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Install Default Addon'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      _showUrlInstallDialog(context);
                    },
                    icon: const Icon(Icons.link_rounded, size: 18),
                    label: const Text('Add from URL'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _showUrlInstallDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Install Addon from URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://...',
            labelText: 'Addon .js URL',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                final success = await AddonManager().installPluginFromUrl(url, 'custom_addon.js');
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Addon installed!' : 'Failed to install from URL'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Install'),
          ),
        ],
      ),
    );
  }
}
