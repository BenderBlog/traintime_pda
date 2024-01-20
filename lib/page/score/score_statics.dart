// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

const double cardWidth = 280;

enum ChoiceState {
  /// All stuff from the index array.
  all,

  /// None stuff from the index array.
  none,

  /// Original stuff from the index array.
  original,
}

final courseIgnore = [
  '军事',
  '形势与政策',
  '创业基础',
  '新生',
  '写作与沟通',
  '学科导论',
  '心理',
  '物理实验',
];

final typesIgnore = [
  '通识教育选修课',
  '集中实践环节',
  '拓展提高',
  '通识教育核心课',
  '专业选修课',
];

const notCoreClassType = "公共任选";
