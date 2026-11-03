// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Pig page — random pig image from pighub.top.

import 'package:watermeter/generated/translations.g.dart';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/pighub_image.dart';
import 'package:watermeter/repository/miscellaneous_session/pighub_session.dart';

class PigPage extends StatefulWidget {
  const PigPage({super.key, this.appBarBottom, this.showAppBar = true});

  final PreferredSizeWidget? appBarBottom;
  final bool showAppBar;

  @override
  State<PigPage> createState() => _PigPageState();
}

class _PigPageState extends State<PigPage> with AutomaticKeepAliveClientMixin {
  late Future<List<PigHubImage>> _future;
  final session = PighubSession();
  int index = 0;
  final random = Random();

  @override
  void initState() {
    super.initState();
    _future = session.getPigImages()..ignore();
  }

  void _fetch() {
    setState(() {
      index = 0;
      // FutureBuilder 会显示错误；提前监听避免请求在下一帧前失败时未被处理。
      _future = session.getPigImages()..ignore();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(context.t.homepage.dashboard),
              bottom: widget.appBarBottom,
            )
          : null,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _fetch,
                icon: const Icon(Icons.replay_outlined),
                label: Text(context.t.common.clickToRefresh),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<PigHubImage>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return [
                  Text(
                    context.t.common.newHomepageHint,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    "Failed to fetch a pig :(\n${snapshot.error}",
                    textAlign: TextAlign.center,
                  ),
                ]
                .toColumn(mainAxisAlignment: MainAxisAlignment.center)
                .padding(horizontal: 24)
                .center();
          }

          final data = snapshot.data!;
          return [
                // Text(
                //   context.t.common.newHomepageHint,
                //   textAlign: TextAlign.center,
                // ),
                // const SizedBox(height: 12),
                Text(
                  "There are ${snapshot.data!.length} pigs in the Animal Farm. \n"
                  "Better stay at home and do as you're told. \n"
                  "Get out of the road if you want to grow old!",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 300,
                  child: Image.network(
                    data[index].url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image_outlined, size: 80),
                    ),
                  ),
                ).clipRRect(all: 12),
                const SizedBox(height: 8),
                Text(
                  data[index].title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      index = random.nextInt(data.length);
                    });
                  },
                  icon: const Icon(Icons.shuffle),
                  label: const Text("Change A Pig"),
                ),
                SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => launchUrlString(
                    data[index].url,
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text("Save this Pig"),
                ),
                const SizedBox(height: 16),
              ]
              .toColumn(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              )
              .scrollable()
              .center()
              .padding(horizontal: 24);
        },
      ),
    );
  }
}
