/// Nested data model for example 5; used with @DataPath to parse from data.result.
class NestedModel {
  NestedModel({this.value});

  factory NestedModel.fromJson(Map<String, dynamic> json) {
    return NestedModel(value: json['value'] as String?);
  }

  final String? value;
}
