// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xdu_planet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Article _$ArticleFromJson(Map<String, dynamic> json) => Article(
      title: json['title'] as String,
      time: DateTime.parse(json['time'] as String),
      content: json['content'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
      'title': instance.title,
      'time': instance.time.toIso8601String(),
      'content': instance.content,
      'url': instance.url,
    };

Person _$PersonFromJson(Map<String, dynamic> json) => Person(
      name: json['name'] as String,
      email: json['email'] as String,
      uri: json['uri'] as String,
      description: json['description'] as String,
      article: (json['article'] as List<dynamic>)
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'uri': instance.uri,
      'description': instance.description,
      'article': instance.article.map((e) => e.toJson()).toList(),
    };

XDUPlanetDatabase _$XDUPlanetDatabaseFromJson(Map<String, dynamic> json) =>
    XDUPlanetDatabase(
      version: (json['version'] as num).toInt(),
      author: (json['author'] as List<dynamic>)
          .map((e) => Person.fromJson(e as Map<String, dynamic>))
          .toList(),
      update: DateTime.parse(json['update'] as String),
    );

Map<String, dynamic> _$XDUPlanetDatabaseToJson(XDUPlanetDatabase instance) =>
    <String, dynamic>{
      'version': instance.version,
      'author': instance.author.map((e) => e.toJson()).toList(),
      'update': instance.update.toIso8601String(),
    };
