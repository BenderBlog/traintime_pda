// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/core/presentation/settings_page/settings_page_section_interface.dart';
import 'package:watermeter/generated/translations.g.dart';

import '../application/update_checker.dart';
import 'update_dialog.dart';

class UpdateSection implements SettingsPageSectionInterface {
  const UpdateSection(this._notices);

  final UpdateNotices _notices;

  @override
  String? title() => null;

  @override
  IconData? icon() => null;

  @override
  List<SettingsPageSectionEntry> items(BuildContext context) {
    return [
      ListTile(
        leading: const Icon(MingCuteIcons.mgc_download_line),
        title: Text(context.t.settings.checkUpdate),
        subtitle: SignalBuilder(
          builder: (context) {
            final release = switch (_notices.state.value) {
              UpdateNoticeReady(:final release) => release,
              UpdateNoticeLoading(previous: final ready?) => ready.release,
              _ => null,
            };
            return Text(
              context.t.settings.latestVersion(
                latest: release?.code ?? context.t.settings.waiting,
              ),
            );
          },
        ),
        trailing: const Icon(Icons.navigate_next),
        onTap: () async {
          final result = await _notices.check();
          if (!context.mounted) return;
          final message = switch (result) {
            UpdateNoticeReady(status: UpdateStatus.available) => null,
            UpdateNoticeReady(status: UpdateStatus.current) =>
              context.t.settings.currentStable,
            UpdateNoticeReady(status: UpdateStatus.testing) =>
              context.t.settings.currentTesting,
            _ => context.t.settings.fetchFailed,
          };
          if (message != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
            return;
          }
          await showDialog<void>(
            context: context,
            builder: (context) =>
                UpdateDialog(release: (result as UpdateNoticeReady).release),
          );
        },
      ),
    ];
  }
}
