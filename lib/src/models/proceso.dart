import 'dart:convert';

Proceso procesorFromJson(String str) => Proceso.fromJson(json.decode(str));
Suspension suspensionFromJson(String str) => Suspension.fromJson(json.decode(str));

String procesoToJson(Proceso data) => json.encode(data.toJson());
String suspensionToJson(Proceso data) => json.encode(data.toJson());

class Proceso {
  String? id;
  String? nombre;
  DateTime? inicio;
  DateTime? fin;
  List<Suspension>? suspensiones;
  String? idOperador;
  String? comentario; // Comentarios adicionales

  Proceso({
    this.id,
    this.nombre,
    this.inicio,
    this.fin,
    this.suspensiones,
    this.idOperador,
    this.comentario,
  });

  factory Proceso.fromJson(Map<String, dynamic> json) => Proceso(
    id: json["id"],
    nombre: json["nombre"],
    inicio: DateTime.parse(json["inicio"]),
    fin: DateTime.parse(json["fin"]),
    idOperador: json["id_operador"],
    suspensiones: json["suspensiones"] != null ? List<Suspension>.from(json["suspensiones"].map((x) => Suspension.fromJson(x))) : null,
    comentario: json["comentario"],
  );
  static List<Proceso> fromJsonList(List<dynamic> jsonList) {
    List<Proceso> toList = [];
    jsonList.forEach((item) {
      Proceso proceso = Proceso.fromJson(item);
      toList.add(proceso);
    });
    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "inicio": inicio?.toIso8601String(),
    "fin": fin?.toIso8601String(),
    "id_operador": idOperador,
    "suspensiones": suspensiones != null ? List<dynamic>.from(suspensiones!.map((x) => x.toJson())) : null,
    "comentario": comentario,
  };
  Duration get duracionTotal {
    Duration duracion = fin != null ? fin!.difference(inicio!) : Duration.zero;
    suspensiones?.forEach((suspension) {
      duracion -= suspension.duracion;
    });
    return duracion;
  }
}

class Suspension {
  DateTime? inicio;
  DateTime? fin;

  Suspension({
    this.inicio,
    this.fin
  });
  factory Suspension.fromJson(Map<String, dynamic> json) => Suspension(
    inicio: DateTime.parse(json["inicio"]),
    fin: DateTime.parse(json["fin"]),
  );
  Map<String, dynamic> toJson() => {
    "inicio": inicio?.toIso8601String(),
    "fin": fin?.toIso8601String(),
  };
  static List<Suspension> fromJsonList(List<dynamic> jsonList) {
    List<Suspension> toList = [];
    jsonList.forEach((item) {
      Suspension suspension = Suspension.fromJson(item);
      toList.add(suspension);
    });
    return toList;
  }

  Duration get duracion => fin != null ? fin!.difference(inicio!) : Duration.zero;
}
