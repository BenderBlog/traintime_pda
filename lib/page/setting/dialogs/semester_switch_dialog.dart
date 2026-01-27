import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/wheel_choser.dart';
import 'package:flutter_i18n/flutter_i18n.dart' as i18n;
import 'package:watermeter/repository/semester_info.dart';

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

  @override
  void initState() {
    super.initState();

    final int currentYear = DateTime.now().year;
    selectedYear = currentYear;
    years = List.generate(currentYear - 2015, (index) => 2016 + index);

    String semesterCode = getSemester();
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: i18n.I18nText('classtable.semester_switcher.choose_semester'),
      content: SizedBox(
        height: 150,
        width: double.maxFinite,
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
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: i18n.I18nText('cancel'),
        ),
        TextButton(
          onPressed: () async {
            /// TODO: Add evaluation, if the setting is unchanged or is the same as current semester, do not set.
            await setUserSemester(selectedYear, selectedSemester);
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          child: i18n.I18nText('confirm'),
        ),
      ],
    );
  }
}
