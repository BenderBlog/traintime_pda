// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';

/// A setting with its control below a flexible title and current value.
class SettingControlTile extends StatelessWidget {
  const SettingControlTile({
    super.key,
    required this.title,
    required this.child,
    this.leading,
    this.valueLabel,
    this.description,
    this.enabled = true,
  });

  final String title;
  final Widget child;
  final IconData? leading;
  final String? valueLabel;
  final String? description;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = enabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                Icon(leading, color: foreground),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyLarge,
                        children: [
                          TextSpan(
                            text: title,
                            style: TextStyle(color: foreground),
                          ),
                          if (valueLabel != null) ...[
                            TextSpan(
                              text: " · ${valueLabel!}",
                              style: TextStyle(
                                color: enabled
                                    ? theme.colorScheme.primary
                                    : foreground,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (description != null)
                      Text(
                        description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: enabled
                              ? theme.colorScheme.onSurfaceVariant
                              : foreground,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
