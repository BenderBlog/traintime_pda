// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

/// 论坛板块
class Forum {
  final int fid;
  final String name;
  final int todayPosts;
  final int totalPosts;
  final String? description;
  final String? iconUrl;

  Forum({
    required this.fid,
    required this.name,
    this.todayPosts = 0,
    this.totalPosts = 0,
    this.description,
    this.iconUrl,
  });
}

/// 论坛板块分组
class ForumGroup {
  final int fgId;
  final String name;
  final List<Forum> forums;

  ForumGroup({required this.fgId, required this.name, required this.forums});
}
