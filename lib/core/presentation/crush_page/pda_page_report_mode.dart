// Original source: catcher_2 (https://github.com/ThexXTURBOXx/catcher_2)
// Copyright 2022-2026 ThexXTURBOXx
// SPDX-License-Identifier: Apache-2.0
//
// Modified by Traintime PDA authors (Hazuki Keatsu), 2026:
// added a copy-to-clipboard action in the report page.

import 'package:catcher_2/catcher_2.dart';
import 'package:catcher_2/model/platform_type.dart';
import 'package:catcher_2/utils/catcher_2_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/core/shared/widgets/copy_button.dart';

class PdaPageReportMode extends ReportMode {
  PdaPageReportMode({this.showStackTrace = true});

  final bool showStackTrace;

  @override
  void requestAction(Report report, BuildContext? context) {
    if (context != null) {
      _navigateToPageWidget(report, context);
    }
  }

  Future<void> _navigateToPageWidget(
    Report report,
    BuildContext context,
  ) async {
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) {
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => PdaPageWidget(this, report)),
    );
  }

  @override
  bool isContextRequired() => true;

  @override
  List<PlatformType> getSupportedPlatforms() => [
    PlatformType.android,
    PlatformType.iOS,
    PlatformType.web,
    PlatformType.linux,
    PlatformType.macOS,
    PlatformType.windows,
  ];
}

class PdaPageWidget extends StatefulWidget {
  const PdaPageWidget(this.pageReportMode, this.report, {super.key});

  final PdaPageReportMode pageReportMode;
  final Report report;

  @override
  PageWidgetState createState() => PageWidgetState();
}

class PageWidgetState extends State<PdaPageWidget> {
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: true,
    onPopInvokedWithResult: (bool didPop, Object? result) {
      if (didPop) {
        widget.pageReportMode.onActionRejected(widget.report);
      }
    },
    child: Builder(
      builder: (context) => Catcher2Utils.isCupertinoAppAncestor(context)
          ? _buildCupertinoPage(context)
          : _buildMaterialPage(context),
    ),
  );

  Widget _buildMaterialPage(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.pageReportMode.localizationOptions.pageReportModeTitle,
      ),
    ),
    body: _buildInnerWidget(context),
  );

  Widget _buildCupertinoPage(BuildContext context) => CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      middle: Text(
        widget.pageReportMode.localizationOptions.pageReportModeTitle,
      ),
    ),
    child: SafeArea(child: _buildInnerWidget(context)),
  );

  Widget _buildInnerWidget(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
    child: Column(
      children: [
        const Padding(padding: EdgeInsets.only(top: 10)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.pageReportMode.localizationOptions.pageReportModeDescription,
            style: _getTextStyle(15),
            textAlign: TextAlign.center,
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 20)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _getStackTraceWidget(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: _onAcceptClicked,
              child: Text(
                widget.pageReportMode.localizationOptions.pageReportModeAccept,
              ),
            ),
            TextButton(
              onPressed: _onCancelClicked,
              child: Text(
                widget.pageReportMode.localizationOptions.pageReportModeCancel,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  TextStyle _getTextStyle(double fontSize) =>
      TextStyle(fontSize: fontSize, decoration: TextDecoration.none);

  Widget _getStackTraceWidget() {
    if (widget.pageReportMode.showStackTrace) {
      var error = '';
      if (widget.report.error != null) {
        error = widget.report.error.toString();
      } else if (widget.report.errorDetails != null) {
        error = widget.report.errorDetails.toString();
      }

      final items = <String>[
        error,
        ...widget.report.stackTrace.toString().split('\n'),
      ];
      return Stack(
        children: [
          SizedBox(
            height: 300,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 56, 8),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  Text(items[index], style: _getTextStyle(10)),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: AnimatedIconButton(
              iconSize: 20.0,
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: items.join('\n'))),
              tooltip: 'Copy report',
              init: MingCuteIcons.mgc_copy_line,
              triggered: MingCuteIcons.mgc_check_line,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  void _onAcceptClicked() {
    widget.pageReportMode.onActionConfirmed(widget.report);
    _closePage();
  }

  void _onCancelClicked() {
    widget.pageReportMode.onActionRejected(widget.report);
    _closePage();
  }

  void _closePage() {
    Navigator.of(context).pop();
  }
}
