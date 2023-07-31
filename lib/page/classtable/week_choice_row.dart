import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

class WeekChoiceRow extends StatefulWidget {
  const WeekChoiceRow({super.key});

  @override
  State<WeekChoiceRow> createState() => _WeekChoiceRowState();
}

class _WeekChoiceRowState extends State<WeekChoiceRow> {
  late ClassTableState classTableState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    classTableState = ClassTableState.of(context)!;
    classTableState.controllers.addListener(() {
      setState(() {});
    });
  }

  Widget dot(bool isOccupied) {
    double opacity = !isOccupied ? 1 : 0.25;
    return ClipOval(
      child: Container(
        color: Theme.of(context).primaryColor.withOpacity(opacity),
      ),
    );
  }

  Widget buttonInformaion(int index) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AutoSizeText(
            "第${index + 1}周",
            style: TextStyle(
                fontWeight: index == classTableState.currentWeek
                    ? FontWeight.bold
                    : FontWeight.normal),
            maxLines: 1,
            textScaleFactor: 0.9,
            group: AutoSizeGroup(),
          ),
          if (MediaQuery.of(context).size.height >= 500)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                7.5,
                1.0,
                7.5,
                3.0,
              ),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 5,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                children: [
                  for (int i = 0; i < 10; i += 2)
                    for (int day = 0; day < 5; ++day)
                      dot(
                        classTableState.pretendLayout[index][day][i]
                            .contains(-1),
                      )
                ],
              ),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height >= 500
          ? topRowHeightBig
          : topRowHeightSmall,
      child: Container(
        padding: const EdgeInsets.only(
          top: 2,
          bottom: 5,
        ),
        child: ListView.builder(
          controller: classTableState.controllers.rowControl,
          scrollDirection: Axis.horizontal,
          itemCount: classTableState.semesterLength,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: weekButtonHorizontalPadding,
              ),
              child: SizedBox(
                width: weekButtonWidth,
                child: Card(
                  color: Theme.of(context).primaryColor.withOpacity(
                        classTableState.controllers.chosenWeek == index
                            ? 0.3
                            : 0.0,
                      ),
                  elevation: 0.0,
                  child: InkWell(
                    // The same as the Material 3 Card Radius.
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    splashColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    highlightColor:
                        Theme.of(context).primaryColor.withOpacity(0.3),
                    onTap: () {
                      classTableState.controllers.isTopRowLocked = true;
                      setState(() {
                        classTableState.controllers.chosenWeek = index;
                        classTableState.controllers.pageControl.animateToPage(
                          index,
                          curve: Curves.linear,
                          duration:
                              const Duration(milliseconds: changePageTime),
                        );
                        classTableState.controllers.changeTopRow(index);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: buttonInformaion(index),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
