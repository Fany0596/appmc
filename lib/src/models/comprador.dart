import 'dart:convert';

Vendedores vendedoresFromJson(String str) => Vendedores.fromJson(json.decode(str));

String vendedoresToJson(Vendedores data) => json.encode(data.toJson());

class Vendedores {
  String? id;
  String? name;
  String? number;
  String? email;

  Vendedores({
    this.id,
    this.name,
    this.number,
    this.email,
  });

  factory Vendedores.fromJson(Map<String, dynamic> json) =>
      Vendedores(
        id: json["id"],
        name: json["name"],
        number: json["number"],
        email: json["email"],
      );



  static List<Vendedores> fromJsonList(List<dynamic> jsonList) {
    List<Vendedores> toList = [];
    jsonList.forEach((item) {
      Vendedores vendedores = Vendedores.fromJson(item);
      toList.add(vendedores);
    });
    return toList;
  }
  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "name": name,
        "number": number,
        "email": email,
      };
}
