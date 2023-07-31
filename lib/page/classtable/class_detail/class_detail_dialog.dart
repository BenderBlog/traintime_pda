import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';

class ClassDetailDialog extends StatelessWidget {
  final ClassDetail classDetail;
  final TimeArrangement timeArrangement;
  final MaterialColor infoColor;
  final int currentWeek;
  const ClassDetailDialog({
    super.key,
    required this.classDetail,
    required this.timeArrangement,
    required this.infoColor,
    required this.currentWeek,
  });

  Widget customListTile(IconData icon, String str) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: infoColor.shade900,
          ),
          const SizedBox(width: 10),
          Text(
            str,
            style: TextStyle(
              color: infoColor.shade900,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget middlePart() {
    return Column(
      children: [
        customListTile(
          Icons.person,
          classDetail.teacher ?? "老师未定",
        ),
        customListTile(
          Icons.room,
          timeArrangement.classroom ?? "地点未定",
        ),
        customListTile(
          Icons.access_time_filled_outlined,
          "${weekList[timeArrangement.day - 1]}"
          "${timeArrangement.start}-${timeArrangement.stop}节课 "
          "${time[(timeArrangement.start - 1) * 2]}-${time[(timeArrangement.stop - 1) * 2 + 1]}",
        ),
      ],
    );
  }

  Widget weekDoc({required int index}) {
    bool isOccupied = true;
    if (timeArrangement.weekList[index] == "0") {
      isOccupied = false;
    }
    return ClipOval(
      child: Container(
        decoration: BoxDecoration(
          color: isOccupied ? infoColor.shade200 : null,
          borderRadius: const BorderRadius.all(Radius.circular(100.0)),
          border: index - 1 == currentWeek
              ? Border.all(width: 2, color: infoColor)
              : null,
        ),
        child: Center(
          child: Text(
            (index + 1).toString(),
            style: TextStyle(
              color: isOccupied
                  ? infoColor.shade900
                  : infoColor.shade400.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 360.0,
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        elevation: 0,
        // color: Theme.of(context).colorScheme.surfaceVariant,
        color: infoColor.shade100,
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${classDetail.name}\n${classDetail.code} | ${classDetail.number} 班",
                style: TextStyle(
                  color: infoColor.shade900,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 5),
              middlePart(),
              Container(
                margin: const EdgeInsets.only(top: 7),
                child: GridView.count(
                  shrinkWrap: true,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  crossAxisCount: 10,
                  children: List.generate(
                    timeArrangement.weekList.length,
                    (index) => weekDoc(index: index),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
