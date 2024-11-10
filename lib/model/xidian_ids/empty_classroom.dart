// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

class EmptyClassroomPlace {
  final String name;
  final String code;

  EmptyClassroomPlace({
    required this.name,
    required this.code,
  });
}

class EmptyClassroomData {
  final String name;
  final List<bool> isUsed;

  EmptyClassroomData({
    required this.name,
    required this.isUsed,
  }) : assert(isUsed.length == 10);
}
