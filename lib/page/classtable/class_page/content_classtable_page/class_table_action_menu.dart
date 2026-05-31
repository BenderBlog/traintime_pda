// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

part of '../content_classtable_page.dart';

class ClassTableActionMenu extends StatelessWidget {
  final ClassTableWidgetState classTableState;
  final VoidCallback onVisualSettingsChanged;

  const ClassTableActionMenu({
    super.key,
    required this.classTableState,
    required this.onVisualSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
        _menuItem(context, 'A', "classtable.popup_menu.not_arranged"),
        _menuItem(context, 'B', "classtable.popup_menu.class_changed"),
        _menuItem(context, 'C', "classtable.popup_menu.add_class"),
        _menuItem(context, 'D', "classtable.popup_menu.generate_ical"),
        _menuItem(context, 'H', "classtable.popup_menu.output_to_system"),
        _menuItem(context, 'I', "classtable.popup_menu.refresh_classtable"),
        _menuItem(context, 'J', "classtable.popup_menu.current_time_settings"),
        _menuItem(context, 'K', "classtable.popup_menu.class_color_settings"),
      ],
      onSelected: (action) => _handleAction(context, action),
    );
  }

  PopupMenuItem<String> _menuItem(
    BuildContext context,
    String value,
    String translationKey,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(FlutterI18n.translate(context, translationKey)),
    );
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    switch (action) {
      case 'A':
        await _openNotArrangedClasses(context);
        break;
      case 'B':
        await _openClassChanges(context);
        break;
      case 'C':
        await _addClass(context);
        break;
      case 'D':
        await _exportICalendar(context);
        break;
      case 'H':
        await _outputToSystemCalendar(context);
        break;
      case 'I':
        await _refreshClassTable(context);
        break;
      case 'J':
        if (await showCurrentTimeSettingsDialog(context)) {
          onVisualSettingsChanged();
        }
        break;
      case 'K':
        if (await showClassColorSettingsDialog(context)) {
          onVisualSettingsChanged();
        }
        break;
    }
  }

  Future<void> _openNotArrangedClasses(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            NotArrangedClassList(notArranged: classTableState.notArranged),
      ),
    );
  }

  Future<void> _openClassChanges(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ClassChangeList(classChanges: classTableState.classChange),
      ),
    );
  }

  Future<void> _addClass(BuildContext context) async {
    final data = await Navigator.of(context)
        .push<(ClassDetail, TimeArrangement)>(
          MaterialPageRoute(
            builder: (context) =>
                ClassAddWindow(semesterLength: classTableState.semesterLength),
          ),
        );
    if (context.mounted && data != null) {
      await classTableState.addUserDefinedClass(data.$1, data.$2);
    }
  }

  Future<void> _exportICalendar(BuildContext context) async {
    try {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            FlutterI18n.translate(
              context,
              "classtable.partner_classtable.share_dialog.title",
            ),
          ),
          content: Text(
            FlutterI18n.translate(
              context,
              "classtable.partner_classtable.share_dialog.content",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(FlutterI18n.translate(context, "confirm")),
            ),
          ],
        ),
      );
      if (!context.mounted) return;

      final fileName =
          "classtable-"
          "${DateFormat("yyyyMMddTHHmmss").format(DateTime.now())}-"
          "${classTableState.semesterCode}"
          ".ics";
      await FilePicker.saveFile(
        dialogTitle: FlutterI18n.translate(
          context,
          "classtable.partner_classtable.save_dialog.title",
        ),
        fileName: fileName,
        allowedExtensions: ["ics"],
        bytes: Uint8List.fromList(classTableState.iCalenderStr.codeUnits),
        lockParentWindow: true,
      );
      if (context.mounted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            "classtable.partner_classtable.save_dialog.success_message",
          ),
        );
      }
    } on FileSystemException {
      if (context.mounted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            "classtable.partner_classtable.save_dialog.failure_message",
          ),
        );
      }
    }
  }

  Future<void> _outputToSystemCalendar(BuildContext context) async {
    final didOutput = await classTableState.outputToCalendar(() async {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            FlutterI18n.translate(
              context,
              "classtable.output_to_system.request_all_title",
            ),
          ),
          content: Text(
            FlutterI18n.translate(
              context,
              "classtable.output_to_system.request_all",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(FlutterI18n.translate(context, "confirm")),
            ),
          ],
        ),
      );
    });

    if (context.mounted) {
      showToast(
        context: context,
        msg: FlutterI18n.translate(
          context,
          didOutput
              ? "classtable.output_to_system.success"
              : "classtable.output_to_system.failure",
        ),
      );
    }
  }

  Future<void> _refreshClassTable(BuildContext context) async {
    final isAccepted =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              FlutterI18n.translate(context, "setting.class_refresh_title"),
            ),
            content: Text(
              FlutterI18n.translate(context, "setting.class_refresh_content"),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () => Navigator.pop(context, false),
                child: Text(FlutterI18n.translate(context, "cancel")),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(FlutterI18n.translate(context, "confirm")),
              ),
            ],
          ),
        ) ??
        false;

    if (context.mounted && isAccepted) {
      await classTableState.updateClasstable(context);
      if (context.mounted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            "classtable.refresh_classtable.success",
          ),
        );
      }
    }
  }
}
