// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

class TeleyInformation {
  TeleyInformation({
    required this.title,
    this.northAddress,
    this.southAddress,
    this.northTeley,
    this.southTeley,
    this.isNorth = false,
    this.isSouth = false,
  });

  String title;
  bool? isNorth;
  bool? isSouth;
  String? northAddress;
  String? southAddress;
  String? northTeley;
  String? southTeley;
}
