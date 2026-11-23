// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/core/presentation/app_shell/app_shell_page_interface.dart';
import 'package:watermeter/core/shared/const.dart' show sheetMaxWidth;
import 'package:watermeter/generated/translations.g.dart';

class SettingsPage extends StatelessWidget implements AppShellPageInterface {
  const SettingsPage({super.key, required this.sections});

  final List<Widget> sections;

  @override
  String label(BuildContext context) => context.t.settings.title;

  @override
  Widget icon(BuildContext context) =>
      const Icon(MingCuteIcons.mgc_user_2_line);

  @override
  Widget selectedIcon(BuildContext context) =>
      const Icon(MingCuteIcons.mgc_user_2_fill);

  @override
  Widget buildPage(BuildContext context) => this;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Text(context.t.settings.title),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: sheetMaxWidth),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          physics: const ClampingScrollPhysics(),
          children: sections,
        ),
      ),
    ),
  );
}
