// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubacel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cubacel _$CubacelFromJson(Map<String, dynamic> json) => Cubacel(
      internet: Internet.fromJson(json['internet'] as Map<String, dynamic>),
      credit: Credit.fromJson(json['credit'] as Map<String, dynamic>),
      others: Others.fromJson(json['others'] as Map<String, dynamic>),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$CubacelToJson(Cubacel instance) => <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'internet': instance.internet.toJson(),
      'credit': instance.credit.toJson(),
      'others': instance.others.toJson(),
    };
