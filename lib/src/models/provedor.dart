import 'dart:convert';

Provedor provedorFromJson(String str) => Provedor.fromJson(json.decode(str));

String provedorToJson(Provedor data) => json.encode(data.toJson());

class Provedor {
  String? id;
  String? name;
  String? nombre;
  String? correo;
  String? telefono;
  String? direc;

  Provedor({
    this.id,
    this.name,
    this.nombre,
    this.correo,
    this.telefono,
    this.direc,

  });

  factory Provedor.fromJson(Map<String, dynamic> json) => Provedor(
    id: json["id"],
    name: json["name"],
    nombre: json["nombre"],
    correo: json["correo"],
    telefono: json["telefono"],
    direc: json["direc"],

  );

  static List<Provedor> fromJsonList(List<dynamic> jsonList) {
    List<Provedor> toList = [];
    jsonList.forEach((item) {
      Provedor provedor = Provedor.fromJson(item);
      toList.add(provedor);
    });
    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "nombre": nombre,
    "correo": correo,
    "telefono": telefono,
    "direc": direc,

  };
}
