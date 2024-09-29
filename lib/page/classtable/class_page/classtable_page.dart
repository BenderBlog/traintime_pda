// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watermeter/page/classtable/class_add/class_add_window.dart';
import 'package:watermeter/page/classtable/class_page/class_change_list.dart';
import 'package:watermeter/page/classtable/class_page/empty_classtable_page.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/classtable/class_page/not_arranged_class_list.dart';
import 'package:watermeter/page/classtable/class_page/week_choice_view.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/pick_file.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:share_plus/share_plus.dart';
import 'package:watermeter/repository/xidian_ids/ehall_classtable_session.dart';

class ClassTablePage extends StatefulWidget {
  const ClassTablePage({super.key});

  @override
  State<StatefulWidget> createState() => _ClassTablePageState();
}

class _ClassTablePageState extends State<ClassTablePage> {
  /// Check whether listener is pushed...
  //bool isPushedListener = false;

  /// A lock of the week choice row.
  /// When locked, choiceWeek cannot be changed.
  bool isTopRowLocked = false;

  /// Classtable pageView controller.
  late PageController pageControl;

  /// Week choice row controller.
  late PageController rowControl;

  late BoxDecoration decoration;
  late ClassTableWidgetState classTableState;

  void _switchPage() {
    setState(() => isTopRowLocked = true);
    Future.wait(
      [
        rowControl.animateToPage(
          classTableState.chosenWeek,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: changePageTime),
        ),
        pageControl.animateToPage(
          classTableState.chosenWeek,
          curve: Curves.easeInOutCubic,
          duration: const Duration(milliseconds: changePageTime),
        ),
      ],
    ).then((value) => isTopRowLocked = false);
  }

  @override
  void dispose() {
    classTableState.removeListener(_switchPage);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    classTableState = ClassTableState.of(context)!.controllers;

    pageControl = PageController(
      initialPage: classTableState.chosenWeek,
      keepPage: true,
    );

    /// (weekButtonWidth + 2 * weekButtonHorizontalPadding)
    /// is the width of the week choose button.
    rowControl = PageController(
      initialPage: classTableState.chosenWeek,
      viewportFraction: (weekButtonWidth + 2 * weekButtonHorizontalPadding) /
          ClassTableState.of(context)!.constraints.minWidth,
      keepPage: true,
    );

    /// Let controllers listen to the currentWeek's change.
    // if (isPushedListener == false) {
    classTableState.addListener(_switchPage);
    //  isPushedListener = true;
    //}

    /// Init the background.
    File image = File("${supportPath.path}/decoration.jpg");
    decoration = BoxDecoration(
      image: (preference.getBool(preference.Preference.decorated) &&
              image.existsSync())
          ? DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
              opacity:
                  Theme.of(context).brightness == Brightness.dark ? 0.4 : 1.0,
            )
          : null,
    );
    super.didChangeDependencies();
  }

  /// A row shows a series of buttons about the classtable's index.
  ///
  /// This is at the top of the classtable. It contains a series of
  /// buttons which shows the week index, as well as an overview in a 5x5 dot gridview.
  ///
  /// When user click on the button, the pageview will show the class table of the
  /// week the button suggested.
  Widget _topView() {
    return SizedBox(
      /// Related to the overview of the week.
      height: MediaQuery.sizeOf(context).height >= 500
          ? topRowHeightBig
          : topRowHeightSmall,
      child: Container(
        padding: const EdgeInsets.only(
          top: 2,
          bottom: 4,
        ),
        child: PageView.builder(
          padEnds: false,
          controller: rowControl,
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
                  color: Theme.of(context).highlightColor.withOpacity(
                        classTableState.chosenWeek == index ? 0.3 : 0.0,
                      ),
                  elevation: 0.0,
                  child: InkWell(
                    /// The following themes are the same as the Material 3 Card Radius.
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    splashColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    highlightColor:
                        Theme.of(context).primaryColor.withOpacity(0.3),
                    onTap: () {
                      if (isTopRowLocked == false) {
                        classTableState.chosenWeek = index;
                      }
                    },
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
    );
  }

  /// If no class, a special page appears.
  bool get haveClass =>
      classTableState.timeArrangement.isNotEmpty &&
      classTableState.classDetail.isNotEmpty;

  Future<void> importPartnerData() async {
    log.info(
      "classTableState.havePartner in importPartnerData: "
      "${classTableState.havePartner}",
    );

    if (classTableState.havePartner) {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("确认对话框"),
          content: const Text("目前有搭子课表数据，是否要覆盖？"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("确定"),
            )
          ],
        ),
      );
      if (context.mounted && confirm != true) {
        return;
      }
    }

    String? result = "";

    try {
      result = await pickFile().then((value) => value?.files.single.path ?? "");
      if (mounted && result.isEmpty) {
        showToast(
          context: context,
          msg: '未发现导入文件',
        );
      }
    } on MissingStoragePermissionException {
      if (mounted) showToast(context: context, msg: "未获取存储权限，无法读取文件");
    }

    if (mounted) {
      try {
        String source = File.fromUri(Uri.parse(result!)).readAsStringSync();
        bool isSuccess = classTableState.decodePartnerClass(source).$4;
        if (isSuccess) {
          File("${supportPath.path}/${ClassTableFile.partnerClassName}")
              .writeAsStringSync(source);
          classTableState.updatePartnerClass();
        }
      } catch (error, stacktrace) {
        log.error(
          "Error occured while importing partner class.",
          error,
          stacktrace,
        );
        showToast(
          context: context,
          msg: '好像导入文件有点问题:P',
        );
        return;
      }
      showToast(
        context: context,
        msg: '导入成功',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (haveClass) {
      return Scaffold(
          appBar: AppBar(
            title: Text(classTableState.isPartner ? "搭子的日程表" : "日程表"),
            leading: IconButton(
              icon: Icon(
                Platform.isIOS || Platform.isMacOS
                    ? Icons.arrow_back_ios
                    : Icons.arrow_back,
              ),
              onPressed: () =>
                  Navigator.of(ClassTableState.of(context)!.parentContext)
                      .pop(),
            ),
            actions: [
              if (classTableState.havePartner)
                IconButton(
                  onPressed: () =>
                      classTableState.isPartner = !classTableState.isPartner,
                  icon: Icon(
                    classTableState.isPartner
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                ),
              if (haveClass)
                PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuItem<String>>[
                    const PopupMenuItem<String>(
                      value: 'A',
                      child: Text("查看未安排课程信息"),
                    ),
                    const PopupMenuItem<String>(
                      value: 'B',
                      child: Text("查看课程安排调整信息"),
                    ),
                    if (!classTableState.isPartner) ...[
                      const PopupMenuItem<String>(
                        value: 'C',
                        child: Text("添加课程信息"),
                      ),
                      const PopupMenuItem<String>(
                        value: 'D',
                        child: Text("生成日历文件"),
                      ),
                      const PopupMenuItem<String>(
                        value: 'E',
                        child: Text("生成共享课表文件"),
                      ),
                      const PopupMenuItem<String>(
                        value: 'F',
                        child: Text("导入共享课表文件"),
                      ),
                      const PopupMenuItem<String>(
                        value: 'G',
                        child: Text("删除共享课表文件"),
                      ),
                    ],
                  ],
                  onSelected: (String action) async {
                    final box = context.findRenderObject() as RenderBox?;
                    switch (action) {
                      case 'A':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const NotArrangedClassList();
                            },
                          ),
                        );
                        break;
                      case 'B':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const ClassChangeList();
                            },
                          ),
                        );
                        break;
                      case 'C':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const ClassAddWindow();
                            },
                          ),
                        );
                        break;
                      case 'D':
                      case 'E':
                        try {
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("请不要随意分享"),
                              content: const Text(
                                  "导出文件包括你的个人信息，请不要随意跟别人分享，或者发在大群里。"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("确定"),
                                )
                              ],
                            ),
                          );
                          String fileName = "classtable-"
                              "${Jiffy.now().format(pattern: "yyyyMMddTHHmmss")}-"
                              "${classTableState.semesterCode}";
                          if (action == 'D') {
                            fileName += ".ics";
                          } else {
                            fileName +=
                                "-${preference.getString(preference.Preference.idsAccount)}.erc";
                          }
                          if (Platform.isLinux ||
                              Platform.isMacOS ||
                              Platform.isWindows) {
                            String? resultFilePath =
                                await FilePicker.platform.saveFile(
                              dialogTitle: "保存日历文件到...",
                              fileName: fileName,
                              allowedExtensions: [
                                if (action == 'D') "ics" else "erc"
                              ],
                              lockParentWindow: true,
                            );
                            if (resultFilePath != null) {
                              File file = File(resultFilePath);
                              if (!(await file.exists())) {
                                await file.create();
                              }
                              if (action == "D") {
                                await file.writeAsString(
                                    classTableState.iCalenderStr);
                              } else {
                                await file
                                    .writeAsString(classTableState.ercStr);
                              }
                            }
                          } else {
                            String tempPath = await getTemporaryDirectory()
                                .then((value) => value.path);
                            File file = File("$tempPath/$fileName");
                            if (!(await file.exists())) {
                              await file.create();
                            }
                            if (action == "D") {
                              await file
                                  .writeAsString(classTableState.iCalenderStr);
                            } else {
                              await file.writeAsString(classTableState.ercStr);
                            }
                            await Share.shareXFiles(
                              [XFile("$tempPath/$fileName")],
                              sharePositionOrigin:
                                  box!.localToGlobal(Offset.zero) & box.size,
                            );
                            await file.delete();
                          }
                          if (context.mounted) {
                            showToast(context: context, msg: "应该保存成功");
                          }
                        } on FileSystemException {
                          if (context.mounted) {
                            showToast(context: context, msg: "文件创建失败，保存取消");
                          }
                        }
                        break;
                      case 'F':
                        await importPartnerData();
                      case 'G':
                        bool? isDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("确认对话框"),
                            content: const Text("确定要清除共享课表吗？"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("取消"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text("确定"),
                              )
                            ],
                          ),
                        );

                        if (context.mounted && isDelete == true) {
                          classTableState.deletePartnerClass();
                          showToast(
                            context: context,
                            msg: '删除共享课表成功',
                          );
                        }
                    }
                  },
                ),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              PreferredSize(
                preferredSize: Size.fromHeight(
                  MediaQuery.sizeOf(context).height >= 500
                      ? topRowHeightBig
                      : topRowHeightSmall,
                ),
                child: _topView(),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: decoration,
                  child: _classTablePage(),
                ),
              ),
            ],
          ));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("日程表"),
          leading: IconButton(
            icon: Icon(
              Platform.isIOS || Platform.isMacOS
                  ? Icons.arrow_back_ios
                  : Icons.arrow_back,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: const EmptyClasstablePage(),
      );
    }
  }

  /// The [_classTablePage] is controlled by [pageControl].
  Widget _classTablePage() => PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: pageControl,
        onPageChanged: (value) {
          /// When [pageControl.animateTo] triggered,
          /// page view will try to refresh the [chosenWeek] everytime the page
          /// view changed into a new page. Because animateTo will load every page
          /// it passed.
          ///
          /// So that's the [isTopRowLocked] is used for. When week choice row is
          /// locked, it will not refresh the [chosenWeek]. And when [chosenWeek]
          /// is equal to the current page, unlock the [isTopRowLocked].
          if (isTopRowLocked == false) {
            classTableState.chosenWeek = value;
          }
        },
        itemCount: classTableState.semesterLength,
        itemBuilder: (context, index) => LayoutBuilder(
          builder: (context, constraint) => ClassTableView(
            constraint: constraint,
            index: index,
          ),
        ),
      );
}
