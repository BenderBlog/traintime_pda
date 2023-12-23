// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

enum ChoiceState {
  /// All stuff from the index array.
  all,

  /// None stuff from the index array.
  none,

  /// Original stuff from the index array.
  original,
}

const courseIgnore = [
  '军事',
  '形势与政策',
  '创业基础',
  '新生',
  '写作与沟通',
  '学科导论',
  '心理',
  '物理实验',
  '工程概论',
  '达标测试',
  '大学生职业发展',
  '国家英语四级',
  '劳动教育',
  '思想政治理论实践课',
  '就业指导',
];

const statusIgnore = [
  '学院选修（任选）',
  '非标',
  '公共任选',
];

const notFinish = "(成绩没登完)";
const notFirstTime = "(非初修)";
const notCoreClassType = "公共任选";
