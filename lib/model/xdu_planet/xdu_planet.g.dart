// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xdu_planet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoList _$RepoListFromJson(Map<String, dynamic> json) =>
    RepoList()..repos = Map<String, String>.from(json['repos'] as Map);

Map<String, dynamic> _$RepoListToJson(RepoList instance) => <String, dynamic>{
      'repos': instance.repos,
    };

TitleEntry _$TitleEntryFromJson(Map<String, dynamic> json) => TitleEntry(
      title: json['title'] as String,
      time: json['time'] as int,
    );

Map<String, dynamic> _$TitleEntryToJson(TitleEntry instance) =>
    <String, dynamic>{
      'title': instance.title,
      'time': instance.time,
    };

TitleList _$TitleListFromJson(Map<String, dynamic> json) => TitleList(
      lastUpdateTime: json['lastUpdateTime'] as int,
    )..list = (json['list'] as List<dynamic>)
        .map((e) => TitleEntry.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$TitleListToJson(TitleList instance) => <String, dynamic>{
      'list': instance.list.map((e) => e.toJson()).toList(),
      'lastUpdateTime': instance.lastUpdateTime,
    };

Content _$ContentFromJson(Map<String, dynamic> json) => Content(
      title: json['title'] as String,
      link: json['link'] as String,
      content: json['content'] as String,
      time: json['time'] as int,
    );

Map<String, dynamic> _$ContentToJson(Content instance) => <String, dynamic>{
      'title': instance.title,
      'link': instance.link,
      'content': instance.content,
      'time': instance.time,
    };
