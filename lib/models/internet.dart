import 'package:json_annotation/json_annotation.dart';
part 'internet.g.dart';

@JsonSerializable()
class Internet {
  final String unit = 'MB';
  @JsonKey(defaultValue: 0)
  final num? only_lte;
  @JsonKey(defaultValue: 0)
  final num? all_networks;
  @JsonKey( defaultValue: 0)
  final num? national_data;
  @JsonKey(defaultValue: 0)
  final num? promotional_data;

  const Internet(
      {this.only_lte,
        this.all_networks,
        this.national_data,
        this.promotional_data});

  factory Internet.fromJson(Map<String, dynamic> json) =>
      _$InternetFromJson(json);
  Map<String, dynamic> toJson() => _$InternetToJson(this);
}