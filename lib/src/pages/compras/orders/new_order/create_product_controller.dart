import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/models/product.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/material_provider.dart';
import 'package:maquinados_correa/src/providers/oc_provider.dart';
import 'package:maquinados_correa/src/providers/product_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ProductPageController extends GetxController {

  TextEditingController descrController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController cantidadController = TextEditingController();
  TextEditingController unidController = TextEditingController();
  Rx<String> selectedUnid = Rx<String>('');

  OcProvider ocProvider = OcProvider();

  MaterialesProvider materialesProvider = MaterialesProvider();

  var idOc = ''.obs;
  List<Oc> oc = <Oc>[].obs;
  var idMateriales = ''.obs;
  List<Materiales> materiales = <Materiales>[].obs;
  ProductProvider productProvider = ProductProvider();


  ProductPageController() {
    precioController.addListener(updateTotal);
    cantidadController.addListener(updateTotal);
    getOc();
    getMateriales();
  }

  void updateTotal() {
    double precio = double.tryParse(precioController.text) ?? 0;
    double cantidad = double.tryParse(cantidadController.text) ?? 0;
    double total = precio * cantidad;

    // Actualiza el valor del controlador de "Total"
    totalController.text = total.toStringAsFixed(2);
  }
  void getOc() async {
    var result = await ocProvider.getAll();
    oc.clear();
    oc.addAll(result);
  }
  void getMateriales() async {
    var result = await materialesProvider.getAll();
    materiales.clear();
    materiales.addAll(result);
  }

  void createProduct(BuildContext context) async {

    String descr = descrController.text;
    String precio = precioController.text;
    String unid = unidController.text;
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

    print('ARTICULO: ${descr}');
    print('PRECIO: ${precio}');
    print('TOTAL: ${total}');
    print('CANTIDAD: ${cantidad}');
    print('ID OC: ${idOc}');
    print('ID MATERIAL: ${idMateriales}');
    ProgressDialog progressDialog = ProgressDialog(context: context);



    if (isValidForm(descr, precio, total.toString(), cantidad)){ //valida que no esten vacios los campos
      Product product = Product(
        descr: descr,
        precio: double.parse(precio),
        total: total,
        unid: unid,
        cantidad: double.parse(cantidad),
        idOc: idOc.value,
        idMateriales: idMateriales.value
      );
      progressDialog.show(max: 100, msg:'Espere un momento...');


       List<File> images =[];

       Stream stream = await productProvider.create(product, images);
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
  bool isValidForm( String precio, String total, String cantidad, String descr) {
    if (descr.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa la descripción', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (idOc == null) {
      Get.snackbar('Formulario no valido', 'Selecciona una oc', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (idMateriales == null) {
      Get.snackbar('Formulario no valido', 'Selecciona un cliente', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }

    return true;
  }

     void clearForm() {
       descrController.text = '';
       precioController.text = '';
       cantidadController.text = '';
       totalController.text = '';
       idOc.value = '';
       idMateriales.value = '';
       update();
     }

}
