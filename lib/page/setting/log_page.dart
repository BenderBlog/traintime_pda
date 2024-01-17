// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/repository/logger.dart';

class LogWindow extends StatefulWidget {
  const LogWindow({super.key});

  @override
  State<LogWindow> createState() => _LogWindowState();
}

class _LogWindowState extends State<LogWindow> {
  /// Copied from logfmt_printer
  static final levelPrefixes = {
    Level.trace: 'trace',
    Level.debug: 'debug',
    Level.info: 'info',
    Level.warning: 'warning',
    Level.error: 'error',
    Level.fatal: 'fatal',
  };

  String printLog(LogEvent event) {
    var output = StringBuffer('level=${levelPrefixes[event.level]}');
    if (event.message is String) {
      output.write(' msg="${event.message}"');
    } else if (event.message is Map) {
      event.message.entries.forEach((entry) {
        if (entry.value is num) {
          output.write(' ${entry.key}=${entry.value}');
        } else {
          output.write(' ${entry.key}="${entry.value}"');
        }
      });
    }
    if (event.error != null) {
      output.write(' error="${event.error}"');
    }

    return output.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("日志窗口"),
        actions: [
          IconButton(
            onPressed: () async {
              String toStore = "";
              final box = context.findRenderObject() as RenderBox?;
              for (var i in logMemory.buffer) {
                toStore += printLog(i.origin);
              }
              try {
                String now = Jiffy.now().format(
                  pattern: "yyyyMMddTHHmmss",
                );
                String tempPath = await getTemporaryDirectory().then(
                  (value) => value.path,
                );
                File file = File("$tempPath/log-$now.txt");
                if (!(await file.exists())) {
                  await file.create();
                }
                await file.writeAsString(toStore);
                await Share.shareXFiles(
                  [XFile("$tempPath/log-$now.txt")],
                  sharePositionOrigin:
                      box!.localToGlobal(Offset.zero) & box.size,
                );
                await file.delete();
                Fluttertoast.showToast(msg: "共享日志成功");
              } on FileSystemException {
                Fluttertoast.showToast(msg: "共享日志失败");
              }
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                logMemory.buffer.clear();
              });
            },
            icon: const Icon(Icons.delete),
          )
        ],
      ),
      body: ListView(children: [
        for (var i in logMemory.buffer) ...[
          if (i != logMemory.buffer.first) const Divider(height: 2),
          Text(printLog(i.origin)).padding(horizontal: 10, vertical: 10),
        ]
      ]),
    );
  }
}
