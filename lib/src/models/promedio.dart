import 'dart:convert';

Promedio promedioFromJson(String str) => Promedio.fromJson(json.decode(str) ?? {});

String promedioToJson(Promedio data) => json.encode(data.toJson());

class Promedio {
  String? id;
  String? producto;
  String? proceso;
  String? parte;
  String? tiempo;


  Promedio({
    this.id,
    this.producto,
    this.proceso,
    this.parte,
    this.tiempo,
     });

  factory Promedio.fromJson(Map<String, dynamic> json) => Promedio(
    id: json["id"],
    producto: json["producto"],
    proceso: json["proceso"],
    parte: json["parte"],
    tiempo: json["tiempo"],
      );

  static List<Promedio> fromJsonList(List<dynamic> jsonList) {
    List<Promedio> toList = [];
    jsonList.forEach((item) {
      if (item != null) {
        Promedio promedio = Promedio.fromJson(item as Map<String, dynamic>);
        toList.add(promedio);
      }
    });
    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "producto": producto,
    "proceso": proceso,
    "parte": parte,
    "tiempo": tiempo,
      };
}
