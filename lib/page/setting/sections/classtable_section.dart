// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

part of '../setting_sections.dart';

class SettingClassTableSection extends StatelessWidget {
  final SettingActionsController actions;
  final VoidCallback onChanged;

  const SettingClassTableSection({
    super.key,
    required this.actions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ReXCard(
      title: buildSettingSectionTitle(
        FlutterI18n.translate(context, "setting.classtable_setting"),
      ),
      remaining: const [],
      bottomRow: Column(
        children: [
          ListTile(
            title: Text(FlutterI18n.translate(context, "setting.background")),
            trailing: Switch(
              value: preference.getBool(preference.Preference.decorated),
              onChanged: (bool value) {
                if (value &&
                    !preference.getBool(preference.Preference.decoration)) {
                  showToast(
                    context: context,
                    msg: FlutterI18n.translate(
                      context,
                      "setting.no_background",
                    ),
                  );
                  return;
                }
                preference.setBool(preference.Preference.decorated, value);
                onChanged();
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.choose_background"),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _chooseBackground(context),
          ),
          const Divider(),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.clear_user_class"),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _confirmClearUserClass(context),
          ),
          const Divider(),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.class_refresh"),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _confirmRefreshClassData(context),
          ),
          const Divider(),
          ListTile(
            title: Text(FlutterI18n.translate(context, "setting.class_swift")),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                "setting.class_swift_description",
                translationParams: {
                  "swift": preference
                      .getInt(preference.Preference.swift)
                      .toString(),
                },
              ),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => ChangeSwiftDialog(),
              ).then((value) => onChanged());
            },
          ),
          const Divider(),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.semester_change"),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                "setting.semester_change_description",
                translationParams: {
                  "semester": preference.getString(
                    preference.Preference.currentSemester,
                  ),
                },
              ),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _changeSemester(context),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseBackground(BuildContext context) async {
    PlatformFile? result;
    try {
      result = await pickFile(type: FileType.image);
    } on MissingStoragePermissionException {
      if (context.mounted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(context, "setting.no_permission"),
        );
      }
    }
    if (result != null) {
      File(
        result.path!,
      ).copySync("${supportPath.path}/${ClassTableController.decorationName}");
      preference.setBool(preference.Preference.decoration, true);
      if (context.mounted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(context, "setting.successful_setting"),
        );
      }
      return;
    }
    if (context.mounted) {
      showToast(
        context: context,
        msg: FlutterI18n.translate(context, "setting.failure_setting"),
      );
    }
  }

  Future<void> _confirmClearUserClass(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          FlutterI18n.translate(context, "setting.clear_user_class_title"),
        ),
        content: Text(
          FlutterI18n.translate(context, "setting.clear_user_class_content"),
        ),
        actions: [
          _CancelButton(),
          TextButton(
            onPressed: () {
              actions.clearUserDefinedClasses();
              onChanged();
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
      ),
    );
  }

  Future<void> _confirmRefreshClassData(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          FlutterI18n.translate(context, "setting.class_refresh_title"),
        ),
        content: Text(
          FlutterI18n.translate(context, "setting.class_refresh_content"),
        ),
        actions: [
          _CancelButton(),
          TextButton(
            onPressed: () async {
              await actions.refreshSemesterAwareData();
              onChanged();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(FlutterI18n.translate(context, "confirm")),
          ),
        ],
      ),
    );
  }

  Future<void> _changeSemester(BuildContext context) async {
    final changed = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) => SemesterSwitchDialog(),
    );
    if (changed != true) return;
    onChanged();
    if (context.mounted) {
      showToast(context: context, msg: "Updating data");
    }
    await actions.waitForSemesterAwareReloads();
    await actions.autoSyncSystemCalendarIfNeeded();
    onChanged();
  }
}
