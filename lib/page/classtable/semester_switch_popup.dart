import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/classtable/class_add/wheel_choser.dart';
import 'package:flutter_i18n/flutter_i18n.dart' as i18n;

void semesterSwitchDialog(
  BuildContext context,
  void Function(int year, int semester) onConfirm,
) {
  final int currentYear = DateTime.now().year;

  final List<int> years = List.generate(
    currentYear - 2015,
    (index) => 2016 + index,
  );

  int selectedYear = currentYear;
  int selectedSemester = 1;

  try {
    ClassTableController classTableController =
        Get.find<ClassTableController>();
    String semesterCode = classTableController.classTableData.semesterCode;
    if (semesterCode.length == 5) {
      selectedSemester = int.parse(semesterCode.substring(4, 5));
    }
  } catch (e) {
    // Ignored, use default
  }

  final List<WheelChooseOptions<int>> yearOptions = years
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

  final List<WheelChooseOptions<int>> semesterOptions = [
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

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: i18n.I18nText('classtable.semester_switcher.choose_semester'),
        content: SizedBox(
          height: 150,
          width: double.maxFinite,
          child: Row(
            children: [
              // Year Picker
              Expanded(
                child: WheelChoose<int>(
                  defaultPage: years.indexOf(selectedYear) == -1
                      ? years.length - 1
                      : years.indexOf(selectedYear),
                  options: yearOptions,
                  changeBookIdCallBack: (res) {
                    selectedYear = res;
                  },
                ),
              ),
              // Semester Picker
              Expanded(
                child: WheelChoose<int>(
                  defaultPage: selectedSemester - 1,
                  options: semesterOptions,
                  changeBookIdCallBack: (res) {
                    selectedSemester = res;
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: i18n.I18nText('cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm(selectedYear, selectedSemester);
              Navigator.of(context).pop();
            },
            child: i18n.I18nText('confirm'),
          ),
        ],
      );
    },
  );
}
