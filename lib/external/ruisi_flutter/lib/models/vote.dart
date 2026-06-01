// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

/// 投票状态
enum VoteStatus {
  /// 可投票（未投过 + 未过期）
  canVote,

  /// 已投票（显示结果）
  voted,

  /// 已过期 / 已关闭（无结果数据）
  expired,

  /// 投票已结束 + 有结果数据（用户可能投过也可能没投）
  endedWithResults,

  /// 可投票 + 同时显示结果分布（投票设置允许投票前看结果）
  canVoteWithResults,
}

/// 投票选项（可投票状态下使用）
class VoteOption {
  final String value; // pollanswers[] 的值
  final String label; // 显示文本

  const VoteOption({required this.value, required this.label});
}

/// 投票结果项（已投票/已过期状态下使用）
class VoteResultItem {
  final String label; // 选项文本
  final double percent; // 百分比 0-100
  final int count; // 票数
  final String color; // 进度条颜色（hex）

  const VoteResultItem({
    required this.label,
    required this.percent,
    required this.count,
    this.color = '#999999',
  });
}

/// 投票数据（从帖子 HTML 中解析）
///
/// 五种状态：
/// - [VoteStatus.canVote]：显示选项 + 提交按钮（无结果）
/// - [VoteStatus.canVoteWithResults]：显示选项 + 提交按钮 + 结果分布
/// - [VoteStatus.voted]：显示结果列表 + 已投票提示（投票进行中）
/// - [VoteStatus.expired]：显示过期提示（无结果）
/// - [VoteStatus.endedWithResults]：显示结果列表 + 已结束提示
class VoteData {
  final VoteStatus status;
  final String actionUrl; // 投票提交 URL（完整地址）
  final List<VoteOption> options; // 仅 canVote 状态有值
  final List<VoteResultItem> results; // voted / endedWithResults 状态有值
  final int maxSelection; // 最大可选数（1 = 单选）
  final int voteCount; // 已参与投票人数
  final bool isPublic; // 是否公开投票

  const VoteData({
    required this.status,
    required this.actionUrl,
    this.options = const [],
    this.results = const [],
    this.maxSelection = 1,
    this.voteCount = 0,
    this.isPublic = false,
  });
}
