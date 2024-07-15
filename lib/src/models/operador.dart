import 'dart:convert';

Operador operadorFromJson(String str) => Operador.fromJson(json.decode(str));

String operadorToJson(Operador data) => json.encode(data.toJson());

class Operador {
  String? id;
  String? name;

  Operador({
    this.id,
    this.name,
  });

  factory Operador.fromJson(Map<String, dynamic> json) =>
      Operador(
        id: json["id"],
        name: json["name"],
      );



  static List<Operador> fromJsonList(List<dynamic> jsonList) {
    List<Operador> toList = [];
    jsonList.forEach((item) {
      Operador operador = Operador.fromJson(item);
      toList.add(operador);
    });
    return toList;
  }
  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "name": name,
      };
}
