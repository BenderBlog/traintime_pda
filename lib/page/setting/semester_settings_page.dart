// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/controller/semester_controller.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/setting/setting_choice_control.dart';
import 'package:watermeter/page/public_widget/setting/setting_control_tile.dart';
import 'package:watermeter/page/public_widget/setting/setting_dropdown_button.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/repository/preference.dart' as pref;
import 'package:flutter_i18n/flutter_i18n.dart' as i18n;
import 'package:watermeter/repository/logger.dart' as log;

class SemesterSettingsPage extends StatefulWidget {
  const SemesterSettingsPage({super.key});

  @override
  State<SemesterSettingsPage> createState() => _SemesterSettingsPageState();
}

class _SemesterSettingsPageState extends State<SemesterSettingsPage> {
  late int selectedYear;
  late int selectedSemester;
  late List<int> years;
  bool _isFetching = false;
  bool _isApplying = false;
  bool get _busy => _isFetching || _isApplying;

  @override
  void initState() {
    super.initState();

    final int currentYear = DateTime.now().year;
    selectedYear = currentYear;
    years = List.generate(currentYear - 2015, (index) => 2016 + index);

    String semesterCode = pref.getString(pref.Preference.currentSemester);
    if (semesterCode.length == 5) {
      selectedYear = int.tryParse(semesterCode.substring(0, 4)) ?? currentYear;
      selectedSemester = int.tryParse(semesterCode.substring(4)) ?? 1;
    } else if (semesterCode.length == 11) {
      List<String> splitCode = semesterCode.split("-");
      if (splitCode.length < 3) {
        selectedSemester = 1;
      } else {
        selectedYear = int.tryParse(splitCode.first) ?? currentYear;
        selectedSemester = int.tryParse(splitCode.last) ?? 1;
      }
    } else {
      selectedSemester = 1;
    }
    if (!years.contains(selectedYear)) {
      years.add(selectedYear);
      years.sort();
    }
    selectedSemester = selectedSemester == 2 ? 2 : 1;
  }

  void _applySemesterCode(String semesterCode) {
    if (!mounted) return;
    if (semesterCode.length == 5) {
      final y = int.tryParse(semesterCode.substring(0, 4));
      final s = int.tryParse(semesterCode.substring(4));
      if (y != null && (s == 1 || s == 2) && years.contains(y)) {
        setState(() {
          selectedYear = y;
          selectedSemester = s!;
        });
      }
    } else if (semesterCode.length == 11) {
      final parts = semesterCode.split("-");
      if (parts.length >= 3) {
        final y = int.tryParse(parts.first);
        final s = int.tryParse(parts.last);
        if (y != null && (s == 1 || s == 2) && years.contains(y)) {
          setState(() {
            selectedYear = y;
            selectedSemester = s!;
          });
        }
      }
    }
  }

  Future<void> _fetchRemoteSemester() async {
    if (_busy) return;
    setState(() {
      _isFetching = true;
    });
    try {
      final remoteSemester = await SemesterController.i.fetchRemoteSemester();
      log.log.info(
        "[SemesterSettingsPage] Fetched remote semester: $remoteSemester",
      );
      _applySemesterCode(remoteSemester);
    } catch (e, s) {
      log.log.handle(e, s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              i18n.FlutterI18n.translate(context, 'error_detected'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  Future<void> _apply() async {
    if (_busy) return;
    setState(() => _isApplying = true);
    try {
      String semester = selectedYear.toString();
      if (!pref.getBool(pref.Preference.role)) {
        semester += '-${selectedYear + 1}-';
      }
      semester += selectedSemester.toString();
      final didChange = await SemesterController.i.setSemesterDirectly(
        semester,
      );
      if (mounted) Navigator.pop(context, didChange);
    } catch (e, s) {
      log.log.handle(e, s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              i18n.FlutterI18n.translate(context, 'error_detected'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: i18n.I18nText('classtable.semester_switcher.choose_semester'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: sheetMaxWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                Text(
                  i18n.FlutterI18n.translate(
                    context,
                    'classtable.semester_switcher.only_future_hint',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                SettingSegmentedList(
                  items: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SettingDropdownButton<int>(
                        value: selectedYear,
                        label: i18n.FlutterI18n.translate(
                          context,
                          'setting.editor.year',
                        ),
                        entries: years
                            .map(
                              (year) => DropdownMenuEntry<int>(
                                value: year,
                                label: i18n.FlutterI18n.translate(
                                  context,
                                  'classtable.semester_switcher.year',
                                  translationParams: {'year': '$year'},
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _busy
                            ? null
                            : (year) {
                                if (year != null) {
                                  setState(() => selectedYear = year);
                                }
                              },
                      ),
                    ),
                    SettingControlTile(
                      title: i18n.FlutterI18n.translate(
                        context,
                        'setting.editor.semester',
                      ),
                      child: AbsorbPointer(
                        absorbing: _busy,
                        child: SettingChoiceControl<int>(
                          value: selectedSemester,
                          options: [
                            SettingChoiceOption(
                              value: 1,
                              label: i18n.FlutterI18n.translate(
                                context,
                                'classtable.semester_switcher.first_academic_year',
                              ),
                            ),
                            SettingChoiceOption(
                              value: 2,
                              label: i18n.FlutterI18n.translate(
                                context,
                                'classtable.semester_switcher.second_academic_year',
                              ),
                            ),
                          ],
                          onChanged: (semester) {
                            if (!_busy) {
                              setState(() => selectedSemester = semester);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _fetchRemoteSemester,
                  icon: _isFetching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_download_outlined),
                  label: Text(
                    i18n.FlutterI18n.translate(
                      context,
                      _isFetching
                          ? 'classtable.semester_switcher.fetching_remote_semester'
                          : 'classtable.semester_switcher.fetch_remote_semester',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _busy ? null : _apply,
                  child: _isApplying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          i18n.FlutterI18n.translate(
                            context,
                            'setting.editor.apply',
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
