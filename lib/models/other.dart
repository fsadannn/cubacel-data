import 'package:json_annotation/json_annotation.dart';
part 'other.g.dart';

@JsonSerializable()
class Others {
  final String? unit = null;
  @JsonKey(defaultValue: 0)
  final num? sms;
  @JsonKey(defaultValue: 0)
  final num? sms_bonus;
  @JsonKey(defaultValue: 0)
  final num? minutes;
  @JsonKey(defaultValue: 0)
  final num? minutes_bonus;

  const Others({this.sms, this.sms_bonus, this.minutes, this.minutes_bonus});

  factory Others.fromJson(Map<String, dynamic> json) => _$OthersFromJson(json);
  Map<String, dynamic> toJson() => _$OthersToJson(this);
}
