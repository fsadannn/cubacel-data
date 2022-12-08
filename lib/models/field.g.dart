// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Field _$FieldFromJson(Map<String, dynamic> json) => Field(
      due_date: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      value: json['value'] as num? ?? 0,
    );

Map<String, dynamic> _$FieldToJson(Field instance) => <String, dynamic>{
      'due_date': instance.due_date?.toIso8601String(),
      'value': instance.value,
    };
