// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';

import 'component/pig_content.dart';
import 'model/pighub_image.dart';
import 'repository/pighub_session.dart';

class PigPage extends StatefulWidget {
  const PigPage({
    super.key,
    required this.dio,
    this.appBarBottom,
    this.showAppBar = true,
  });

  /// The caller owns and configures this HTTP client.
  final Dio dio;
  final PreferredSizeWidget? appBarBottom;
  final bool showAppBar;

  @override
  State<PigPage> createState() => _PigPageState();
}

class _PigPageState extends State<PigPage> with AutomaticKeepAliveClientMixin {
  final _random = Random();
  late Future<List<PigHubImage>> _images;
  int _index = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PigPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dio != widget.dio) _load();
  }

  void _load() {
    _index = 0;
    // FutureBuilder handles errors after it subscribes on the next frame.
    _images = PighubSession(widget.dio).getPigImages()..ignore();
  }

  void _refresh() => setState(_load);

  void _changePig(int count) {
    setState(() => _index = _random.nextInt(count));
  }

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
                onPressed: _refresh,
                icon: const Icon(Icons.replay_outlined),
                label: Text(context.t.common.clickToRefresh),
              ),
            ),
          ),
        ),
      ),
      body: PigContent(images: _images, index: _index, onChangePig: _changePig),
    );
  }
}
