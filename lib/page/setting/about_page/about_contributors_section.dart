// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watermeter/model/about_page.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';

class AboutContributorsSection extends StatefulWidget {
  const AboutContributorsSection({super.key});

  @override
  State<AboutContributorsSection> createState() =>
      _AboutContributorsSectionState();
}

class _AboutContributorsSectionState extends State<AboutContributorsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SectionSettingScaffold(
      title: FlutterI18n.translate(context, 'setting.about_page.contributors'),
      icon: Icons.favorite_border_rounded,
      items: M3EExpandableSegmentedItem(
        index: 0,
        totalCount: 1,
        isExpanded: _expanded,
        onToggle: () => setState(() => _expanded = !_expanded),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childPadding: EdgeInsets.zero,
        color: colors.surfaceContainer,
        childColor: colors.surfaceContainer,
        header: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.people_outline_rounded),
          title: Text(
            FlutterI18n.translate(
              context,
              'setting.acknowledgement',
              translationParams: {
                'developers': getDevelopers.length.toString(),
              },
            ),
          ),
        ),
        childCount: getDevelopers.length,
        onChildTap: (index) => launchUrl(
          Uri.parse(getDevelopers[index].url),
          mode: LaunchMode.externalApplication,
        ),
        childBuilder: (context, index) {
          final developer = getDevelopers[index];
          return ListTile(
            leading: ClipOval(
              child: CachedNetworkImage(
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                imageUrl: developer.imageUrl,
                placeholder: (context, url) => const Icon(Icons.person_outline),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.person_outline),
              ),
            ),
            title: Text(developer.name),
            subtitle: Text(
              FlutterI18n.translate(context, developer.descriptionI18nKey),
            ),
            trailing: const Icon(Icons.open_in_new_rounded, size: 20),
          );
        },
      ),
    );
  }
}
