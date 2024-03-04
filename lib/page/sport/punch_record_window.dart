// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Interface of the punch record window of the sport data.
/*
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:watermeter/model/xidian_sport/punch.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';

class PunchRecordWindow extends StatefulWidget {
  const PunchRecordWindow({super.key});

  @override
  State<PunchRecordWindow> createState() => _PunchRecordWindowState();
}

class _PunchRecordWindowState extends State<PunchRecordWindow>
    with AutomaticKeepAliveClientMixin {
  bool isValid = false;
  late EasyRefreshController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(
      () => Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: sheetMaxWidth),
            child: EasyRefresh.builder(
              controller: _controller,
              clipBehavior: Clip.none,
              header: const MaterialHeader(
                clamping: true,
                showBezierBackground: false,
                bezierBackgroundAnimation: false,
                bezierBackgroundBounce: false,
                springRebound: false,
              ),
              onRefresh: () async {
                await SportSession().getPunch();
                _controller.finishRefresh();
              },
              childBuilder: (context, physics) {
                if (punchData.value.situation.isEmpty) {
                  if (punchData.value.all.isNotEmpty) {
                    List<RecordCard> toUse = [];
                    if (isValid) {
                      toUse.addAll(
                        List<RecordCard>.generate(
                          punchData.value.valid.length,
                          (index) => RecordCard(
                            mark: index + 1,
                            toUse: punchData.value.all[index],
                          ),
                        ).reversed,
                      );
                    } else {
                      toUse.addAll(
                        List<RecordCard>.generate(
                          punchData.value.all.length,
                          (index) => RecordCard(
                            mark: index + 1,
                            toUse: punchData.value.all[index],
                          ),
                        ).reversed,
                      );
                    }
                    return DataList<RecordCard>(
                      list: toUse,
                      initFormula: (toUse) => toUse,
                    );
                  } else {
                    return ListView(
                      physics: physics,
                      children: [
                        SizedBox(
                          height: context.height * 0.7,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  size: 64,
                                ),
                                Text(
                                  "目前没有记录",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                } else if (punchData.value.situation.contains("正在加载")) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Center(
                    child: Text("坏事: ${punchData.value.situation}"),
                  );
                }
              },
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "次数: ${punchData.value.validTime} / ${punchData.value.allTime}\n"
                "成绩 ${punchData.value.score}",
                textScaler: const TextScaler.linear(1.2),
              ),
              FloatingActionButton.extended(
                elevation: 0.0,
                highlightElevation: 0.0,
                focusElevation: 0.0,
                disabledElevation: 0.0,
                onPressed: () {
                  setState(() {
                    isValid = !isValid;
                  });
                  _controller.callRefresh();
                },
                label: Text(
                  isValid ? "查看所有记录" : "查看成功记录",
                  textScaler: const TextScaler.linear(1.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordCard extends StatelessWidget {
  final PunchData toUse;
  final int mark;

  const RecordCard({super.key, required this.mark, required this.toUse});

  ReXCardRemaining situation() {
    String toShow;
    Color? background;
    bool isBold = false;
    if (toUse.state.contains("成功")) {
      toShow = toUse.state;
    } else if (toUse.state.contains("失败")) {
      toShow = "失败";
      background = Colors.red;
      isBold = true;
    } else {
      toShow = "信息";
    }
    return ReXCardRemaining(
      toShow,
      color: background,
      isBold: isBold,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReXCard(
      title: Text("第 $mark 条"),
      remaining: [situation()],
      bottomRow: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          informationWithIcon(Icons.punch_clock,
              toUse.time.format(pattern: "yyyy-MM-dd HH:mm:ss"), context),
          informationWithIcon(Icons.place, toUse.machineName, context),
          if (!toUse.state.contains("成功"))
            informationWithIcon(
              Icons.error_outline,
              toUse.state,
              context,
            ),
        ],
      ),
    );
  }
}
*/