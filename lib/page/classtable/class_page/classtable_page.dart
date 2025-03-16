// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_add/class_add_window.dart';
import 'package:watermeter/page/classtable/class_page/class_change_list.dart';
import 'package:watermeter/page/classtable/class_page/empty_classtable_page.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/classtable/class_page/not_arranged_class_list.dart';
import 'package:watermeter/page/classtable/class_page/week_choice_view.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/pick_file.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:share_plus/share_plus.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';

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
    File image = File("${supportPath.path}/${ClassTableFile.decorationName}");
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
                  color: Theme.of(context).highlightColor.withValues(
                        alpha: classTableState.chosenWeek == index ? 0.3 : 0.0,
                      ),
                  elevation: 0.0,
                  child: InkWell(
                    /// The following themes are the same as the Material 3 Card Radius.
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
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
          title: Text(FlutterI18n.translate(
            context,
            "confirm_title",
          )),
          content: Text(FlutterI18n.translate(
            context,
            "classtable.partner_classtable.override_dialog",
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(FlutterI18n.translate(context, "cancel")),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(FlutterI18n.translate(context, "confirm")),
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
          msg: FlutterI18n.translate(
            context,
            "classtable.partner_classtable.no_file",
          ),
        );
      }
    } on MissingStoragePermissionException {
      if (mounted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            "classtable.partner_classtable.no_permission",
          ),
        );
      }
    }

    if (mounted) {
      try {
        String source = File.fromUri(Uri.parse(result!)).readAsStringSync();
        bool isSuccess = classTableState.decodePartnerClass(source).$5;
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
          msg: FlutterI18n.translate(
            context,
            "classtable.partner_classtable.problem",
          ),
        );
        return;
      }
      showToast(
        context: context,
        msg: FlutterI18n.translate(
          context,
          "classtable.partner_classtable.success",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (haveClass) {
      return Scaffold(
          appBar: AppBar(
            title: Text(classTableState.isPartner
                ? FlutterI18n.translate(
                    context, "classtable.partner_page_title",
                    translationParams: {
                        "partner_name": classTableState.partnerName ?? "Sweetie"
                      })
                : FlutterI18n.translate(
                    context,
                    "classtable.page_title",
                  )),
            leading: BackButton(
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
                    PopupMenuItem<String>(
                      value: 'A',
                      child: Text(FlutterI18n.translate(
                        context,
                        "classtable.popup_menu.not_arranged",
                      )),
                    ),
                    PopupMenuItem<String>(
                      value: 'B',
                      child: Text(FlutterI18n.translate(
                        context,
                        "classtable.popup_menu.class_changed",
                      )),
                    ),
                    if (!classTableState.isPartner) ...[
                      PopupMenuItem<String>(
                        value: 'C',
                        child: Text(FlutterI18n.translate(
                          context,
                          "classtable.popup_menu.add_class",
                        )),
                      ),
                      PopupMenuItem<String>(
                        value: 'D',
                        child: Text(FlutterI18n.translate(
                          context,
                          "classtable.popup_menu.generate_ical",
                        )),
                      ),
                      PopupMenuItem<String>(
                        value: 'H',
                        child: Text(FlutterI18n.translate(
                          context,
                          "classtable.popup_menu.output_to_system",
                        )),
                      ),
                      PopupMenuItem<String>(
                        value: 'I',
                        child: Text(FlutterI18n.translate(
                          context,
                          "classtable.popup_menu.refresh_classtable",
                        )),
                      ),
                      PopupMenuItem<String>(
                        value: 'E',
                        child: Text(FlutterI18n.translate(
                          context,
                          "classtable.popup_menu.generate_partner_file",
                        )),
                      ),
                      PopupMenuItem<String>(
                        value: 'F',
                        child: Text(FlutterI18n.translate(
                          context,
                          "classtable.popup_menu.import_partner_file",
                        )),
                      ),
                      PopupMenuItem<String>(
                        value: 'G',
                        child: Text(FlutterI18n.translate(
                          context,
                          "classtable.popup_menu.delete_partner_file",
                        )),
                      ),
                    ],
                  ],
                  onSelected: (String action) async {
                    final box = context.findRenderObject() as RenderBox?;
                    switch (action) {
                      case 'A':
                        var notArranged = ClassTableState.of(context)!
                            .controllers
                            .notArranged;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return NotArrangedClassList(
                                notArranged: notArranged,
                              );
                            },
                          ),
                        );
                        break;
                      case 'B':
                        var classChange = ClassTableState.of(context)!
                            .controllers
                            .classChange;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return ClassChangeList(
                                classChanges: classChange,
                              );
                            },
                          ),
                        );
                        break;
                      case 'C':
                        int semesterLength = ClassTableState.of(context)!
                            .controllers
                            .semesterLength;
                        (ClassDetail, TimeArrangement)? data =
                            await Navigator.of(context)
                                .push<(ClassDetail, TimeArrangement)>(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return ClassAddWindow(
                                semesterLength: semesterLength,
                              );
                            },
                          ),
                        );
                        if (context.mounted && data != null) {
                          await ClassTableState.of(context)!
                              .controllers
                              .addUserDefinedClass(
                                data.$1,
                                data.$2,
                              );
                        }
                        break;
                      case 'D':
                      case 'E':
                        try {
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(FlutterI18n.translate(
                                context,
                                "classtable.partner_classtable.share_dialog.title",
                              )),
                              content: Text(FlutterI18n.translate(
                                context,
                                "classtable.partner_classtable.share_dialog.content",
                              )),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(FlutterI18n.translate(
                                    context,
                                    "confirm",
                                  )),
                                )
                              ],
                            ),
                          );
                          if (context.mounted) {
                            String fileName = "classtable-"
                                "${Jiffy.now().format(pattern: "yyyyMMddTHHmmss")}-"
                                "${classTableState.semesterCode}";
                            String sweetheartName = "";
                            if (action == 'D') {
                              fileName += ".ics";
                            } else {
                              TextEditingController controller =
                                  TextEditingController();
                              sweetheartName = await showDialog<String>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text(FlutterI18n.translate(
                                              context,
                                              "classtable.partner_classtable.name_dialog.title",
                                            )),
                                            content: TextField(
                                              autofocus: true,
                                              controller: controller,
                                              maxLines: 1,
                                              decoration: InputDecoration(
                                                hintText: FlutterI18n.translate(
                                                  context,
                                                  "classtable.partner_classtable.name_dialog.hint",
                                                ),
                                                border:
                                                    const OutlineInputBorder(),
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text(
                                                  FlutterI18n.translate(
                                                    context,
                                                    "classtable.partner_classtable.name_dialog.cancel",
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  Navigator.of(context).pop(
                                                    null,
                                                  );
                                                },
                                              ),
                                              TextButton(
                                                child: Text(
                                                  FlutterI18n.translate(
                                                    context,
                                                    "classtable.partner_classtable.name_dialog.accept",
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  if (controller.text.isEmpty) {
                                                    showToast(
                                                      context: context,
                                                      msg:
                                                          FlutterI18n.translate(
                                                        context,
                                                        "classtable.partner_classtable.name_dialog.blank_input",
                                                      ),
                                                    );
                                                  } else {
                                                    Navigator.of(context).pop(
                                                      controller.text,
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          )) ??
                                  "Sweetie";

                              if (context.mounted) {
                                fileName += "-$sweetheartName.erc";
                              }
                            }
                            if ((Platform.isLinux ||
                                    Platform.isMacOS ||
                                    Platform.isWindows) &&
                                context.mounted) {
                              String? resultFilePath =
                                  await FilePicker.platform.saveFile(
                                dialogTitle: FlutterI18n.translate(
                                  context,
                                  "classtable.partner_classtable.save_dialog.title",
                                ),
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
                                  await file.writeAsString(
                                    classTableState.ercStr(sweetheartName),
                                  );
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
                                await file.writeAsString(
                                    classTableState.iCalenderStr);
                              } else {
                                await file.writeAsString(
                                  classTableState.ercStr(sweetheartName),
                                );
                              }
                              await Share.shareXFiles(
                                [XFile("$tempPath/$fileName")],
                                sharePositionOrigin:
                                    box!.localToGlobal(Offset.zero) & box.size,
                              );
                              await file.delete();
                            }
                          }
                          if (context.mounted) {
                            showToast(
                              context: context,
                              msg: FlutterI18n.translate(
                                context,
                                "classtable.partner_classtable.save_dialog.success_message",
                              ),
                            );
                          }
                        } on FileSystemException {
                          if (context.mounted) {
                            showToast(
                              context: context,
                              msg: FlutterI18n.translate(
                                context,
                                "classtable.partner_classtable.save_dialog.failure_message",
                              ),
                            );
                          }
                        }
                        break;
                      case 'F':
                        await importPartnerData();
                      case 'G':
                        bool? isDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(FlutterI18n.translate(
                              context,
                              "classtable.partner_classtable.delete_dialog.title",
                            )),
                            content: Text(FlutterI18n.translate(
                              context,
                              "classtable.partner_classtable.delete_dialog.message",
                            )),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(
                                  FlutterI18n.translate(
                                    context,
                                    "cancel",
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  FlutterI18n.translate(
                                    context,
                                    "confirm",
                                  ),
                                ),
                              )
                            ],
                          ),
                        );

                        if (context.mounted && isDelete == true) {
                          classTableState.deletePartnerClass();
                          showToast(
                            context: context,
                            msg: FlutterI18n.translate(
                              context,
                              "classtable.partner_classtable.delete_dialog.success_message",
                            ),
                          );
                        }
                      case 'H':
                        await classTableState.outputToCalendar().then((data) {
                          if (context.mounted) {
                            showToast(
                              context: context,
                              msg: FlutterI18n.translate(
                                context,
                                data
                                    ? "classtable.output_to_system.success"
                                    : "classtable.output_to_system.failure",
                              ),
                            );
                          }
                        });
                      case 'I':
                        bool isAccepted = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text(FlutterI18n.translate(
                                  context,
                                  "setting.class_refresh_title",
                                )),
                                content: Text(FlutterI18n.translate(
                                  context,
                                  "setting.class_refresh_content",
                                )),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(FlutterI18n.translate(
                                      context,
                                      "cancel",
                                    )),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(FlutterI18n.translate(
                                      context,
                                      "confirm",
                                    )),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                        if (context.mounted && isAccepted) {
                          await classTableState
                              .updateClasstable(context)
                              .then((data) {
                            if (context.mounted) {
                              showToast(
                                context: context,
                                msg: FlutterI18n.translate(
                                  context,
                                  "classtable.refresh_classtable.success",
                                ),
                              );
                            }
                          });
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
              DecoratedBox(
                decoration: decoration,
                child: _classTablePage(),
              ).expanded(),
            ],
          ));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(
            context,
            "classtable.page_title",
          )),
          leading: IconButton(
            icon: Icon(
              Platform.isIOS || Platform.isMacOS
                  ? Icons.arrow_back_ios
                  : Icons.arrow_back,
            ),
            onPressed: () =>
                Navigator.of(ClassTableState.of(context)!.parentContext).pop(),
          ),
        ),
        body: [
          const EmptyClasstablePage(),
          TextButton.icon(
            onPressed: () async {
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "classtable.refresh_classtable.ready",
                ),
              );
              await classTableState.updateClasstable(context).then((data) {
                if (context.mounted) {
                  showToast(
                    context: context,
                    msg: FlutterI18n.translate(
                      context,
                      "classtable.refresh_classtable.success",
                    ),
                  );
                }
              });
            },
            icon: const Icon(Icons.update),
            label: Text(
              FlutterI18n.translate(
                context,
                "classtable.popup_menu.refresh_classtable",
              ),
            ),
          )
        ].toColumn(),
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
