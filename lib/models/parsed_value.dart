import 'data_type.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'parsed_value.g.dart';


@JsonSerializable()
class ParsedValue {
  @JsonKey(required: true)
  final String unit;
  @JsonKey(required: true)
  final String fieldName;
  @JsonKey(required: true)
  final num value;
  @JsonKey(required: true)
  final DataType type;

  const ParsedValue(
      {required this.unit,
        required this.fieldName,
        required this.value,
        required this.type});

  factory ParsedValue.fromJson(Map<String, dynamic> json) =>
      _$ParsedValueFromJson(json);
  Map<String, dynamic> toJson() => _$ParsedValueToJson(this);
}
