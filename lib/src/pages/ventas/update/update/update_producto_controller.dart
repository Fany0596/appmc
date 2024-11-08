import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/material_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class UpdateProductoPageController extends GetxController {
  Producto? producto;

  @override
  void onInit() {
    super.onInit();
    print('Argumentos recibidos: ${Get.arguments}');
    producto = Producto.fromJson(Get.arguments['producto']);
    print('Producto recibido: ${producto?.descr}');
  }

  TextEditingController articuloController = TextEditingController();
  TextEditingController descrController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController cantidadController = TextEditingController();

  CotizacionProvider cotizacionProvider = CotizacionProvider();

  MaterialesProvider materialesProvider = MaterialesProvider();

  ProductoProvider productoProvider = ProductoProvider();

  UpdateProductoPageController() {
    precioController.addListener(updateTotal);
    cantidadController.addListener(updateTotal);
    Producto producto = Producto.fromJson(Get.arguments['producto']);
    print('Producto recibido: $producto');
    descrController.text = producto.descr!;
    cantidadController.text = producto.cantidad!.toStringAsFixed(2);
    precioController.text = producto.precio!.toStringAsFixed(2);
  }

  void updateTotal() {
    double precio = double.tryParse(precioController.text) ?? 0;
    double cantidad = double.tryParse(cantidadController.text) ?? 0;
    double total = precio * cantidad;

    // Actualiza el valor del controlador de "Total"
    totalController.text = total.toStringAsFixed(2);
  }

  void createProducto(BuildContext context) async {

    String descr = descrController.text;
    String precio = precioController.text;
    String cantidad = cantidadController.text;
    String productoId = producto?.id ?? '';

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

    print('PRECIO: ${precio}');
    print('TOTAL: ${total}');
    print('CANTIDAD: ${cantidad}');
    ProgressDialog progressDialog = ProgressDialog(context: context);



    if (isValidForm(precio, total.toString(), cantidad, descr)){ //valida que no esten vacios los campos
      Producto myproducto = Producto(
          id: productoId,
        descr: descr,
        precio: double.parse(precio),
        total: total,
        cantidad: double.parse(cantidad),
      );
      progressDialog.show(max: 100, msg:'Espere un momento...');


      ResponseApi responseApi = await productoProvider.edit(myproducto);
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
  bool isValidForm(String precio, String total, String cantidad, String descr) {

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

    return true;
  }

     void clearForm() {
       articuloController.text = '';
       descrController.text = '';
       precioController.text = '';
       cantidadController.text = '';
       totalController.text = '';
       update();
     }
  void goToHome() {
    Get.offNamedUntil('/ventas/home', (route) => false);
  }
}
