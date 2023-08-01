import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/widget.dart';

class NotArrangedClassList extends StatelessWidget {
  final List<ClassDetail> notArranged;
  const NotArrangedClassList({
    super.key,
    required this.notArranged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("没有时间安排的科目"),
      ),
      body: ListView.builder(
        itemCount: notArranged.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(notArranged[index].name),
          subtitle: Text(
            "编号: ${notArranged[index].code} | ${notArranged[index].number}\n"
            "老师: ${notArranged[index].teacher ?? "没有数据"}",
          ),
        ),
      ),
    );
  }
}
