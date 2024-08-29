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

class PriceProductoPageController extends GetxController {
  Producto? producto;

  @override
  void onInit() {
    super.onInit();
    print('Argumentos recibidos: ${Get.arguments}');
    producto = Producto.fromJson(Get.arguments['producto']);
    print('Producto recibido: ${producto?.descr}');
  }

  TextEditingController pmaterialController = TextEditingController();

  CotizacionProvider cotizacionProvider = CotizacionProvider();

  MaterialesProvider materialesProvider = MaterialesProvider();

  var idCotizaciones = ''.obs;
  List<Cotizacion> cotizacion = <Cotizacion>[].obs;
  var idMateriales = ''.obs;
  List<Materiales> materiales = <Materiales>[].obs;
  ProductoProvider productoProvider = ProductoProvider();


  PriceProductoPageController() {
    Producto producto = Producto.fromJson(Get.arguments['producto']);
    print('Producto recibido: $producto');
    getCotizacion();
    getMateriales();
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

    String pmaterial = pmaterialController.text;
    String productoId = producto?.id ?? '';
    print('ID del producto a actualizar: $productoId');


    if (pmaterial.isEmpty ) {
      Get.snackbar('Formulario no valido', 'Ingresa el precio');
      return;
    }

    print('PRECIO DEL MATERIAL: ${pmaterial}');
    print('ID MATERIAL: ${idMateriales}');
    ProgressDialog progressDialog = ProgressDialog(context: context);



    if (isValidForm(pmaterial)){ //valida que no esten vacios los campos
      Producto myproducto = Producto(
          id: productoId,
          pmaterial: pmaterial,
        idMateriales: idMateriales.value
      );
      progressDialog.show(max: 100, msg:'Espere un momento...');


       List<File> images =[];
      // images.add(planopdf!);
      //images.add(imageFile2!);
      //images.add(imageFile3!);

      ResponseApi responseApi = await productoProvider.mat(myproducto);
      progressDialog.close();
      Get.snackbar('Proceso terminado', responseApi.message ?? '', backgroundColor: Colors.green, colorText: Colors.white);

      if (responseApi.success == true) {
        Get.snackbar('Éxito', responseApi.message ?? 'Producto eliminado correctamente', backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        Get.snackbar('Error', responseApi.message ?? 'Error al eliminar el producto', backgroundColor: Colors.red,
          colorText: Colors.white,);
      }
    }
  }
  bool isValidForm(String pmaterial) {
    if (pmaterial.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa precio del material',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (idMateriales == null) {
      Get.snackbar('Formulario no valido', 'Selecciona un material',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }

    return true;
  }

     void clearForm() {
       pmaterialController.text = '';
       idMateriales.value = '';
       update();
     }

}
