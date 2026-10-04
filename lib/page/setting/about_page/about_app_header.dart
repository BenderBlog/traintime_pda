// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watermeter/model/about_page.dart';
import 'package:watermeter/page/public_widget/app_icon.dart';

class AboutAppHeader extends StatelessWidget {
  const AboutAppHeader({
    super.key,
    required this.applicationName,
    required this.applicationVersion,
  });

  final String applicationName;
  final String applicationVersion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const AppIconWidget(size: 80),
            const SizedBox(height: 16),
            Text(
              applicationName,
              textAlign: TextAlign.center,
              style: theme.emphasizedTextTheme.headlineMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NOEL Edition',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              applicationVersion,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final link in linkData)
                  M3EButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(link.url),
                      mode: LaunchMode.externalApplication,
                    ),
                    style: M3EButtonStyle.tonal,
                    icon: Icon(link.icon),
                    label: Text(link.resolve(context.t)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
