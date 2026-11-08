// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

/// Returns the original indices of overlapping ranges. Touching endpoints do not overlap.
Set<int> findOverlappingTimeRangeIndices(List<(DateTime, DateTime)> ranges) {
  if (ranges.length < 2) return {};

  // 给输入构建索引并依据开始时间来排序
  final sortedIndices = List.generate(ranges.length, (index) => index)
    ..sort((a, b) => ranges[a].$1.compareTo(ranges[b].$1));
  final overlapping = <int>{};
  // 记录最迟的结束时间的索引
  var latestEndIndex = sortedIndices.first;

  for (final index in sortedIndices.skip(1)) {
    if (ranges[index].$1.isBefore(ranges[latestEndIndex].$2)) {
      overlapping.add(latestEndIndex);
      overlapping.add(index);
    }
    if (ranges[index].$2.isAfter(ranges[latestEndIndex].$2)) {
      latestEndIndex = index;
    }
  }
  return overlapping;
}
