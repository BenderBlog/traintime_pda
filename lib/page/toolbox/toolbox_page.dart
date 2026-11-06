// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';

import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/toolbox/campus_notice_page.dart';
import 'package:watermeter/generated/translations.g.dart';

class ToolBoxPage extends StatefulWidget {
  const ToolBoxPage({super.key});

  @override
  State<ToolBoxPage> createState() => _ToolBoxPageState();
}

class _ToolBoxPageState extends State<ToolBoxPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.toolbox.title)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.search),
            title: Text(context.t.toolbox.noticeSearch),
            subtitle: Text(context.t.toolbox.noticeDescription),
            onTap: () => context.push<void>(const CampusNoticePage()),
          ),
        ],
      ),
    );
  }
}
