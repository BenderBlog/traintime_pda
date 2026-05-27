// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

/// 回复通知
class ReplyNotification {
  final int id;
  final int tid;
  final String title;
  final String author;
  final String time;
  final String snippet;
  final int pid;
  final bool isNew;

  ReplyNotification({
    required this.id,
    required this.tid,
    required this.title,
    required this.author,
    required this.time,
    required this.snippet,
    this.pid = 0,
    this.isNew = false,
  });
}

/// @通知
class AtNotification {
  final int id;
  final int tid;
  final String title;
  final String author;
  final String time;
  final String snippet;
  final int pid;
  final bool isNew;

  AtNotification({
    required this.id,
    required this.tid,
    required this.title,
    required this.author,
    required this.time,
    required this.snippet,
    this.pid = 0,
    this.isNew = false,
  });
}

/// 聊天会话列表项
class ChatSession {
  final int toUid;
  final String toUsername;
  final String lastMessage;
  final String time;
  final int unread;

  ChatSession({
    required this.toUid,
    required this.toUsername,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
  });
}

/// 聊天消息
class ChatMessage {
  final int pmId;
  final int fromUid;
  final int toUid;
  final String fromUsername;
  final String content;
  final String time;
  final bool isFromMe;

  ChatMessage({
    required this.pmId,
    required this.fromUid,
    required this.toUid,
    required this.fromUsername,
    required this.content,
    required this.time,
    required this.isFromMe,
  });
}

/// 签到结果
class SignResult {
  final bool alreadySigned;
  final String? message;
  final int? consecutiveDays;

  SignResult({this.alreadySigned = false, this.message, this.consecutiveDays});
}

/// 用户信息
class UserInfo {
  final int uid;
  final String username;
  final String? avatarUrl;
  final int? posts;
  final int? credits;
  final int? money;
  final String? signature;
  final String? lastActiveTime;

  UserInfo({
    required this.uid,
    required this.username,
    this.avatarUrl,
    this.posts,
    this.credits,
    this.money,
    this.signature,
    this.lastActiveTime,
  });
}
