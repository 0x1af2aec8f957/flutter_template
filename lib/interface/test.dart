/// 协助生成: https://app.quicktype.io
import 'dart:convert';

class Test {
    final String id; // id
    final DateTime createdTime; // 创建时间	
    final DateTime updatedTime; // 更新时间

    const Test({
      required this.id,
      required this.createdTime,
      required this.updatedTime,
    });

    Test copyWith({
      String? id,
      DateTime? createdTime,
      DateTime? updatedTime,
    }) =>  Test(
      id: id ?? this.id,
      createdTime: createdTime ?? this.createdTime,
      updatedTime: updatedTime ?? this.updatedTime,
    );

    factory Test.fromRawJson(String str) => Test.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Test.fromJson(Map<String, dynamic> json) => Test(
      id: json["id"],
      createdTime: DateTime.parse(json["createdTime"]),
      updatedTime: DateTime.parse(json["updatedTime"]),
    );

    Map<String, dynamic> toJson() => {
      "id": id,
      "createdTime": createdTime.toIso8601String(),
      "updatedTime": updatedTime.toIso8601String(),
    };
}
