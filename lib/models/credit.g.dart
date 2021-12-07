// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Credit _$CreditFromJson(Map<String, dynamic> json) => Credit(
      credit_normal: json['credit_normal'] as num? ?? 0,
      credit_bonus: json['credit_bonus'] as num? ?? 0,
    );

Map<String, dynamic> _$CreditToJson(Credit instance) => <String, dynamic>{
      'credit_normal': instance.credit_normal,
      'credit_bonus': instance.credit_bonus,
    };
