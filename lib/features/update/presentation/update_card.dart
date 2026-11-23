// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/core/presentation/grid_page/grid_page_card_interface.dart';
import 'package:watermeter/generated/translations.g.dart';

import '../application/update_checker.dart';
import 'update_dialog.dart';

class UpdateCard implements GridPageCardInterface {
  const UpdateCard(this._notices);

  final UpdateNotices _notices;

  @override
  String get id => 'update';

  @override
  int flex() => 1;

  @override
  String title(BuildContext context) => context.t.settings.checkUpdate;

  @override
  Widget buildCard(BuildContext context, bool editMode) {
    return SignalBuilder(
      builder: (context) {
        final state = _notices.state.value;
        final ready = switch (state) {
          UpdateNoticeReady ready => ready,
          UpdateNoticeLoading(:final previous) => previous,
          UpdateNoticeFailure() => null,
        };
        final text = switch (ready?.status) {
          UpdateStatus.available => context.t.settings.newVersion,
          UpdateStatus.current => context.t.settings.currentStable,
          UpdateStatus.testing => context.t.settings.currentTesting,
          null when state is UpdateNoticeFailure =>
            context.t.settings.fetchFailed,
          null => context.t.settings.fetchingUpdate,
        };
        return Card(
          child: InkWell(
            onTap: editMode || ready?.status != UpdateStatus.available
                ? null
                : () => showDialog<void>(
                    context: context,
                    builder: (context) => UpdateDialog(release: ready!.release),
                  ),
            child: Center(child: Text(text)),
          ),
        );
      },
    );
  }
}
