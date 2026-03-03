/// 案例5 用：嵌套数据结构，配合 @DataPath 从 data.result 解析。
class NestedModel {
  NestedModel({this.value});

  factory NestedModel.fromJson(Map<String, dynamic> json) {
    return NestedModel(value: json['value'] as String?);
  }

  final String? value;
}
