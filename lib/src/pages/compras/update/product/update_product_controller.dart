import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/product.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/material_provider.dart';
import 'package:maquinados_correa/src/providers/oc_provider.dart';
import 'package:maquinados_correa/src/providers/product_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class UpdateProductPageController extends GetxController {
  Product? product;

  @override
  void onInit() {
    super.onInit();
    print('Argumentos recibidos: ${Get.arguments}');
    product = Product.fromJson(Get.arguments['product']);
    print('Producto recibido: ${product?.descr}');
  }

  TextEditingController descrController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController cantidadController = TextEditingController();
  TextEditingController unidController = TextEditingController();

  Rx<String> selectedUnid = Rx<String>('');

  OcProvider ocProvider = OcProvider();

  MaterialesProvider materialesProvider = MaterialesProvider();

  var idMateriales = ''.obs;
  List<Materiales> materiales = <Materiales>[].obs;
  ProductProvider productProvider = ProductProvider();

  UpdateProductPageController() {
    precioController.addListener(updateTotal);
    cantidadController.addListener(updateTotal);
    Product product = Product.fromJson(Get.arguments['product']);
    print('Producto recibido: $product');
    //cantidadController.text = product.cantidad.toString();
    getMateriales();
    descrController.text = product.descr!;
    unidController.text = product.unid!;
    precioController.text = product.precio.toString();
    cantidadController.text = product.cantidad.toString();
  }
  void getMateriales() async {
    var result = await materialesProvider.getAll();
    materiales.addAll(result);
  }
  void updateProduct(BuildContext context) async {
    String descr = descrController.text;
    String precio = precioController.text;
    String unid = unidController.text;
    String cantidad = cantidadController.text;
    String productId = product?.id ?? '';
    print('ID del producto a actualizar: $productId');

    if (precio.isEmpty || cantidad.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa el precio y la cantidad');
      return;
    }
    if (descr.isEmpty|| productId.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa la descripción');
      return;
    }

    double total = double.parse(precio) * double.parse(cantidad);

    ProgressDialog progressDialog = ProgressDialog(context: context);

    if (isValidForm(descr, precio, total.toString(), cantidad)) {
      Product myproduct = Product(
        id: productId,
        descr: descr,
        precio: double.parse(precio),
        total: total,
        unid: unid,
        cantidad: double.parse(cantidad),
        idMateriales: idMateriales.value,
      );
      progressDialog.show(max: 100, msg: 'Espere un momento...');

      ResponseApi responseApi = await productProvider.edit(myproduct);

      progressDialog.close();

      if (responseApi.success == true) {
        Get.snackbar('Éxito', responseApi.message ?? 'Producto editado correctamente', backgroundColor: Colors.green,
          colorText: Colors.white,);
        if (responseApi.success!) { // Si la respuesta es exitosa, navegar a la página de roles
          goToHome();
        }
      } else {
        Get.snackbar('Error', responseApi.message ?? 'Error al editar el producto', backgroundColor: Colors.red,
          colorText: Colors.white,);
      }
    }
  }

  bool isValidForm(String descr, String precio, String total, String cantidad) {
    if (descr.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa la descripción', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (idMateriales.value.isEmpty) {
      Get.snackbar('Formulario no valido', 'Selecciona un material', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    return true;
  }
  void updateTotal() {
    double precio = double.tryParse(precioController.text) ?? 0;
    double cantidad = double.tryParse(cantidadController.text) ?? 0;
    double total = precio * cantidad;
    // Actualiza el valor del controlador de "Total"
    totalController.text = total.toStringAsFixed(2);
  }
     void clearForm() {
       descrController.text = '';
       precioController.text = '';
       cantidadController.text = '';
       totalController.text = '';
       idMateriales.value = '';
       update();
     }
  void goToHome() {
    Get.offNamedUntil('/compras/home', (route) => false);
  }
}
