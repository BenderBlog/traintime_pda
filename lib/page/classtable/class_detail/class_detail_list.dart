import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/class_detail/class_detail_dialog.dart';
import 'package:watermeter/page/classtable/class_detail/class_detail_state.dart';
import 'package:watermeter/page/widget.dart';

class ClassDetailList extends StatelessWidget {
  const ClassDetailList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ClassDetailState classDetailState = ClassDetailState.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        classDetailState.information.length,
        (i) => ClassDetailDialog(
          classDetail: classDetailState
              .classDetail[classDetailState.information[i].index],
          timeArrangement: classDetailState.information[i],
          infoColor: colorList[classDetailState.information[i].index],
          currentWeek: classDetailState.currentWeek,
        ),
      ),
    );
  }
}
