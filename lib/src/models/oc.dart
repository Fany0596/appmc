import 'dart:convert';
import 'package:maquinados_correa/src/models/Client.dart';
import 'package:maquinados_correa/src/models/comprador.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/product.dart';
import 'package:maquinados_correa/src/models/provedor.dart';

Oc ocFromJson(String str) => Oc.fromJson(json.decode(str));

String ocToJson(Oc data) => json.encode(data.toJson());

class Oc {
  String? id;
  String? number;
  String? ent;
  String? soli;
  String? status;
  String? condiciones;
  String? tipo;
  String? moneda;
  String? envio;
  String? coment;
  int? timestamp;
  String? idComprador;
  String? idProvedor;
  String? idCotizaciones;
  Comprador? comprador;
  Provedor? provedor;
  Cotizacion? cotizacion;
  int? quantity;
  List<Product>? product = [];


  Oc({
    this.id,
    this.number,
    this.ent,
    this.soli,
    this.status,
    this.condiciones,
    this.tipo,
    this.moneda,
    this.envio,
    this.coment,
    this.product,
    this.timestamp,
    this.idComprador,
    this.idProvedor,
    this.idCotizaciones,
    this.comprador,
    this.provedor,
    this.cotizacion,
    this.quantity,
  });

  factory Oc.fromJson(Map<String, dynamic> json) => Oc(
    id: json["id"],
    number: json["number"],
    ent: json["ent"],
    soli: json["soli"],
    status: json["status"],
    condiciones: json["condiciones"],
    tipo: json["tipo"],
    moneda: json["moneda"],
    envio: json["envio"],
    coment: json["coment"],
    product: json["product"] != null ? List<Product>.from(json["product"].map((model) => model is Product ? model : Product.fromJson(model))) : [],
    timestamp: json["timestamp"],
    idComprador: json["id_comprador"],
    idProvedor: json["id_provedor"],
    idCotizaciones: json["id_cotizaciones"],
    comprador: json['comprador'] is String ? compradorFromJson(json['comprador']) : json['comprador'] is Comprador ? json['comprador'] : Comprador.fromJson(json['comprador'] ?? {}),
    provedor: json['provedor'] is String ? provedorFromJson(json['provedor']) : json['provedor'] is Provedor ? json['provedor'] : Provedor.fromJson(json['provedor'] ?? {}),
    cotizacion: json['cotizaciones'] is String ? cotizacionFromJson(json['cotizaciones']) : json['cotizaciones'] is Cotizacion ? json['cotizaciones'] : Cotizacion.fromJson(json['cotizaciones'] ?? {}),
    quantity: json["quantity"],
  );

  static List<Oc> fromJsonList(List<dynamic> jsonList) {
    List<Oc> toList = [];
    jsonList.forEach((item) {
      Oc oc = Oc.fromJson(item);
      toList.add(oc);
    });
    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "number": number,
    "ent": ent,
    "soli": soli,
    "status": status,
    "condiciones": condiciones,
    "tipo": tipo,
    "moneda": moneda,
    "envio": envio,
    "coment": coment,
    "product": product,
    "timestamp": timestamp,
    "id_comprador": idComprador,
    "id_provedor": idProvedor,
    "id_cotizaciones": idCotizaciones,
    "comprador" : comprador,
    "provedor" : provedor,
    "cotizacion" : cotizacion,
    "quantity": quantity,
  };
}