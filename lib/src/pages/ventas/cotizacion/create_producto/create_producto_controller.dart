import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/material_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ProductoPageController extends GetxController {


  TextEditingController articuloController = TextEditingController();
  TextEditingController descrController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController cantidadController = TextEditingController();

  CotizacionProvider cotizacionProvider = CotizacionProvider();

  MaterialesProvider materialesProvider = MaterialesProvider();

  var idCotizaciones = ''.obs;
  List<Cotizacion> cotizacion = <Cotizacion>[].obs;
  var idMateriales = ''.obs;
  List<Materiales> materiales = <Materiales>[].obs;
  ProductoProvider productoProvider = ProductoProvider();


  ProductoPageController() {
    precioController.addListener(updateTotal);
    cantidadController.addListener(updateTotal);
    getCotizacion();
    getMateriales();
  }

  void updateTotal() {
    double precio = double.tryParse(precioController.text) ?? 0;
    double cantidad = double.tryParse(cantidadController.text) ?? 0;
    double total = precio * cantidad;

    // Actualiza el valor del controlador de "Total"
    totalController.text = total.toStringAsFixed(2);
  }
  void getCotizacion() async {
    var result = await cotizacionProvider.getAll();
    cotizacion.clear();
    cotizacion.addAll(result);
  }
  void getMateriales() async {
    var result = await materialesProvider.getAll();
    materiales.clear();
    materiales.addAll(result);
  }

  void createProducto(BuildContext context) async {

    String articulo = articuloController.text;
    String descr = descrController.text;
    String precio = precioController.text;
    String cantidad = cantidadController.text;

    if (precio.isEmpty || cantidad.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa el precio y la cantidad');
      return;
    }
    if (descr.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa la descripción');
      return;
    }

    // Calcula el total multiplicando precio y cantidad
    double total = double.parse(precio) * double.parse(cantidad);

    print('ARTICULO: ${articulo}');
    print('PRECIO: ${precio}');
    print('TOTAL: ${total}');
    print('CANTIDAD: ${cantidad}');
    print('ID COTIZACION: ${idCotizaciones}');
    print('ID MATERIAL: ${idMateriales}');
    ProgressDialog progressDialog = ProgressDialog(context: context);



    if (isValidForm(articulo, precio, total.toString(), cantidad, descr)){ //valida que no esten vacios los campos
      Producto producto = Producto(
        articulo: articulo,
        descr: descr,
        precio: double.parse(precio),
        total: total,
        cantidad: double.parse(cantidad),
        idCotizaciones: idCotizaciones.value,
        idMateriales: idMateriales.value
      );
      progressDialog.show(max: 100, msg:'Espere un momento...');


       List<File> images =[];
      // images.add(planopdf!);
      //images.add(imageFile2!);
      //images.add(imageFile3!);

       Stream stream = await productoProvider.create(producto, images);
       stream.listen((res) {

         ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
        progressDialog.close();
       Get.snackbar('Proceso terminado', responseApi.message ?? '',backgroundColor: Colors.green,
         colorText: Colors.white,);
       if (responseApi.success == true) {
         clearForm();
       }
       });
    }
  }
  bool isValidForm(String articulo, String precio, String total, String cantidad, String descr) {
    if (articulo.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa número de cotización',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (precio.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa precio',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (cantidad.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa cantidad',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (descr.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa la descripción',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (idCotizaciones == null) {
      Get.snackbar('Formulario no valido', 'Selecciona un vendedor',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (idMateriales == null) {
      Get.snackbar('Formulario no valido', 'Selecciona un cliente',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }

    return true;
  }

     void clearForm() {
       articuloController.text = '';
       descrController.text = '';
       precioController.text = '';
       cantidadController.text = '';
       totalController.text = '';
       idCotizaciones.value = '';
       idMateriales.value = '';
       update();
     }

}
