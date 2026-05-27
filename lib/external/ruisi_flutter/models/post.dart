// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

/// 帖子内容中的图片信息
class ImageAttachment {
  final int aid;
  final String url;
  final String? thumbUrl;
  final int width;
  final int height;
  final String filename;

  ImageAttachment({
    required this.aid,
    required this.url,
    this.thumbUrl,
    this.width = 0,
    this.height = 0,
    required this.filename,
  });
}

/// 帖子回复
class Post {
  final int pid;
  final int tid;
  final int authorId;
  final String author;
  final String? avatar; // 头像 URL（直接从 HTML 提取）
  final String time;
  final String content;
  final bool isQuote;
  final List<ImageAttachment> images;
  final String? replyUrl; // 回复链接
  final int index; // 楼层

  Post({
    required this.pid,
    required this.tid,
    required this.authorId,
    required this.author,
    this.avatar,
    required this.time,
    required this.content,
    this.isQuote = false,
    this.images = const [],
    this.replyUrl,
    this.index = 0,
  });
}

/// 帖子详情
class TopicDetail {
  final int tid;
  final int fid;
  final String title;
  final String author;
  final int authorId;
  final String time;
  final int replies;
  final bool isFavorite;
  final String? typeId;
  final List<Post> posts;
  final int currentPage;
  final int totalPages;

  TopicDetail({
    required this.tid,
    required this.fid,
    required this.title,
    required this.author,
    required this.authorId,
    required this.time,
    this.replies = 0,
    this.isFavorite = false,
    this.typeId,
    this.posts = const [],
    this.currentPage = 1,
    this.totalPages = 1,
  });
}
