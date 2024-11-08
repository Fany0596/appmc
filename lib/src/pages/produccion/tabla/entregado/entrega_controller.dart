import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class EntregaController extends GetxController {
  Producto? producto;
  var selectedDate = ''.obs;
  final Rx<String> pdfFileName = ''.obs;
  Rx<String> selectedEfec = Rx<String>('');

  @override
  void onInit() {
    super.onInit();
    print('Argumentos recibidos: ${Get.arguments}');
    producto = Producto.fromJson(Get.arguments['producto']);
    print('Producto recibido: ${producto?.articulo}');
  }

  ProductoProvider productoProvider = ProductoProvider();
  TextEditingController entregaController = TextEditingController();
  TextEditingController efectividadController = TextEditingController();

  void entregado(BuildContext context) async {
    String productId = producto?.id ?? ''; // Esto asume que el ID está presente en el objeto producto
    print('ID del producto a actualizar: $productId');
    String entrega = entregaController.text;
    String efectividad = efectividadController.text;
    // Verifica que todas las propiedades del producto estén definida
    ProgressDialog progressDialog = ProgressDialog(context: context);


    if (isValidForms()) { //valida que no esten vacios los campos
      Producto myproducto = Producto(
          id: producto!.id,
          estatus: 'ENTREGADO',
          operador: '',
          operacion: '',
          efectividad: efectividad,
          entrega: entrega,
      );
      //Mostrar mensaje de éxito

      try {
        ProgressDialog progressDialog = ProgressDialog(context: context);
        progressDialog.show(max: 100, msg: 'Actualizando producto...');

        // Realizar la solicitud de actualización
        ResponseApi responseApi = await productoProvider.entregar(myproducto);

        progressDialog.close();

        // Mostrar el resultado de la solicitud
        if (responseApi.success == true) {
          Get.snackbar('Producto entregado exitosamente','' ,backgroundColor: Colors.green,
            colorText: Colors.white,);
          goToHome();
        }

      } catch (e) {
        print('Error al actualizar el producto: $e');
        Get.snackbar('Ocurrió un error al actualizar el producto', 'Verifique los campos', backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,);
      }
    }
  }
  bool isValidForms() {
    if (producto!.id!.isEmpty) {
      Get.snackbar('Formulario no valido', 'Llene todos los campos', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    return true;
  }
  void goToHome() {
    Get.offNamedUntil('/produccion/home', (route) => false);
  }
}
