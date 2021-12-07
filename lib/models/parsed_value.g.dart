// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsed_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParsedValue _$ParsedValueFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['unit', 'fieldName', 'value', 'type'],
  );
  return ParsedValue(
    unit: json['unit'] as String,
    fieldName: json['fieldName'] as String,
    value: json['value'] as num,
    type: $enumDecode(_$DataTypeEnumMap, json['type']),
  );
}

Map<String, dynamic> _$ParsedValueToJson(ParsedValue instance) =>
    <String, dynamic>{
      'unit': instance.unit,
      'fieldName': instance.fieldName,
      'value': instance.value,
      'type': _$DataTypeEnumMap[instance.type],
    };

const _$DataTypeEnumMap = {
  DataType.internet: 'internet',
  DataType.credit: 'credit',
  DataType.other: 'other',
};
