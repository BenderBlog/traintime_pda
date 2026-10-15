// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:watermeter/model/about_page.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/public_widget/setting/setting_expandable_section.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';

class AboutContributorsSection extends StatelessWidget {
  const AboutContributorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      title: context.t.setting.aboutPage.contributors,
      icon: Icons.favorite_border_rounded,
      items: SettingExpandableSection(
        header: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.people_outline_rounded),
          title: Text(
            context.t.setting.acknowledgement(
              developers: getDevelopers.length.toString(),
            ),
          ),
        ),
        onChildTap: (index) => launchUrl(
          Uri.parse(getDevelopers[index].url),
          mode: LaunchMode.externalApplication,
        ),
        children: [
          for (final developer in getDevelopers)
            ListTile(
              leading: ClipOval(
                child: CachedNetworkImage(
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  imageUrl: developer.imageUrl,
                  placeholder: (context, url) =>
                      const Icon(Icons.person_outline),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.person_outline),
                ),
              ),
              title: Text(developer.name),
              subtitle: Text(developer.description(context.t)),
              trailing: const Icon(Icons.open_in_new_rounded, size: 20),
            ),
        ],
      ),
    );
  }
}
