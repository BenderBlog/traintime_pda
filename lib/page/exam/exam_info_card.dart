import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/page/widget.dart';

class ExamInfoCard extends StatelessWidget {
  final Subject? toUse;
  final String? title;

  const ExamInfoCard({super.key, this.toUse, this.title})
      : assert(toUse != null || title != null);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(14),
        child: toUse != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(
                        toUse!.subject,
                        textScaleFactor: 1.1,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      TagsBoxes(
                        text: toUse!.type,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      const Divider(
                        color: Colors.transparent,
                        height: 5,
                      ),
                      informationWithIcon(Icons.access_time_filled_rounded,
                          toUse!.time, context),
                      informationWithIcon(
                          Icons.person, toUse!.teacher ?? "未知老师", context),
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            flex: 1,
                            child: informationWithIcon(
                                Icons.room, toUse!.place, context),
                          ),
                          Expanded(
                            flex: 1,
                            child: informationWithIcon(
                                Icons.chair, toUse!.seat.toString(), context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            : Text(
                title!,
                textScaleFactor: 1.1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
      ),
    );
  }
}
