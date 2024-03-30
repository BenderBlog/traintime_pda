// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:watermeter/model/toolbox_addresses.dart';
import 'package:watermeter/page/public_widget/split_view.dart';
import 'package:watermeter/page/toolbox/webview_list_tile.dart';

class ToolBoxPage extends StatelessWidget {
  const ToolBoxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("其他功能"),
        leading: IconButton(
          icon: Icon(
            Platform.isIOS || Platform.isMacOS
                ? Icons.arrow_back_ios
                : Icons.arrow_back,
          ),
          onPressed: () => SplitView.of(context).pop(),
        ),
      ),
      body: ListView(
        children: WebViewAddresses.values
            .map((e) => WebViewListTile(data: e))
            .toList(),
      ),
    );
  }
}
