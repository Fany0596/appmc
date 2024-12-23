import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/material_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ProductoPageController extends GetxController {
  List<Producto> productosPendientes = [];

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

  void clearForm() {
    articuloController.text = '';
    descrController.text = '';
    precioController.text = '';
    cantidadController.text = '';
    totalController.text = '';
    idMateriales.value = '';
    update();
  }

  void clearForm2() {
    articuloController.text = '';
    descrController.text = '';
    precioController.text = '';
    cantidadController.text = '';
    totalController.text = '';
    idMateriales.value = '';
    idCotizaciones.value = '';
    update();
  }

  void reloadPage() {
    getCotizacion(); // Recargar cotizaciones
    getMateriales(); // Recargar materiales
    update(); // Actualizar el controlador
  }

  void agregarProducto(BuildContext context) {
    String articulo = articuloController.text;
    String descr = descrController.text;
    String precio = precioController.text;
    String cantidad = cantidadController.text;

    // Calcula el total multiplicando precio y cantidad
    double total = double.parse(precio) * double.parse(cantidad);

    if (isValidForm(articulo, precio, total.toString(), cantidad, descr)) {
      double total = double.parse(precio) * double.parse(cantidad);

      Producto producto = Producto(
          articulo: articulo,
          descr: descr,
          precio: double.parse(precio),
          total: total,
          cantidad: double.parse(cantidad),
          idCotizaciones: idCotizaciones.value,
          idMateriales: idMateriales.value);

      productosPendientes.add(producto);
      clearForm();
      update();
      Get.snackbar('Producto agregado', 'El producto se ha agregado a la lista',
          backgroundColor: Colors.green, colorText: Colors.white);
    }
  }

  void guardarTodosLosProductos(BuildContext context) async {
    if (productosPendientes.isEmpty) {
      Get.snackbar('Error', 'No hay productos para guardar',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    ProgressDialog progressDialog = ProgressDialog(context: context);
    progressDialog.show(max: 100, msg: 'Guardando productos...');

    for (var producto in productosPendientes) {
      List<File> images = [];
      Stream stream = await productoProvider.create(producto, images);
      await for (var res in stream) {
        ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
        if (responseApi.success != true) {
          progressDialog.close();
          Get.snackbar(
              'Error', 'No se pudo guardar el producto: ${producto.articulo}',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      }
    }

    progressDialog.close();
    Get.snackbar('Éxito', 'Todos los productos han sido guardados',
        backgroundColor: Colors.green, colorText: Colors.white);
    productosPendientes.clear();
    clearForm2();
  }
  bool isValidForm(String articulo, String precio, String total,
      String cantidad, String descr) {
    if (articulo.isEmpty) {
      Get.snackbar(
        'Formulario no valido',
        'Ingresa número de cotización',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (precio.isEmpty) {
      Get.snackbar(
        'Formulario no valido',
        'Ingresa precio',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (cantidad.isEmpty) {
      Get.snackbar(
        'Formulario no valido',
        'Ingresa cantidad',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (descr.isEmpty) {
      Get.snackbar(
        'Formulario no valido',
        'Ingresa la descripción',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (idCotizaciones == null) {
      Get.snackbar(
        'Formulario no valido',
        'Selecciona un vendedor',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (idMateriales == null) {
      Get.snackbar(
        'Formulario no valido',
        'Selecciona un cliente',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  void removeProducto(int index) {
    productosPendientes.removeAt(index);
    update(); // Esto actualizará la UI
  }
}
