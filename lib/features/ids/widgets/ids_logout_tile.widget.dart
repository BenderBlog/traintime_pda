// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/features/ids/ids.dart';
import 'package:watermeter/generated/translations.g.dart';

ListTile idsLogoutTile(BuildContext context, IdsUseCase feature) {
  return ListTile(
    leading: const Icon(MingCuteIcons.mgc_exit_door_line),
    title: Text(context.t.ids.logout),
    trailing: const Icon(Icons.navigate_next),
    onTap: () => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(context.t.ids.logoutDialog.title),
        content: Text(context.t.ids.logoutDialog.content),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(context.t.common.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await feature.signOut();
                if (context.mounted) Navigator.pop(context);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.t.ids.logoutDialog.failed)),
                  );
                }
              }
            },
            child: Text(context.t.common.confirm),
          ),
        ],
      ),
    ),
  );
}
