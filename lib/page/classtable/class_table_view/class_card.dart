import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/class_detail/class_detail.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/widget.dart';

class ClassCard extends StatelessWidget {
  final int index;
  final Set<int> conflict;
  final double height;
  const ClassCard({
    super.key,
    required this.height,
    required this.index,
    required this.conflict,
  });

  @override
  Widget build(BuildContext context) {
    ClassTableState classTableState = ClassTableState.of(context)!;

    Widget inside = index == -1
        ? const Padding(
            padding: EdgeInsets.all(1.5),
            // Easter egg, usless you read the code, or reverse engineering...
            child: Center(
              child: Text(
                "BOCCHI RULES!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.transparent,
                  letterSpacing: 1,
                ),
              ),
            ),
          )
        : TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.resolveWith(
                (status) => EdgeInsets.zero,
              ),
              overlayColor: MaterialStateProperty.resolveWith(
                (status) => Colors.transparent,
              ),
            ),
            onPressed: () {
              Widget toShow = Center(
                child: ClassDetail(
                  classDetail:
                      List.from(ClassTableState.of(context)!.classDetail),
                  information: List.generate(
                    conflict.length,
                    (index) => ClassTableState.of(context)!
                        .timeArrangement[conflict.elementAt(index)],
                  ),
                  currentWeek: ClassTableState.of(context)!.currentWeek,
                ),
              );
              showDialog(
                builder: (context) => toShow,
                context: context,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(1.5),
              child: Center(
                child: Text(
                  "${classTableState.classDetail[classTableState.timeArrangement[index].index].name}\n"
                  "${classTableState.timeArrangement[index].classroom}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: index != -1
                        ? colorList[
                                classTableState.timeArrangement[index].index %
                                    colorList.length]
                            .shade900
                        : Colors.white,
                  ),
                ),
              ),
            ),
          );

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ClipRRect(
          // Out
          borderRadius: BorderRadius.circular(10),
          child: Container(
            // Border
            color: index == -1
                ? const Color(0x00000000)
                : colorList[classTableState.timeArrangement[index].index %
                        colorList.length]
                    .shade300
                    .withOpacity(0.75),
            padding: conflict.length == 1
                ? const EdgeInsets.all(1.5)
                : const EdgeInsets.fromLTRB(1, 1, 1, 8),
            child: ClipRRect(
              // Inner
              borderRadius: BorderRadius.circular(8.5),
              child: Container(
                color: index == -1
                    ? const Color(0x00000000)
                    : colorList[classTableState.timeArrangement[index].index %
                            colorList.length]
                        .shade100
                        .withOpacity(0.7),
                child: inside,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
