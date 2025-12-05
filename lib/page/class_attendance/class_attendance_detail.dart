import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/repository/xidian_ids/learning_session.dart';

class ClassAttendanceDetailView extends StatelessWidget {
  late final Future<List<ClassAttendanceDetail>> future;

  ClassAttendanceDetailView({
    super.key,
    required ClassAttendance classAttendance,
  }) {
    future = LearningSession().getAttendanceRecordDetail(classAttendance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("签到信息")),
      body: FutureBuilder<List<ClassAttendanceDetail>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('加载数据时出错: ${snapshot.error}\n${snapshot.stackTrace}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('没有签到记录'));
          } else {
            final details = snapshot.data!;
            return ListView.builder(
              itemCount: details.length,
              itemBuilder: (context, index) {
                final detail = details[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(detail.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('发起人: ${detail.creatorName}'),
                        Text('开始时间: ${detail.starttime}'),
                        Text('提交时间: ${detail.submittime}'),
                        Text('状态: ${detail.status}'),
                        Text('用户状态: ${detail.userStatus}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
