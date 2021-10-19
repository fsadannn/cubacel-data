// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Others _$OthersFromJson(Map<String, dynamic> json) {
  return Others(
    sms: json['sms'] as num? ?? 0,
    minutes: json['minutes'] as num? ?? 0,
    minutes_bonus: json['minutes_bonus'] as num? ?? 0,
  );
}

Map<String, dynamic> _$OthersToJson(Others instance) => <String, dynamic>{
      'sms': instance.sms,
      'minutes': instance.minutes,
      'minutes_bonus': instance.minutes_bonus,
    };
