import 'package:json_annotation/json_annotation.dart';
part 'credit.g.dart';

@JsonSerializable()
class Credit {
  final String unit = 'CUC';
  @JsonKey(defaultValue: 0)
  final num? credit_normal;
  @JsonKey(defaultValue: 0)
  final num? credit_bonus;

  const Credit({this.credit_normal, this.credit_bonus});

  factory Credit.fromJson(Map<String, dynamic> json) =>
      _$CreditFromJson(json);
  Map<String, dynamic> toJson() => _$CreditToJson(this);
}
