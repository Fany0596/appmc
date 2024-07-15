import 'dart:convert';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {
  String? id;
  String? articulo;
  String? descr;
  String? unid;
  double? precio;
  double? total;
  double? cantidad;
  String? idCotizaciones;
  String? idOc;
  String? idMateriales;
  String? estatus;
  String? pedido;
  String? fecha;
  String? ot;
  String? parte;
  String? name;
  String? number;
  int? quantity;


  Product({
    this.id,
    this.articulo,
    this.descr,
    this.unid,
    this.precio,
    this.total,
    this.cantidad,
    this.idCotizaciones,
    this.idOc,
    this.idMateriales,
    this.estatus,
    this.pedido,
    this.fecha,
    this.ot,
    this.parte,
    this.name,
    this.number,
    this.quantity,

  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    articulo: json["articulo"],
    descr: json["descr"],
    unid: json["unid"],
    precio: json["precio"].toDouble(),
    total: json["total"].toDouble(),
    cantidad: json["cantidad"].toDouble(),
    idCotizaciones: json["id_cotizaciones"],
    idOc: json["id_oc"],
    idMateriales: json["id_materiales"],
    estatus: json["estatus"],
    pedido: json["pedido"],
    fecha: json["fecha"],
    ot: json["ot"],
    parte: json["parte"],
    name: json["name"],
    number: json["number"],
    quantity: json["quantity"],

  );
  static List<Product> fromJsonList(List<dynamic> jsonList) {
    List<Product> toList = [];
    jsonList.forEach((item) {
      Product product = Product.fromJson(item);
      toList.add(product);
    });
    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "articulo": articulo,
    "descr": descr,
    "unid": unid,
    "precio": precio,
    "total": total,
    "cantidad": cantidad,
    "id_cotizaciones": idCotizaciones,
    "id_oc": idOc,
    "id_materiales": idMateriales,
    "estatus": estatus,
    "pedido": pedido,
    "fecha": fecha,
    "ot": ot,
    "parte": parte,
    "name": name,
    "number": number,
    "quantity": quantity,

  };
}