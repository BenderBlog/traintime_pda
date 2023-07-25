import 'package:flutter/material.dart';
import 'package:watermeter/page/exam/flow_event_row.dart';
import 'package:watermeter/page/widget.dart';

class TimelineWidget extends StatelessWidget {
  final List<bool> isTitle;
  final List<Widget> children;
  const TimelineWidget({
    super.key,
    required this.isTitle,
    required this.children,
  }) : assert(isTitle.length == children.length);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 660),
        child: Stack(
          alignment: AlignmentDirectional.center,
          fit: StackFit.loose,
          children: <Widget>[
            Positioned(
              left: isPhone(context) ? 14 : 20,
              top: 16,
              bottom: 16,
              child: const VerticalDivider(
                width: 1,
              ),
            ),
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: children.length,
              itemBuilder: (BuildContext context, int index) {
                return FlowEventRow(
                  isTitle: isTitle[index],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: children[index],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
