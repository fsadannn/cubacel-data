import 'package:json_annotation/json_annotation.dart';
part 'field.g.dart';

@JsonSerializable()
class Field {
  @JsonKey(defaultValue: null)
  final DateTime? due_date;
  @JsonKey(defaultValue: 0)
  final num? value;

  const Field({this.due_date, this.value});

  factory Field.fromJson(Map<String, dynamic> json) =>
      _$FieldFromJson(json);
  Map<String, dynamic> toJson() => _$FieldToJson(this);
}
