import 'dart:convert';

import 'package:maquinados_correa/src/models/proceso.dart';

Producto productoFromJson(String str) => Producto.fromJson(json.decode(str));

String productoToJson(Producto data) => json.encode(data.toJson());

class Producto {
  String? id;
  String? articulo;
  String? descr;
  double? precio;
  double? total;
  double? cantidad;
  String? idCotizaciones;
  String? idMateriales;
  String? estatus;
  String? pedido;
  String? operador;
  String? operacion;
  String? fecha;
  String? desc;
  String? ot;
  String? parte;
  String? name;
  String? number;
  String? pdfFile;
  String? pmaterial;
  int? quantity;
  List<Proceso>? procesos; // Lista de procesos de producción


  Producto({
    this.id,
    this.articulo,
    this.descr,
    this.precio,
    this.total,
    this.cantidad,
    this.idCotizaciones,
    this.idMateriales,
    this.estatus,
    this.pedido,
    this.operador,
    this.operacion,
    this.fecha,
    this.desc,
    this.ot,
    this.parte,
    this.name,
    this.number,
    this.quantity,
    this.pdfFile,
    this.pmaterial,
    this.procesos,

  });

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
    id: json["id"],
    articulo: json["articulo"],
    descr: json["descr"],
    precio: json["precio"].toDouble(),
    total: json["total"].toDouble(),
    cantidad: json["cantidad"].toDouble(),
    idCotizaciones: json["id_cotizaciones"],
    idMateriales: json["id_materiales"],
    estatus: json["estatus"],
    pedido: json["pedido"],
    operador: json["operador"],
    operacion: json["operacion"],
    fecha: json["fecha"],
    desc: json["desc"],
    ot: json["ot"],
    parte: json["parte"],
    name: json["name"],
    number: json["number"],
    quantity: json["quantity"],
    pdfFile: json["pdfFile"],
    pmaterial: json["pmaterial"],
    procesos: json["procesos"] != null ? List<Proceso>.from(json["procesos"].map((x) => Proceso.fromJson(x))) : null,

  );
  static List<Producto> fromJsonList(List<dynamic> jsonList) {
    List<Producto> toList = [];
    jsonList.forEach((item) {
      Producto producto = Producto.fromJson(item);
      toList.add(producto);
    });
    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "articulo": articulo,
    "descr": descr,
    "precio": precio,
    "total": total,
    "cantidad": cantidad,
    "id_cotizaciones": idCotizaciones,
    "id_materiales": idMateriales,
    "estatus": estatus,
    "pedido": pedido,
    "operador": operador,
    "operacion": operacion,
    "fecha": fecha,
    "desc": desc,
    "ot": ot,
    "parte": parte,
    "name": name,
    "number": number,
    "quantity": quantity,
    "pdfFile": pdfFile,
    "pmaterial": pmaterial,
    "procesos": procesos != null ? List<dynamic>.from(procesos!.map((x) => x.toJson())) : null,

  };
}