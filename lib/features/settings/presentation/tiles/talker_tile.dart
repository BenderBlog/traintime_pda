// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart' as legacy;
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/core/presentation/app_shell/app_shell.dart';
import 'package:watermeter/generated/translations.g.dart';

ListTile talkerTile(BuildContext context, Talker talker) {
  return ListTile(
    leading: const Icon(MingCuteIcons.mgc_document_line),
    title: Text(context.t.settings.checkLogger),
    trailing: const Icon(Icons.navigate_next),
    onTap: () => AppShell.of(context).pushDetail(
      Builder(
        builder: (context) => TalkerScreen(
          talker: talker,
          theme: TalkerScreenTheme.fromTheme(legacy.Theme.of(context)),
        ),
      ),
    ),
  );
}
