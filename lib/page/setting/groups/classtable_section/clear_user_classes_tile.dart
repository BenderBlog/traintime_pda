// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/controller/custom_class_controller.dart';
import 'package:watermeter/page/public_widget/toast.dart';

class ClearUserClassesTile extends StatelessWidget {
  const ClearUserClassesTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(MingCuteIcons.mgc_delete_2_line),
      title: Text(FlutterI18n.translate(context, "setting.clear_user_class")),
      trailing: const Icon(Icons.navigate_next),
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => const _ClearUserClassesDialog(),
      ),
    );
  }
}

class _ClearUserClassesDialog extends StatelessWidget {
  const _ClearUserClassesDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        FlutterI18n.translate(context, "setting.clear_user_class_title"),
      ),
      content: Text(
        FlutterI18n.translate(context, "setting.clear_user_class_content"),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(FlutterI18n.translate(context, "cancel")),
        ),
        TextButton(
          onPressed: () async {
            await CustomClassController.i.clearAll();
            if (!context.mounted) return;
            showToast(
              context: context,
              msg: FlutterI18n.translate(
                context,
                "setting.clear_user_class_clear",
              ),
            );
            Navigator.pop(context);
          },
          child: Text(FlutterI18n.translate(context, "confirm")),
        ),
      ],
    );
  }
}
