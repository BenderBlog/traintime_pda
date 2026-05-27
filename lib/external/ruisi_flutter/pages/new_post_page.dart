// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';

import '../controller/ruisi_controller.dart';
import 'login_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final c = RuisiController.i;

      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, 'ruisi.post.title')),
          actions: [
            TextButton(
              onPressed: _submitting ? null : _submit,
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
                value: _selectedFid,
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
                onChanged: (v) => setState(() => _selectedFid = v),
                validator: (v) => v == null
                    ? FlutterI18n.translate(
                        context,
                        'ruisi.post.select_forum_hint',
                      )
                    : null,
              ),
              const SizedBox(height: 16),

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
            ],
          ),
        ),
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFid == null) return;

    setState(() => _submitting = true);

    final c = RuisiController.i;
    final (ok, error) = await c.newPost(
      _selectedFid!,
      _subjectCtrl.text,
      _contentCtrl.text,
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
