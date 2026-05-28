// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controller/ruisi_controller.dart';
import '../models/post.dart';
import '../constants/urls.dart';
import '../widgets/smiley_picker.dart';
import 'login_page.dart';

/// 帖子详情页
class TopicDetailPage extends StatefulWidget {
  final int tid;

  const TopicDetailPage({super.key, required this.tid});

  @override
  State<TopicDetailPage> createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  final _replyCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _showReply = false;
  bool _showSmiley = false;

  dynamic _detail; // TopicDetail?
  bool _loading = true;
  String? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final detail = await RuisiController.i.api.getTopicDetail(
        widget.tid,
        page: page,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _currentPage = page;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _submitReply() async {
    final content = _replyCtrl.text.trim();
    if (content.isEmpty) return;

    if (content.length < 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FlutterI18n.translate(
              context,
              'ruisi.topic_detail.reply_too_short',
            ),
          ),
        ),
      );
      return;
    }

    final c = RuisiController.i;
    if (!c.isLoggedIn) {
      if (!mounted) return;
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      if (result != true) return;
    }

    final ok = await c.api.replyTopic(widget.tid, content);
    if (!mounted) return;

    if (ok) {
      _replyCtrl.clear();
      setState(() {
        _showReply = false;
        _showSmiley = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FlutterI18n.translate(context, 'ruisi.topic_detail.reply_success'),
          ),
        ),
      );
      _load(page: _currentPage);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FlutterI18n.translate(context, 'ruisi.topic_detail.reply_failure'),
          ),
        ),
      );
    }
  }

  void _insertSmiley(String value) {
    final text = _replyCtrl.text;
    final selection = _replyCtrl.selection;
    final cursorPos = selection.isValid ? selection.start : text.length;

    final newText =
        text.substring(0, cursorPos) + value + text.substring(cursorPos);
    _replyCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + value.length),
    );
  }

  Future<void> _addFavorite() async {
    final c = RuisiController.i;
    if (!c.isLoggedIn) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }
    final ok = await c.addFavorite(widget.tid);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? FlutterI18n.translate(
                  context,
                  'ruisi.topic_detail.favorite_success',
                )
              : FlutterI18n.translate(
                  context,
                  'ruisi.topic_detail.favorite_failure',
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _detail?.title ??
              FlutterI18n.translate(context, 'ruisi.topic_detail.title'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            tooltip: FlutterI18n.translate(context, 'ruisi.common.favorite'),
            onPressed: _addFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final url = '${Urls.baseUrl}viewthread.php?tid=${widget.tid}';
              launchUrl(Uri.parse(url));
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => _load(),
                    child: Text(
                      FlutterI18n.translate(context, 'ruisi.common.retry'),
                    ),
                  ),
                ],
              ),
            )
          : _detail == null
          ? Center(
              child: Text(
                FlutterI18n.translate(context, 'ruisi.topic_detail.no_data'),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _load(page: _currentPage),
                    child: ListView.separated(
                      controller: _scrollCtrl,
                      itemCount: (_detail.posts?.length ?? 0) + 2,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _detail.title ?? '',
                              style: theme.textTheme.titleLarge,
                            ),
                          );
                        }
                        if (i == (_detail.posts?.length ?? 0) + 1) {
                          return _Pagination(
                            current: _currentPage,
                            total: _detail.totalPages ?? 1,
                            onPageChanged: (p) => _load(page: p),
                          );
                        }
                        final post = _detail.posts[i - 1] as Post;
                        return _PostTile(
                          post: post,
                          onReply: () {
                            _replyCtrl.text =
                                '回复 #${post.index} ${post.author}\n';
                            setState(() => _showReply = true);
                          },
                        );
                      },
                    ),
                  ),
                ),
                // 回复输入框
                if (_showReply) ...[
                  if (_showSmiley) SmileyPicker(onSelected: _insertSmiley),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _replyCtrl,
                              maxLines: 3,
                              minLines: 1,
                              decoration: InputDecoration(
                                hintText: FlutterI18n.translate(
                                  context,
                                  'ruisi.topic_detail.reply_hint',
                                ),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              _showSmiley
                                  ? Icons.keyboard
                                  : Icons.emoji_emotions_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _showSmiley = !_showSmiley),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            icon: const Icon(Icons.send),
                            onPressed: _submitReply,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
      floatingActionButton: _showReply
          ? null
          : FloatingActionButton(
              onPressed: () => setState(() => _showReply = true),
              child: const Icon(Icons.reply),
            ),
    );
  }
}

class _PostTile extends StatelessWidget {
  final Post post;
  final VoidCallback onReply;

  const _PostTile({required this.post, required this.onReply});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (post.avatar != null && post.avatar!.isNotEmpty)
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: post.avatar!,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const Icon(Icons.person, size: 20),
                  ),
                )
              else
                const Icon(Icons.person, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (post.time.isNotEmpty)
                      Text(post.time, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (post.index > 0)
                Text(
                  '#${post.index}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Html(
            data: post.content,
            onLinkTap: (url, _, _) {
              if (url != null) launchUrl(Uri.parse(url));
            },
            extensions: [_SmileyExtension()],
          ),
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: post.images
                  .map(
                    (img) => GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: InteractiveViewer(
                              child: CachedNetworkImage(
                                imageUrl: img.url,
                                fit: BoxFit.contain,
                                placeholder: (_, _) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (_, _, _) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: img.url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          width: 100,
                          height: 100,
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        errorWidget: (_, _, _) => Container(
                          width: 100,
                          height: 100,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.reply, size: 16),
                label: Text(
                  FlutterI18n.translate(context, 'ruisi.common.reply'),
                ),
                onPressed: onReply,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int current;
  final int total;
  final ValueChanged<int> onPageChanged;

  const _Pagination({
    required this.current,
    required this.total,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = <int>[];
    for (
      int i = (current - 2).clamp(1, total);
      i <= (current + 2).clamp(1, total);
      i++
    ) {
      pages.add(i);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (current > 1)
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onPageChanged(current - 1),
            ),
          for (final p in pages)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ChoiceChip(
                label: Text('$p'),
                selected: p == current,
                onSelected: p != current ? (_) => onPageChanged(p) : null,
                labelStyle: p == current
                    ? TextStyle(color: theme.colorScheme.onPrimary)
                    : null,
              ),
            ),
          if (current < total)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => onPageChanged(current + 1),
            ),
        ],
      ),
    );
  }
}

/// Extension to render smiley images from local assets instead of network.
///
/// Discuz posts contain smileys as `<img src="static/image/smiley/...">`.
/// The built-in [ImageBuiltIn] won't match these relative URLs.
/// This extension intercepts them and loads from bundled assets.
class _SmileyExtension extends HtmlExtension {
  @override
  Set<String> get supportedTags => {'img'};

  @override
  bool matches(ExtensionContext context) {
    if (context.elementName != 'img') return false;
    final src = context.attributes['src'] ?? '';
    return src.contains('static/image/smiley');
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final src = context.attributes['src'] ?? '';
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: _SmileyImage(src: src),
    );
  }
}

class _SmileyImage extends StatelessWidget {
  final String src;

  const _SmileyImage({required this.src});

  @override
  Widget build(BuildContext context) {
    // Extract the path after 'smiley/' from the forum URL.
    // e.g. "static/image/smiley/jgz/jgz065.png" → "smiley/jgz/jgz065.png"
    final smileyIndex = src.indexOf('smiley/');
    if (smileyIndex < 0) return const SizedBox.shrink();

    String assetPath = src.substring(smileyIndex);

    // Android parity: the 'default' category uses .gif in forum HTML
    // but the bundled assets are .png files.
    if (assetPath.contains('/default')) {
      assetPath = assetPath.replaceAll('.gif', '.png');
    }

    final fullPath = 'assets/ruisi_flutter/$assetPath';

    return Image.asset(
      fullPath,
      width: 24,
      height: 24,
      errorBuilder: (_, _, _) {
        // Local asset missing — fall back to network with full URL.
        final fullUrl = src.startsWith('http') ? src : '${Urls.baseUrl}$src';
        return Image.network(
          fullUrl,
          width: 24,
          height: 24,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        );
      },
    );
  }
}
