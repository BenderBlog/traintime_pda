import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

class ClassTablePageView extends StatefulWidget {
  const ClassTablePageView({super.key});

  @override
  State<ClassTablePageView> createState() => _ClassTablePageViewState();
}

class _ClassTablePageViewState extends State<ClassTablePageView> {
  late ClassTableState classTableState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    classTableState = ClassTableState.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      controller: classTableState.controllers.pageControl,
      onPageChanged: (value) {
        if (!classTableState.controllers.isTopRowLocked) {
          setState(() {
            classTableState.controllers.chosenWeek = value;
          });
          classTableState.controllers.changeTopRow(value);
        }
        if (classTableState.controllers.chosenWeek == value) {
          classTableState.isTopRowLocked = false;
        }
      },
      itemCount: classTableState.semesterLength,
      itemBuilder: (context, index) => ClassTableView(index: index),
    );
  }
}
