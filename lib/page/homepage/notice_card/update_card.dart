// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/update_notice_controller.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';
import 'package:watermeter/page/setting/dialogs/update_dialog.dart';
import 'package:watermeter/generated/l10n.dart';

class UpdateCard extends StatelessWidget {
  const UpdateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final state = UpdateNoticeController.i.updateMessageStateSignal.value;
        if (state.isLoading || state.isRefreshing) {
          return Text(I18n.of(context)!.settingFetchingUpdate)
              .paddingDirectional(horizontal: 16, vertical: 14)
              .withHomeCardStyle(context);
        } else if (state.hasError) {
          return Text(I18n.of(context)!.settingFetchFailed)
              .paddingDirectional(horizontal: 16, vertical: 14)
              .withHomeCardStyle(context);
        } else {
          switch (UpdateNoticeController
              .i
              .isNewVersionAvaliableComputed
              .value) {
            case null:
              return Text(
                    I18n.of(context)!.settingCurrentTesting,
                  )
                  .paddingDirectional(horizontal: 16, vertical: 14)
                  .withHomeCardStyle(context);
            case true:
              return Text(I18n.of(context)!.settingNewVersion)
                  .paddingDirectional(horizontal: 16, vertical: 14)
                  .withHomeCardStyle(
                    context,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            UpdateDialog(updateMessage: state.value!),
                      );
                    },
                  );
            case false:
              return SizedBox(height: 0);
          }
        }
      },
    );
  }
}
