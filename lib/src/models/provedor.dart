import 'dart:convert';

Clientes clientesFromJson(String str) => Clientes.fromJson(json.decode(str));

String clientesToJson(Clientes data) => json.encode(data.toJson());

class Clientes {
  String? id;
  String? name;

  Clientes({
    this.id,
    this.name,

  });

  factory Clientes.fromJson(Map<String, dynamic> json) => Clientes(
    id: json["id"],
    name: json["name"],

  );

  static List<Clientes> fromJsonList(List<dynamic> jsonList) {
    List<Clientes> toList = [];
    jsonList.forEach((item) {
      Clientes clientes = Clientes.fromJson(item);
      toList.add(clientes);
    });
    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,

  };
}
