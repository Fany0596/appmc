import 'dart:convert';
import 'package:maquinados_correa/src/models/Client.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/vendedor.dart';

Cotizacion cotizacionFromJson(String str) => Cotizacion.fromJson(json.decode(str));

String cotizacionToJson(Cotizacion data) => json.encode(data.toJson());

class Cotizacion {
  String? id;
  String? number;
  String? ent;
  String? fecha;
  String? nombre;
  String? correo;
  String? req;
  String? telefono;
  String? status;
  String? condiciones;
  String? descuento;
  String? garant;
  String? banc;
  String? agreg1;
  String? agreg2;
  String? agreg3;
  String? agreg4;
  String? coment1;
  String? coment2;
  String? coment3;
  int? timestamp;
  String? idVendedores;
  String? idClientes;
  Clientes? clientes;
  Vendedores? vendedores;
  int? quantity;
  List<Producto>? producto = [];
  List<Oc>? oc = [];


  Cotizacion({
    this.id,
    this.number,
    this.ent,
    this.fecha,
    this.nombre,
    this.correo,
    this.req,
    this.telefono,
    this.status,
    this.condiciones,
    this.descuento,
    this.garant,
    this.banc,
    this.agreg1,
    this.agreg2,
    this.agreg3,
    this.agreg4,
    this.coment1,
    this.coment2,
    this.coment3,
    this.producto,
    this.oc,
    this.timestamp,
    this.idVendedores,
    this.idClientes,
    this.clientes,
    this.vendedores,
    this.quantity,
  });

  factory Cotizacion.fromJson(Map<String, dynamic> json) => Cotizacion(
    id: json["id"],
    number: json["number"],
    ent: json["ent"],
    fecha: json["fecha"],
    nombre: json["nombre"],
    correo: json["correo"],
    req: json["req"],
    telefono: json["telefono"],
    status: json["status"],
    condiciones: json["condiciones"],
    descuento: json["descuento"],
    garant: json["garant"],
    banc: json["banc"],
    agreg1: json["agreg1"],
    agreg2: json["agreg2"],
    agreg3: json["agreg3"],
    agreg4: json["agreg4"],
    coment1: json["coment1"],
    coment2: json["coment2"],
    coment3: json["coment3"],
    producto: json["producto"] != null ? List<Producto>.from(json["producto"].map((model) => model is Producto ? model : Producto.fromJson(model))) : [],
    oc: json["oc"] != null ? List<Oc>.from(json["oc"].map((model) => model is Oc ? model : Oc.fromJson(model))) : [],
    timestamp: json["timestamp"],
    idVendedores: json["id_vendedores"],
    idClientes: json["id_clientes"],
    clientes: json['clientes'] is String ? clientesFromJson(json['clientes']) : json['clientes'] is Clientes ? json['clientes'] : Clientes.fromJson(json['clientes'] ?? {}),
    vendedores: json['vendedores'] is String ? vendedoresFromJson(json['vendedores']) : json['vendedores'] is Vendedores ? json['vendedores'] : Vendedores.fromJson(json['vendedores'] ?? {}),
    quantity: json["quantity"],
  );

  static List<Cotizacion> fromJsonList(List<dynamic> jsonList) {
    List<Cotizacion> toList = [];
    jsonList.forEach((item) {
      Cotizacion cotizacion = Cotizacion.fromJson(item);
      toList.add(cotizacion);
    });
    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "number": number,
    "ent": ent,
    "fecha": fecha,
    "nombre": nombre,
    "correo": correo,
    "req": req,
    "telefono": telefono,
    "status": status,
    "condiciones": condiciones,
    "descuento": descuento,
    "garant": garant,
    "banc": banc,
    "agreg1": agreg1,
    "agreg2": agreg2,
    "agreg3": agreg3,
    "agreg4": agreg4,
    "coment1": coment1,
    "coment2": coment2,
    "coment3": coment3,
    "producto": producto,
    "oc": oc,
    "timestamp": timestamp,
    "id_vendedores": idVendedores,
    "id_clientes": idClientes,
    "clientes" : clientes,
    "vendedores" : vendedores,
    "quantity": quantity,
  };
}