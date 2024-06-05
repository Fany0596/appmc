import 'dart:convert';

Materiales materialesFromJson(String str) => Materiales.fromJson(json.decode(str));

String materialesToJson(Materiales data) => json.encode(data.toJson());

class Materiales {
  String? id;
  String? name;

  Materiales({
    this.id,
    this.name,

  });

  factory Materiales.fromJson(Map<String, dynamic> json) => Materiales(
    id: json["id"],
    name: json["name"],

  );

  static List<Materiales> fromJsonList(List<dynamic> jsonList) {
    List<Materiales> toList = [];
    jsonList.forEach((item) {
      Materiales materiales = Materiales.fromJson(item);
      toList.add(materiales);
    });
    return toList;
  }


  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,

  };
}
