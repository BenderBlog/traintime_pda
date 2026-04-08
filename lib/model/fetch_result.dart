// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

class FetchResult<T> {
  final bool isCache;
  final DateTime fetchTime;
  final T data;
  final String? hintKey;

  const FetchResult._({
    required this.isCache,
    required this.fetchTime,
    required this.data,
    this.hintKey,
  });

  factory FetchResult.fresh({required DateTime fetchTime, required T data}) =>
      FetchResult._(isCache: false, fetchTime: fetchTime, data: data);

  factory FetchResult.cache({
    required DateTime fetchTime,
    required T data,
    String? hintKey,
  }) => FetchResult._(
    isCache: true,
    fetchTime: fetchTime,
    data: data,
    hintKey: hintKey,
  );
}
