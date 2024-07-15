import 'dart:convert';

Comprador compradorFromJson(String str) => Comprador.fromJson(json.decode(str));

String compradorToJson(Comprador data) => json.encode(data.toJson());

class Comprador {
  String? id;
  String? name;
  String? number;
  String? email;

  Comprador({
    this.id,
    this.name,
    this.number,
    this.email,
  });

  factory Comprador.fromJson(Map<String, dynamic> json) =>
      Comprador(
        id: json["id"],
        name: json["name"],
        number: json["number"],
        email: json["email"],
      );



  static List<Comprador> fromJsonList(List<dynamic> jsonList) {
    List<Comprador> toList = [];
    jsonList.forEach((item) {
      Comprador comprador = Comprador.fromJson(item);
      toList.add(comprador);
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
