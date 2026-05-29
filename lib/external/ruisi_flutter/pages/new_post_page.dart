// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';

import '../controller/ruisi_controller.dart';
import '../models/post_page_meta.dart';
import '../constants/urls.dart';
import '../../../repository/pick_file.dart';
import 'login_page.dart';
import '../widgets/smiley_picker.dart';

/// 发帖页面
class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  int? _selectedFid;
  bool _submitting = false;
  bool _showSmiley = false;
  bool _metaLoading = false;
  bool _uploading = false;
  PostPageMeta? _meta;
  int? _selectedTypeId;
  final List<_UploadedAttachment> _attachments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = RuisiController.i;
      if (!c.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return;
      }
      if (c.forumGroups.value.isEmpty) {
        c.loadForums();
      }
    });
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMeta(int fid) async {
    setState(() {
      _metaLoading = true;
      _meta = null;
      _selectedTypeId = null;
    });

    try {
      final meta = await RuisiController.i.api.loadNewPostMeta(fid);
      if (!mounted) return;
      setState(() {
        _meta = meta;
        _selectedTypeId = meta.typeOptions.isNotEmpty
            ? meta.typeOptions.first.id
            : null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载发帖信息失败: $e')));
    } finally {
      if (mounted) setState(() => _metaLoading = false);
    }
  }

  bool get _canUpload {
    return (_meta?.uploadUid != null) && (_meta?.uploadHash != null);
  }

  Future<void> _pickAndUploadImage() async {
    if (!_canUpload) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('当前板块暂不支持上传图片')));
      return;
    }

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

    setState(() => _uploading = true);
    try {
      final (ok, result) = await RuisiController.i.api.ruisiApi.uploadImage(
        Urls.uploadImageUrl,
        uid: _meta!.uploadUid!,
        hash: _meta!.uploadHash!,
        bytes: data,
        filename: file.name,
      );
      if (!ok) throw Exception(result);
      setState(
        () =>
            _attachments.add(_UploadedAttachment(aid: result, name: file.name)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('图片上传失败: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _removeAttachment(_UploadedAttachment attachment) async {
    try {
      await RuisiController.i.api.ruisiApi.post(
        Urls.deleteUploadedUrl(attachment.aid),
      );
    } catch (_) {
      // 忽略删除失败，保持列表同步即可
    }
    setState(() => _attachments.remove(attachment));
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final c = RuisiController.i;
      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, 'ruisi.post.title')),
          actions: [
            TextButton(
              onPressed: _submitting || _uploading || _metaLoading
                  ? null
                  : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(FlutterI18n.translate(context, 'ruisi.post.publish')),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 板块选择
              DropdownButtonFormField<int>(
                initialValue: _selectedFid,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(
                    context,
                    'ruisi.post.select_forum',
                  ),
                  border: const OutlineInputBorder(),
                ),
                items: c.forumGroups.value
                    .expand((g) => g.forums)
                    .map(
                      (f) =>
                          DropdownMenuItem(value: f.fid, child: Text(f.name)),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedFid = v);
                  if (v != null) _loadMeta(v);
                },
                validator: (v) => v == null
                    ? FlutterI18n.translate(
                        context,
                        'ruisi.post.select_forum_hint',
                      )
                    : null,
              ),
              const SizedBox(height: 16),

              if (_metaLoading) const LinearProgressIndicator(minHeight: 2),
              if (_meta != null && _meta!.typeOptions.isNotEmpty) ...[
                DropdownButtonFormField<int>(
                  initialValue: _selectedTypeId,
                  items: _meta!.typeOptions
                      .map(
                        (t) =>
                            DropdownMenuItem(value: t.id, child: Text(t.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTypeId = v),
                  decoration: const InputDecoration(
                    labelText: '主题分类',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 标题
              TextFormField(
                controller: _subjectCtrl,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(
                    context,
                    'ruisi.post.subject',
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? FlutterI18n.translate(context, 'ruisi.post.subject_hint')
                    : null,
              ),
              const SizedBox(height: 16),

              // 内容
              TextFormField(
                controller: _contentCtrl,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(
                    context,
                    'ruisi.post.content',
                  ),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 12,
                validator: (v) => (v == null || v.isEmpty)
                    ? FlutterI18n.translate(context, 'ruisi.post.content_hint')
                    : null,
              ),
              const SizedBox(height: 8),

              // 表情工具栏
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _showSmiley
                          ? Icons.keyboard
                          : Icons.emoji_emotions_outlined,
                    ),
                    tooltip: FlutterI18n.translate(
                      context,
                      'ruisi.post.smiley',
                    ),
                    onPressed: () => setState(() => _showSmiley = !_showSmiley),
                  ),
                  IconButton(
                    icon: _uploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.image_outlined),
                    tooltip: '上传图片',
                    onPressed: _uploading || !_canUpload
                        ? null
                        : _pickAndUploadImage,
                  ),
                ],
              ),

              // 表情面板
              if (_showSmiley) SmileyPicker(onSelected: _insertSmiley),
              if (_attachments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _attachments
                        .map(
                          (a) => Chip(
                            label: Text(a.name),
                            onDeleted: () => _removeAttachment(a),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  void _insertSmiley(String value) {
    final text = _contentCtrl.text;
    final selection = _contentCtrl.selection;
    final cursorPos = selection.isValid ? selection.start : text.length;

    final newText =
        text.substring(0, cursorPos) + value + text.substring(cursorPos);
    _contentCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + value.length),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFid == null) return;

    setState(() => _submitting = true);

    final (ok, error) = await RuisiController.i.api.newPost(
      _selectedFid!,
      _subjectCtrl.text,
      _contentCtrl.text,
      _attachments.map((a) => a.aid).toList(),
      _selectedTypeId,
    );

    setState(() => _submitting = false);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(FlutterI18n.translate(context, 'ruisi.post.success')),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? FlutterI18n.translate(context, 'ruisi.post.failure'),
          ),
        ),
      );
    }
  }
}

class _UploadedAttachment {
  final String aid;
  final String name;

  const _UploadedAttachment({required this.aid, required this.name});
}
