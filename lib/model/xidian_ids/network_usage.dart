// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

class NetworkUsage {
  // (ip, online_time, used_t)
  final List<(String, String, String)> ipList;
  final String used;
  final String rest;
  final String charged;

  const NetworkUsage({
    required this.ipList,
    required this.used,
    required this.rest,
    required this.charged,
  });
}
