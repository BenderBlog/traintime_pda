import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';

class ClassTableState extends InheritedWidget {
  final int semesterLength;
  final List<ClassDetail> classDetail;
  final List<ClassDetail> notArranged;
  final List<TimeArrangement> timeArrangement;
  final List<List<List<List<int>>>> pretendLayout;

  final DateTime startDay;
  final int currentWeek;

  late final ClassTableWidgetState controllers;

  bool get isTopRowLocked => controllers.isTopRowLocked;
  set isTopRowLocked(bool status) =>
      status ? controllers.lockTopRow() : controllers.unlockTopRow();

  ClassTableState({
    super.key,
    required super.child,
    required this.semesterLength,
    required this.startDay,
    required this.notArranged,
    required this.timeArrangement,
    required this.classDetail,
    required this.pretendLayout,
    required this.currentWeek,
  }) {
    late int toShowChoiceWeek;
    if (currentWeek < 0) {
      toShowChoiceWeek = 0;
    } else if (currentWeek >= semesterLength) {
      toShowChoiceWeek = semesterLength - 1;
    } else {
      toShowChoiceWeek = currentWeek;
    }
    controllers = ClassTableWidgetState(choiceWeek: toShowChoiceWeek);
  }

  static ClassTableState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClassTableState>();
  }

  @override
  bool updateShouldNotify(covariant ClassTableState oldWidget) {
    return controllers.chosenWeek != oldWidget.controllers.chosenWeek;
  }
}

class ClassTableWidgetState extends ChangeNotifier {
  late ScrollController rowControl;
  late PageController pageControl;
  late int chosenWeek;
  bool isTopRowLocked = false;

  void changeTopRow(int index) => rowControl.animateTo(
        (weekButtonWidth + 2 * weekButtonHorizontalPadding) * index,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: changePageTime ~/ 1.5),
      );

  ClassTableWidgetState({
    required int choiceWeek,
  }) {
    chosenWeek = choiceWeek;
    pageControl = PageController(
      initialPage: chosenWeek,
      keepPage: true,
    );
    rowControl = ScrollController(
      initialScrollOffset:
          (weekButtonWidth + 2 * weekButtonHorizontalPadding) * chosenWeek,
    );
  }

  void lockTopRow() => isTopRowLocked = true;

  void unlockTopRow() {
    isTopRowLocked = false;
    notifyListeners();
  }
}
