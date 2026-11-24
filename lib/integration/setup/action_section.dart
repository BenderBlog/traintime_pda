import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/core/presentation/app_shell/app_shell.dart';
import 'package:watermeter/core/presentation/settings_page/settings_page_section_interface.dart';
import 'package:watermeter/features/settings/presentation/about_page/about_page.dart';
import 'package:watermeter/generated/application_version.g.dart';
import 'package:watermeter/generated/translations.g.dart';

class AboutSection implements SettingsPageSectionInterface {
  const AboutSection(this.updateTile);

  final SettingsPageSectionEntry Function(BuildContext) updateTile;

  @override
  IconData? icon() => null;

  @override
  List<SettingsPageSectionEntry> items(BuildContext context) => <ListTile>[
    ListTile(
      leading: const Icon(MingCuteIcons.mgc_information_line),
      title: Text(context.t.settings.aboutThisProgram),
      subtitle: Text(
        context.t.settings.version(
          version: "$kApplicationVersion + $kApplicationBuildNumber",
        ),
      ),
      trailing: const Icon(Icons.navigate_next),
      onTap: () => AppShell.of(context).pushDetail(AboutPage()),
    ),
    updateTile(context),
  ];

  @override
  String? title() => null;
}
