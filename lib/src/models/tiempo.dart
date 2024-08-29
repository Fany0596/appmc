import 'dart:convert';

import 'package:maquinados_correa/src/models/operador.dart';

Tiempo tiempoFromJson(String str) => Tiempo.fromJson(json.decode(str) ?? {});

String tiempoToJson(Tiempo data) => json.encode(data.toJson());

class Tiempo {
  String? id;
  String? proceso;
  String? estado;
  String? time;
  String? idProducto;
  String? idOperador;
  String? coment;
  Operador? operador;


  Tiempo({
    this.id,
    this.proceso,
    this.estado,
    this.time,
    this.idProducto,
    this.idOperador,
    this.coment,
    this.operador,

  });

  factory Tiempo.fromJson(Map<String, dynamic> json) => Tiempo(
    id: json["id"],
    proceso: json["proceso"],
    estado: json["estado"],
    time: json["time"],
    idProducto: json["id_producto"],
    idOperador: json["id_operador"],
    coment: json["coment"],
    operador: json['operador'] is String ? operadorFromJson(json['operador']) : json['operador'] is Operador ? json['operador'] : Operador.fromJson(json['operador'] ?? {}),


  );

  static List<Tiempo> fromJsonList(List<dynamic> jsonList) {
    List<Tiempo> toList = [];
    jsonList.forEach((item) {
      if (item != null) {
        Tiempo tiempo = Tiempo.fromJson(item as Map<String, dynamic>);
        toList.add(tiempo);
      }
    });
    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "proceso": proceso,
    "estado": estado,
    "time": time,
    "id_producto": idProducto,
    "id_operador": idOperador,
    "coment": coment,
    "operador": operador,

  };
}
