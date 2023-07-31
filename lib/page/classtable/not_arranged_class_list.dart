import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/widget.dart';

class NotArrangedClassList extends StatelessWidget {
  const NotArrangedClassList({super.key});

  @override
  Widget build(BuildContext context) {
    List<ClassDetail> notArranged = ClassTableState.of(context)!.notArranged;
    return Scaffold(
      appBar: AppBar(
        title: const Text("没有时间安排的科目"),
      ),
      body: dataList<Card, Card>(
        List.generate(
          notArranged.length,
          (index) => Card(
            child: ListTile(
              title: Text(notArranged[index].name),
              subtitle: Text(
                "编号: ${notArranged[index].code} | ${notArranged[index].number}\n"
                "老师: ${notArranged[index].teacher ?? "没有数据"}",
              ),
            ),
          ),
        ),
        (toUse) => toUse,
      ),
    );
  }
}
