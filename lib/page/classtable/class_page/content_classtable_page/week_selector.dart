// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

part of '../content_classtable_page.dart';

class ClassTableWeekSelector extends StatelessWidget {
  final ClassTablePagingController pagingController;
  final ClassTableWidgetState classTableState;

  const ClassTableWeekSelector({
    super.key,
    required this.pagingController,
    required this.classTableState,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pagingController,
      builder: (context, _) => SizedBox(
        height: MediaQuery.sizeOf(context).height >= 500
            ? topRowHeightBig
            : topRowHeightSmall,
        child: Container(
          padding: const EdgeInsets.only(top: 2, bottom: 4),
          color: Theme.of(context).colorScheme.surface,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (details) =>
                pagingController.chooseWeekAt(details.localPosition.dx),
            child: PageView.builder(
              padEnds: false,
              controller: pagingController.rowController,
              physics: const ClampingScrollPhysics(),
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
                      color: Theme.of(context).highlightColor.withValues(
                        alpha: classTableState.chosenWeek == index ? 0.3 : 0.0,
                      ),
                      elevation: 0.0,
                      child: InkWell(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                        onTap: () => pagingController.chooseWeek(index),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: WeekChoiceView(index: index),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
