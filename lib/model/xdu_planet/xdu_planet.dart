/*
XDU Planet response body structure.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

import 'package:json_annotation/json_annotation.dart';

part 'xdu_planet.g.dart';

@JsonSerializable(explicitToJson: true)
class RepoList {
  Map<String, String> repos = {};

  RepoList();

  factory RepoList.fromJson(Map<String, dynamic> json) =>
      _$RepoListFromJson(json);

  Map<String, dynamic> toJson() => _$RepoListToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TitleEntry {
  String title;
  int time;

  TitleEntry({
    required this.title,
    required this.time,
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
