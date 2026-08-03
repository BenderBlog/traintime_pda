import 'package:flutter/material.dart';
import 'package:watermeter/controller/semester_controller.dart';
import 'package:watermeter/page/public_widget/wheel_choser.dart';
import 'package:watermeter/repository/preference.dart' as pref;
import 'package:flutter_i18n/flutter_i18n.dart' as i18n;
import 'package:watermeter/repository/logger.dart' as log;

class SemesterSwitchDialog extends StatefulWidget {
  const SemesterSwitchDialog({super.key});

  @override
  State<SemesterSwitchDialog> createState() => _SemesterSwitchDialogState();
}

class _SemesterSwitchDialogState extends State<SemesterSwitchDialog> {
  late int selectedYear;
  late int selectedSemester;
  late List<int> years;
  late List<WheelChooseOptions<int>> yearOptions;
  late List<WheelChooseOptions<int>> semesterOptions;
  bool _isFetching = false;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    yearOptions = years
        .map(
          (e) => WheelChooseOptions(
            data: e,
            hint: i18n.FlutterI18n.translate(
              context,
              'classtable.semester_switcher.year',
              translationParams: {'year': '$e'},
            ),
          ),
        )
        .toList();
    semesterOptions = [
      WheelChooseOptions(
        data: 1,
        hint: i18n.FlutterI18n.translate(
          context,
          'classtable.semester_switcher.first_academic_year',
        ),
      ),
      WheelChooseOptions(
        data: 2,
        hint: i18n.FlutterI18n.translate(
          context,
          'classtable.semester_switcher.second_academic_year',
        ),
      ),
    ];
  }

  void _applySemesterCode(String semesterCode) {
    if (!mounted) return;
    if (semesterCode.length == 5) {
      final y = int.tryParse(semesterCode.substring(0, 4));
      final s = int.tryParse(semesterCode.substring(4));
      if (y != null && s != null && years.contains(y)) {
        setState(() {
          selectedYear = y;
          selectedSemester = s;
        });
      }
    } else if (semesterCode.length == 11) {
      final parts = semesterCode.split("-");
      if (parts.length >= 3) {
        final y = int.tryParse(parts.first);
        final s = int.tryParse(parts.last);
        if (y != null && s != null && years.contains(y)) {
          setState(() {
            selectedYear = y;
            selectedSemester = s;
          });
        }
      }
    }
  }

  Future<void> _fetchRemoteSemester() async {
    setState(() {
      _isFetching = true;
    });
    try {
      final remoteSemester = await SemesterController.i.fetchRemoteSemester();
      log.log.info(
        "[SemesterSwitchDialog] Fetched remote semester: $remoteSemester",
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: i18n.I18nText('classtable.semester_switcher.choose_semester'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              i18n.FlutterI18n.translate(
                context,
                'classtable.semester_switcher.only_future_hint',
              ),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            AbsorbPointer(
              absorbing: _isFetching,
              child: SizedBox(
                height: 150,
                child: Row(
                  children: [
                    Expanded(
                      child: WheelChoose<int>(
                        defaultPage: !years.contains(selectedYear)
                            ? years.length - 1
                            : years.indexOf(selectedYear),
                        options: yearOptions,
                        changeBookIdCallBack: (res) {
                          setState(() {
                            selectedYear = res;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: WheelChoose<int>(
                        defaultPage: selectedSemester - 1,
                        options: semesterOptions,
                        changeBookIdCallBack: (res) {
                          setState(() {
                            selectedSemester = res;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isFetching ? null : _fetchRemoteSemester,
                icon: _isFetching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_download),
                label: Text(
                  _isFetching
                      ? i18n.FlutterI18n.translate(
                          context,
                          'classtable.semester_switcher.fetching_remote_semester',
                        )
                      : i18n.FlutterI18n.translate(
                          context,
                          'classtable.semester_switcher.fetch_remote_semester',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: i18n.I18nText('cancel'),
        ),
        TextButton(
          onPressed: _isFetching
              ? null
              : () async {
                  String semester = selectedYear.toString();
                  if (!pref.getBool(pref.Preference.role)) {
                    semester += "-${selectedYear + 1}-";
                  }
                  semester += selectedSemester.toString();
                  final didChange = await SemesterController.i
                      .setSemesterDirectly(semester);
                  if (context.mounted) {
                    Navigator.of(context).pop(didChange);
                  }
                },
          child: i18n.I18nText('confirm'),
        ),
      ],
    );
  }
}
