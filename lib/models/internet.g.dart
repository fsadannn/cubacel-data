// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'internet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Internet _$InternetFromJson(Map<String, dynamic> json) {
  return Internet(
    only_lte: json['only_lte'] as num? ?? 0,
    all_networks: json['all_networks'] as num? ?? 0,
    national_data: json['national_data'] as num? ?? 0,
    promotional_data: json['promotional_data'] as num? ?? 0,
  );
}

Map<String, dynamic> _$InternetToJson(Internet instance) => <String, dynamic>{
      'only_lte': instance.only_lte,
      'all_networks': instance.all_networks,
      'national_data': instance.national_data,
      'promotional_data': instance.promotional_data,
    };
