// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Menu _$MenuFromJson(Map<String, dynamic> json) {
  return Menu(
    title: json['title'] as String,
    icon: json['icon'] as String,
    path: json['path'] as String,
    sort: int.parse(json['sort']),
  );
}

Map<String, dynamic> _$MenuToJson(Menu instance) => <String, dynamic>{
      'title': instance.title,
      'path': instance.path,
      'icon': instance.icon,
      'sort': instance.sort,
    };
