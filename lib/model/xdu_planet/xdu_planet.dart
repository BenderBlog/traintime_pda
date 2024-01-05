// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';

part 'xdu_planet.g.dart';

/*
@JsonSerializable(explicitToJson: true)
class Repo {
  String name;
  String website;
  String feed;
  String favicon;

  Repo({
    required this.name,
    required this.website,
    required this.feed,
    required this.favicon,
  });

  factory Repo.fromJson(Map<String, dynamic> json) => _$RepoFromJson(json);

  Map<String, dynamic> toJson() => _$RepoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RepoList {
  Map<String, Repo> repos;

  RepoList({required this.repos});

  factory RepoList.fromJson(Map<String, dynamic> json) =>
      _$RepoListFromJson(json);

  Map<String, dynamic> toJson() => _$RepoListToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TitleEntry {
  String title;
  DateTime time;
  String url;

  TitleEntry({
    required this.title,
    required this.time,
    required this.url,
  });

  factory TitleEntry.fromJson(Map<String, dynamic> json) =>
      _$TitleEntryFromJson(json);

  Map<String, dynamic> toJson() => _$TitleEntryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TitleList {
  List<TitleEntry> list = [];
  int lastUpdateTime;

  TitleList({
    required this.lastUpdateTime,
  });

  factory TitleList.fromJson(Map<String, dynamic> json) =>
      _$TitleListFromJson(json);

  Map<String, dynamic> toJson() => _$TitleListToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Content {
  String title;
  String link;
  String content;
  int time;

  Content({
    required this.title,
    required this.link,
    required this.content,
    required this.time,
  });

  factory Content.fromJson(Map<String, dynamic> json) =>
      _$ContentFromJson(json);

  Map<String, dynamic> toJson() => _$ContentToJson(this);
}
*/
@JsonSerializable(explicitToJson: true)
class Article {
  final String title;
  final DateTime time;
  final String content;
  final String url;

  Article({
    required this.title,
    required this.time,
    required this.content,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleToJson(this);
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
