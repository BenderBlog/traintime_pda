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
      author: json['author'] as String?,
    );

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
      'title': instance.title,
      'time': instance.time.toIso8601String(),
      'content': instance.content,
      'url': instance.url,
      'author': instance.author,
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

XDUPlanetComment _$XDUPlanetCommentFromJson(Map<String, dynamic> json) =>
    XDUPlanetComment(
      ID: (json['ID'] as num).toInt(),
      CreatedAt: DateTime.parse(json['CreatedAt'] as String),
      UpdatedAt: DateTime.parse(json['UpdatedAt'] as String),
      article_id: json['article_id'] as String,
      content: json['content'] as String,
      user_id: json['user_id'] as String,
      reply_to: json['reply_to'] as String,
    );

Map<String, dynamic> _$XDUPlanetCommentToJson(XDUPlanetComment instance) =>
    <String, dynamic>{
      'ID': instance.ID,
      'CreatedAt': instance.CreatedAt.toIso8601String(),
      'UpdatedAt': instance.UpdatedAt.toIso8601String(),
      'article_id': instance.article_id,
      'content': instance.content,
      'user_id': instance.user_id,
      'reply_to': instance.reply_to,
    };
