// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 表情选择器组件
///
/// 加载 smiley.json 资源，按分类展示表情网格。
/// 点击表情后通过 [onSelected] 回调返回对应的 BBCode 值（如 `{:16_998:}` 或颜文字）。
class SmileyPicker extends StatefulWidget {
  /// 点击表情时的回调，参数为表情的 value（BBCode 代码或颜文字文本）
  final ValueChanged<String> onSelected;

  const SmileyPicker({super.key, required this.onSelected});

  @override
  State<SmileyPicker> createState() => _SmileyPickerState();
}

class _SmileyPickerState extends State<SmileyPicker>
    with SingleTickerProviderStateMixin {
  List<_SmileyCategory> _categories = [];
  late TabController _tabCtrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSmileys();
  }

  Future<void> _loadSmileys() async {
    final jsonStr = await rootBundle.loadString(
      'assets/ruisi_flutter/smiley.json',
    );
    final List<dynamic> data = json.decode(jsonStr);
    final categories = data.map((e) => _SmileyCategory.fromJson(e)).toList();
    setState(() {
      _categories = categories;
      _tabCtrl = TabController(length: categories.length, vsync: this);
      _loading = false;
    });
  }

  @override
  void dispose() {
    if (!_loading) _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 280,
      child: Column(
        children: [
          // 分类 Tab 栏
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: const TextStyle(fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            tabs: _categories.map((c) => Tab(text: c.name)).toList(),
          ),
          // 表情网格
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: _categories.map((cat) {
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: cat.smileys.length,
                  itemBuilder: (_, i) {
                    final s = cat.smileys[i];
                    return InkWell(
                      onTap: () => widget.onSelected(s.value),
                      borderRadius: BorderRadius.circular(6),
                      child: s.isImage
                          ? Image.asset(
                              'assets/ruisi_flutter/smiley/${s.path}.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(
                                  s.value,
                                  style: const TextStyle(fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                s.value,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 表情分类
class _SmileyCategory {
  final String name;
  final bool isImage;
  final List<_SmileyItem> smileys;

  _SmileyCategory({
    required this.name,
    required this.isImage,
    required this.smileys,
  });

  factory _SmileyCategory.fromJson(Map<String, dynamic> json) {
    return _SmileyCategory(
      name: json['name'] as String,
      isImage: json['isImage'] as bool,
      smileys: (json['smileys'] as List)
          .map((e) => _SmileyItem.fromJson(e, json['isImage'] as bool))
          .toList(),
    );
  }
}

/// 单个表情
class _SmileyItem {
  final String value;
  final String? path;
  final bool isImage;

  _SmileyItem({required this.value, this.path, required this.isImage});

  factory _SmileyItem.fromJson(Map<String, dynamic> json, bool isImage) {
    return _SmileyItem(
      value: json['value'] as String,
      path: json['path'] as String?,
      isImage: isImage,
    );
  }
}
