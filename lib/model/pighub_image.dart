// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'pighub_image.g.dart';

@JsonSerializable()
class PigHubImage {
  final int id;
  @JsonKey(name: "image_url")
  final String imageUrl; // relative path, e.g. /data/xxx.jpg
  final String title;
  @JsonKey(name: "view_count")
  final int viewCount;

  const PigHubImage({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.viewCount,
  });

  factory PigHubImage.fromJson(Map<String, dynamic> json) =>
      _$PigHubImageFromJson(json);

  Map<String, dynamic> toJson() => _$PigHubImageToJson(this);

  /// Full URL of the image.
  String get url => "https://www.pighub.top/$imageUrl";
}
