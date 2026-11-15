// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/external/guess_book/guess_book.dart';
import 'package:watermeter/external/pig_page/pig_page.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/repository/network_client.dart';

/// 猪图鉴赏与猜书名共用的导航页。
class EntertainmentPage extends StatefulWidget {
  const EntertainmentPage({super.key});

  @override
  State<EntertainmentPage> createState() => _EntertainmentPageState();
}

class _EntertainmentPageState extends State<EntertainmentPage>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.homepage.relax),
        actions: [
          IconButton(
            icon: const Icon(Icons.games_outlined),
            tooltip: context.t.homepage.relax,
            onPressed: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              final selected = await showDialog<int>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text(context.t.homepage.relax),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                      child: Text(context.t.homepage.relaxMessage),
                    ),
                    for (final (index, icon, title) in [
                      (0, Icons.image_outlined, context.t.homepage.dashboard),
                      (1, Icons.menu_book_outlined, context.t.guessBook.title),
                    ])
                      ListTile(
                        leading: Icon(icon),
                        title: Text(title),
                        selected: index == _selectedIndex,
                        trailing: index == _selectedIndex
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () => Navigator.pop(context, index),
                      ),
                  ],
                ),
              );
              if (selected != null && mounted) {
                setState(() => _selectedIndex = selected);
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          PigPage(dio: NetworkClients.otherDio, showAppBar: false),
          const GuessBookPage(showAppBar: false),
        ],
      ),
    );
  }
}
