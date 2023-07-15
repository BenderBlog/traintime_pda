// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xdu_planet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Repo _$RepoFromJson(Map<String, dynamic> json) => Repo(
      name: json['name'] as String,
      website: json['website'] as String,
      feed: json['feed'] as String,
      favicon: json['favicon'] as String,
    );

Map<String, dynamic> _$RepoToJson(Repo instance) => <String, dynamic>{
      'name': instance.name,
      'website': instance.website,
      'feed': instance.feed,
      'favicon': instance.favicon,
    };

RepoList _$RepoListFromJson(Map<String, dynamic> json) => RepoList(
      repos: (json['repos'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Repo.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$RepoListToJson(RepoList instance) => <String, dynamic>{
      'repos': instance.repos.map((k, e) => MapEntry(k, e.toJson())),
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
