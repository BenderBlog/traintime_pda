// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'xdu_planet.g.dart';

@JsonSerializable(explicitToJson: true)
class Article {
  final String title;
  final DateTime time;
  final String content;
  final String url;
  String? author;

  Article({
    required this.title,
    required this.time,
    required this.content,
    required this.url,
    this.author,
  });

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleToJson(this);

  String get id => content.replaceAll("db/", "").replaceAll(".txt", "");
  DateTime get articleTime => time.toLocal();
}

@JsonSerializable(explicitToJson: true)
class Person {
  final String name;
  final String email;
  final String uri;
  final String description;
  final List<Article> article;

  Person({
    required this.name,
    required this.email,
    required this.uri,
    required this.description,
    required this.article,
  });

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  Map<String, dynamic> toJson() => _$PersonToJson(this);
}

@JsonSerializable(explicitToJson: true)
class XDUPlanetDatabase {
  final List<Person> author;
  final DateTime update;

  XDUPlanetDatabase({
    required this.author,
    required this.update,
  });

  factory XDUPlanetDatabase.fromJson(Map<String, dynamic> json) =>
      _$XDUPlanetDatabaseFromJson(json);

  Map<String, dynamic> toJson() => _$XDUPlanetDatabaseToJson(this);
}

@JsonSerializable()
class XDUPlanetComment {
  final int ID;
  final DateTime CreatedAt;
  final DateTime UpdatedAt;
  final String article_id;
  final String content;
  final String user_id;
  final String reply_to;
  final String status;

  XDUPlanetComment({
    required this.ID,
    required this.CreatedAt,
    required this.UpdatedAt,
    required this.article_id,
    required this.content,
    required this.user_id,
    required this.reply_to,
    required this.status,
  });

  factory XDUPlanetComment.fromJson(Map<String, dynamic> json) =>
      _$XDUPlanetCommentFromJson(json);

  Map<String, dynamic> toJson() => _$XDUPlanetCommentToJson(this);

  // 可选值为ok、block、delete、audit，分别表示已通过、已屏蔽、已删除、待审核
  String get statusStr {
    if (status.isNotEmpty && status != "ok") return "xdu_planet.$status";
    return "";
  }
}
