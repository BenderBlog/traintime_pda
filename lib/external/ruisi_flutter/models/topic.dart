// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

/// 帖子列表项
class Topic {
  final int tid;
  final int fid;
  final String title;
  final String author;
  final int authorId;
  final int views;
  final int replies;
  final String? lastReplyTime;
  final bool isStick; // 置顶
  final bool isImage; // 图片帖
  final String? imageUrl; // 封面图
  final int? categoryId;
  final String? categoryName;

  Topic({
    required this.tid,
    required this.fid,
    required this.title,
    required this.author,
    required this.authorId,
    this.views = 0,
    this.replies = 0,
    this.lastReplyTime,
    this.isStick = false,
    this.isImage = false,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
  });
}
