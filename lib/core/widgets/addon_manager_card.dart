import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:it_feels_music/data/services/addon_manager.dart';

class AddonManagerCard extends StatefulWidget {
  const AddonManagerCard({super.key});

  @override
  State<AddonManagerCard> createState() => _AddonManagerCardState();
}

class _AddonManagerCardState extends State<AddonManagerCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AddonManager().hasPlugins) {
        Clipboard.setData(const ClipboardData(
          text: 'https://raw.githubusercontent.com/Allrounder687/it-feels-provider-backend/main/backend_addon.js',
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AddonManager().hasPluginsNotifier,
      builder: (context, hasPlugins, child) {
        if (hasPlugins) {
          return const SizedBox.shrink(); 
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
                  Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Experience the Magic',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'IT-Feels is a neutral media player. We\'ve prepared a magic link in your clipboard! Just hit Paste & Install below to instantly unlock the full experience.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  final url = data?.text?.trim() ?? '';
                  if (url.isNotEmpty && url.startsWith('http')) {
                    final success = await AddonManager().installPluginFromUrl(url, 'custom_addon.js');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Magic successfully unlocked!' : 'Failed to install from clipboard'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      _showUrlInstallDialog(context);
                    }
                  }
                },
                icon: const Icon(Icons.content_paste_rounded, size: 18),
                label: const Text('Paste & Install'),
              ),
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
