// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsed_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParsedValue _$ParsedValueFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['unit', 'fieldName', 'value', 'type']);
  return ParsedValue(
    unit: json['unit'] as String,
    fieldName: json['fieldName'] as String,
    value: json['value'] as num,
    type: _$enumDecode(_$DataTypeEnumMap, json['type']),
  );
}

Map<String, dynamic> _$ParsedValueToJson(ParsedValue instance) =>
    <String, dynamic>{
      'unit': instance.unit,
      'fieldName': instance.fieldName,
      'value': instance.value,
      'type': _$DataTypeEnumMap[instance.type],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$DataTypeEnumMap = {
  DataType.internet: 'internet',
  DataType.credit: 'credit',
  DataType.other: 'other',
};
