// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controller/ruisi_controller.dart';
import '../models/post.dart';
import '../models/vote.dart';
import '../constants/urls.dart';
import '../widgets/smiley_picker.dart';
import '../../../repository/pick_file.dart';

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
  bool _replyUploading = false;
  bool _replySubmitting = false;
  final List<_UploadedAttachment> _replyAttachments = [];
  RuisiService c = GetIt.instance<RuisiService>();

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
      final detail = await c.api.getTopicDetail(widget.tid, page: page);
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

    setState(() => _replySubmitting = true);

    bool ok = false;
    try {
      final aids = _replyAttachments.map((a) => a.aid).toList();
      ok = await c.api.replyTopicWithAttachments(widget.tid, content, aids);
    } finally {
      if (mounted) setState(() => _replySubmitting = false);
    }

    if (!mounted) return;

    if (ok) {
      _replyCtrl.clear();
      setState(() {
        _showReply = false;
        _showSmiley = false;
        _replyAttachments.clear();
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

  Future<void> _pickReplyImage() async {
    final file = await pickFile();
    if (file == null) return;
    if (!mounted) return;

    final ext = file.extension?.toLowerCase();
    const allowed = {'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'};
    if (ext == null || !allowed.contains(ext)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('仅支持 jpg/jpeg/png/gif/bmp/webp 图片')),
      );
      return;
    }

    final data = await file.readAsBytes();
    if (!mounted) return;
    if (data.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('读取图片失败')));
      return;
    }

    setState(() => _replyUploading = true);
    try {
      final meta = await c.api.loadReplyUploadMeta(widget.tid);
      final uid = meta.uploadUid ?? '';
      final hash = meta.uploadHash ?? '';
      final (ok, result) = await c.api.ruisiApi.uploadImage(
        Urls.uploadImageUrl,
        uid: uid,
        hash: hash,
        bytes: data,
        filename: file.name,
      );
      if (!ok) throw Exception(result);
      final parts = result.split('|');
      final aid = parts.isNotEmpty ? parts.first : result;
      final thumbnailUrl = parts.length > 1 ? parts[1] : '';
      setState(() {
        _replyAttachments.add(
          _UploadedAttachment(aid: aid, thumbnailUrl: thumbnailUrl),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('图片上传失败: $e')));
    } finally {
      if (mounted) setState(() => _replyUploading = false);
    }
  }

  Future<void> _addFavorite() async {
    final ok = await c.api.addFavorite(widget.tid);
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

    final blockPop = _replyUploading || _replySubmitting;
    return PopScope(
      canPop: !blockPop,
      child: Scaffold(
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
                        itemCount:
                            (_detail.posts?.length ?? 0) +
                            2 +
                            (_currentPage == 1 && _detail.vote != null ? 1 : 0),
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          // 投票卡片插在标题(index 0)之后
                          final hasVote =
                              _currentPage == 1 && _detail.vote != null;
                          final voteOffset = hasVote ? 1 : 0;

                          if (i == 0) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                _detail.title ?? '',
                                style: theme.textTheme.titleLarge,
                              ),
                            );
                          }

                          if (hasVote && i == 1) {
                            return _VoteCard(
                              vote: _detail.vote!,
                              onVote: () => _showVoteSheet(_detail.vote!),
                            );
                          }

                          final postIndex = i - 1 - voteOffset;
                          if (postIndex >= (_detail.posts?.length ?? 0)) {
                            return _Pagination(
                              current: _currentPage,
                              total: _detail.totalPages ?? 1,
                              onPageChanged: (p) => _load(page: p),
                            );
                          }
                          final post = _detail.posts[postIndex] as Post;
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
                              onPressed: _replyUploading || _replySubmitting
                                  ? null
                                  : () => setState(
                                      () => _showSmiley = !_showSmiley,
                                    ),
                            ),
                            IconButton(
                              icon: _replyUploading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.image_outlined),
                              tooltip: '上传图片',
                              onPressed: _replyUploading || _replySubmitting
                                  ? null
                                  : _pickReplyImage,
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              icon: const Icon(Icons.send),
                              onPressed: _replyUploading || _replySubmitting
                                  ? null
                                  : _submitReply,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_replyAttachments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _replyAttachments
                            .map(
                              (a) => Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: a.thumbnailUrl.isNotEmpty
                                        ? Image.network(
                                            a.thumbnailUrl,
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 64,
                                            height: 64,
                                            color: theme
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      try {
                                        await c.api.ruisiApi.post(
                                          Urls.deleteUploadedUrl(a.aid),
                                        );
                                      } catch (_) {}
                                      setState(
                                        () => _replyAttachments.remove(a),
                                      );
                                    },
                                    child: const CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.black54,
                                      child: Icon(
                                        Icons.close,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
        floatingActionButton: _showReply
            ? null
            : FloatingActionButton(
                onPressed: () => setState(() => _showReply = true),
                child: const Icon(Icons.reply),
              ),
      ),
    );
  }

  Future<void> _showVoteSheet(VoteData vote) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _VoteSheet(vote: vote),
    );
    if (result == true && mounted) {
      _load(page: _currentPage);
    }
  }
}

class _UploadedAttachment {
  final String aid;
  final String thumbnailUrl;

  const _UploadedAttachment({required this.aid, this.thumbnailUrl = ''});
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
            extensions: [_SmileyExtension(), _IgnoreJsOpExtension()],
          ),

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

/// Extension to render `<ignore_js_op>` tags from Discuz desktop HTML.
///
/// Three variants:
/// 1. Pure image:       `<img file="real.jpg" src="none.gif"/>`
/// 2. File-style image: `<dl class="tattl attm">...<img file="real.jpg"/>...`
/// 3. Pure file:        `<dl class="tattl">...<a>filename.pdf</a>...`
class _IgnoreJsOpExtension extends HtmlExtension {
  @override
  Set<String> get supportedTags => {'ignore_js_op'};

  @override
  bool matches(ExtensionContext context) =>
      context.elementName == 'ignore_js_op';

  @override
  InlineSpan build(ExtensionContext context) {
    final el = context.element;

    // 1. Pure image: direct <img file="..."> child
    final directImg = el?.querySelector('img[file]');
    if (directImg != null) {
      final file = directImg.attributes['file'] ?? '';
      if (file.isNotEmpty) {
        final url = file.startsWith('http') ? file : '${Urls.baseUrl}$file';
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _IgnoreJsOpImage(url: url),
        );
      }
    }

    // 2 & 3. <dl class="tattl ..."> child
    final dl = el?.querySelector('dl.tattl');
    if (dl != null) {
      // 2. File-style image: has class "attm" and contains img[file]
      if (dl.className.contains('attm')) {
        final img = dl.querySelector('img[file]');
        final file = img?.attributes['file'] ?? '';
        if (file.isNotEmpty) {
          final url = file.startsWith('http') ? file : '${Urls.baseUrl}$file';
          return WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _IgnoreJsOpImage(url: url),
          );
        }
      }

      // 3. Pure file: has .attnm with download link
      final linkEl = dl.querySelector('.attnm a');
      if (linkEl != null) {
        final href = linkEl.attributes['href'] ?? '';
        final fileName = linkEl.text.trim();
        final sizeText = dl.querySelectorAll('dd p').length > 1
            ? dl.querySelectorAll('dd p')[1].text.trim()
            : null;
        final fullUrl = href.startsWith('http') ? href : '${Urls.baseUrl}$href';
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _IgnoreJsOpFileCard(
            fileName: fileName,
            sizeText: sizeText,
            url: fullUrl,
          ),
        );
      }
    }

    // Fallback: unknown structure, render nothing
    return WidgetSpan(
      child: Text("Unknown ignore_js_op element: \n ${context.element}"),
    );
  }
}

/// Network image used by [_IgnoreJsOpExtension] for pure/file-style images.
class _IgnoreJsOpImage extends StatelessWidget {
  final String url;
  const _IgnoreJsOpImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (_, _) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, _, _) => const Icon(Icons.broken_image),
                ),
              ),
            ),
          );
        },
        child: CachedNetworkImage(
          imageUrl: url,
          placeholder: (_, _) =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          errorWidget: (_, _, _) => const Icon(Icons.broken_image, size: 48),
        ),
      ),
    );
  }
}

/// File attachment card used by [_IgnoreJsOpExtension] for pure files.
class _IgnoreJsOpFileCard extends StatelessWidget {
  final String fileName;
  final String? sizeText;
  final String url;
  const _IgnoreJsOpFileCard({
    required this.fileName,
    this.sizeText,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.insert_drive_file),
        title: Text(fileName, overflow: TextOverflow.ellipsis),
        subtitle: sizeText != null ? Text(sizeText!) : null,
        trailing: const Icon(Icons.download),
        onTap: () => launchUrl(Uri.parse(url)),
      ),
    );
  }
}

/// 投票摘要卡片（帖子详情页内嵌）
///
/// 三种状态：
/// - canVote：显示选项列表 + "点此投票"按钮
/// - voted：显示结果进度条 + 已投票提示
/// - expired：显示过期提示
class _VoteCard extends StatelessWidget {
  final VoteData vote;
  final VoidCallback onVote;

  const _VoteCard({required this.vote, required this.onVote});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeText = vote.maxSelection > 1
        ? FlutterI18n.translate(
            context,
            'ruisi.topic_detail.vote.multi_select',
            translationParams: {'count': '${vote.maxSelection}'},
          )
        : FlutterI18n.translate(
            context,
            'ruisi.topic_detail.vote.single_select',
          );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Icon(
                Icons.how_to_vote,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${FlutterI18n.translate(context, 'ruisi.topic_detail.vote.title_prefix')} · $typeText',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            FlutterI18n.translate(
              context,
              'ruisi.topic_detail.vote.count',
              translationParams: {'count': '${vote.voteCount}'},
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),

          // 按状态分发内容
          if (vote.status == VoteStatus.expired) ...[
            // 选项标签（如果有）
            for (final opt in vote.options)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(opt.label, style: theme.textTheme.bodyMedium),
              ),
            const SizedBox(height: 8),
            Text(
              FlutterI18n.translate(context, 'ruisi.topic_detail.vote.expired'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ] else if (vote.status == VoteStatus.voted) ...[
            // 已投票（投票进行中）：结果列表 + 已投票提示
            for (final r in vote.results) _ResultRow(result: r),
            const SizedBox(height: 8),
            Text(
              FlutterI18n.translate(
                context,
                'ruisi.topic_detail.vote.already_voted',
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ] else if (vote.status == VoteStatus.endedWithResults) ...[
            // 投票已结束 + 有结果：结果列表 + 已结束提示
            for (final r in vote.results) _ResultRow(result: r),
            const SizedBox(height: 8),
            Text(
              FlutterI18n.translate(context, 'ruisi.topic_detail.vote.ended'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ] else if (vote.status == VoteStatus.canVoteWithResults) ...[
            // 可投票 + 显示分布：选项列表 + 结果 + 投票按钮
            for (final r in vote.results) _ResultRow(result: r),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: onVote,
              child: Text(
                FlutterI18n.translate(context, 'ruisi.topic_detail.vote.open'),
              ),
            ),
          ] else ...[
            // 可投票：选项列表
            for (final opt in vote.options)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(opt.label, style: theme.textTheme.bodyMedium),
              ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: onVote,
              child: Text(
                FlutterI18n.translate(context, 'ruisi.topic_detail.vote.open'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 单行投票结果（进度条 + 百分比 + 票数）
class _ResultRow extends StatelessWidget {
  final VoteResultItem result;
  const _ResultRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(int.parse(result.color.replaceFirst('#', '0xff')));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(result.label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: result.percent / 100,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${result.percent.toStringAsFixed(2)}% (${result.count})',
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 投票底部弹窗（仅 canVote 状态使用）
class _VoteSheet extends StatefulWidget {
  final VoteData vote;
  const _VoteSheet({required this.vote});

  @override
  State<_VoteSheet> createState() => _VoteSheetState();
}

class _VoteSheetState extends State<_VoteSheet> {
  final Set<String> _selected = {};
  bool _submitting = false;

  bool get _isMulti => widget.vote.maxSelection > 1;

  void _toggle(String value) {
    setState(() {
      if (_isMulti) {
        if (_selected.contains(value)) {
          _selected.remove(value);
        } else if (_selected.length < widget.vote.maxSelection) {
          _selected.add(value);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                FlutterI18n.translate(
                  context,
                  'ruisi.topic_detail.vote.max_selection',
                  translationParams: {'count': '${widget.vote.maxSelection}'},
                ),
              ),
            ),
          );
        }
      } else {
        _selected
          ..clear()
          ..add(value);
      }
    });
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FlutterI18n.translate(
              context,
              'ruisi.topic_detail.vote.not_selected',
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final (ok, err) = await GetIt.instance<RuisiService>().api.submitVote(
        widget.vote.actionUrl,
        _selected.toList(),
      );
      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              FlutterI18n.translate(context, 'ruisi.topic_detail.vote.success'),
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              err ??
                  FlutterI18n.translate(
                    context,
                    'ruisi.topic_detail.vote.failure',
                  ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeText = _isMulti
        ? FlutterI18n.translate(
            context,
            'ruisi.topic_detail.vote.multi_select',
            translationParams: {'count': '${widget.vote.maxSelection}'},
          )
        : FlutterI18n.translate(
            context,
            'ruisi.topic_detail.vote.single_select',
          );

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${FlutterI18n.translate(context, 'ruisi.topic_detail.vote.sheet_title')}($typeText)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: widget.vote.options.length,
                itemBuilder: (_, idx) {
                  final opt = widget.vote.options[idx];
                  final checked = _selected.contains(opt.value);
                  return _isMulti
                      ? CheckboxListTile(
                          value: checked,
                          title: Text(opt.label),
                          onChanged: (_) => _toggle(opt.value),
                        )
                      : RadioListTile<String>(
                          value: opt.value,
                          groupValue: _selected.isEmpty
                              ? null
                              : _selected.first,
                          title: Text(opt.label),
                          onChanged: (_) => _toggle(opt.value),
                        );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            FlutterI18n.translate(
                              context,
                              'ruisi.common.submit',
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
