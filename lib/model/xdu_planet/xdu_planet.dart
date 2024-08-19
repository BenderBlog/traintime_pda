// Copyright 2023 BenderBlog Rodriguez and contributors.
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

  String get id =>
      RegExp(r'([0-9]+)_([0-9]+)').firstMatch(content)?.group(0).toString() ??
      "";
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
  final int version;
  final List<Person> author;
  final DateTime update;

  XDUPlanetDatabase({
    required this.version,
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

  XDUPlanetComment({
    required this.ID,
    required this.CreatedAt,
    required this.UpdatedAt,
    required this.article_id,
    required this.content,
    required this.user_id,
    required this.reply_to,
  });

  factory XDUPlanetComment.fromJson(Map<String, dynamic> json) =>
      _$XDUPlanetCommentFromJson(json);

  Map<String, dynamic> toJson() => _$XDUPlanetCommentToJson(this);
}
