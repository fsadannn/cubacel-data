import 'package:json_annotation/json_annotation.dart';
import 'internet.dart';
import 'other.dart';
import 'credit.dart';

part 'cubacel.g.dart';

@JsonSerializable(explicitToJson: true)
class Cubacel {
  @JsonKey()
  final DateTime date;
  @JsonKey()
  final Internet internet;
  @JsonKey()
  final Credit credit;
  @JsonKey()
  final Others others;

  Cubacel({required this.internet, required this.credit, required this.others, DateTime? date}) : date = date ?? DateTime.now();
  factory Cubacel.fromJson(Map<String, dynamic> json) =>
      _$CubacelFromJson(json);
  Map<String, dynamic> toJson() => _$CubacelToJson(this);

}