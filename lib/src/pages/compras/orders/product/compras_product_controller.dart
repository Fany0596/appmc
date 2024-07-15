import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/product.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/material_provider.dart';
import 'package:maquinados_correa/src/providers/product_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ComprasProductController extends GetxController {
  Product? product;

  @override
  void onInit() {
    super.onInit();
    print('Argumentos recibidos: ${Get.arguments}');
    product = Product.fromJson(Get.arguments['product']);
    print('Producto recibido: ${product?.descr}');
  }


  TextEditingController descrController = TextEditingController();
  TextEditingController pedidoController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController nameController = TextEditingController();



  var idMateriales = ''.obs;
  List<Materiales> materiales = <Materiales>[].obs;

  ProductProvider productProvider = ProductProvider();
  MaterialesProvider materialesProvider = MaterialesProvider();

  ComprasProductController() {
    Product product = Product.fromJson(Get.arguments['product']);
    print('Producto recibido: $product');
    //cantidadController.text = product.cantidad.toString();
    getMateriales();
    descrController.text = product.descr!;
    nameController.text = product.name!;
  }

  void getMateriales() async {
    var result = await materialesProvider.getAll();
    materiales.addAll(result);
  }

  void updateTotal() {
    double precio = double.tryParse(precioController.text) ?? 0;
    //double cantidad = double.tryParse(cantidadController.text) ?? 0;
    //double total = precio * cantidad;
  }

  void updated(BuildContext context) async {
    String pedido = pedidoController.text;

    // Asegúrate de tener el ID del producto que deseas actualizar
    String productId = product?.id ?? ''; // Esto asume que el ID está presente en el objeto producto
    print('ID del producto a actualizar: $productId');
    // Verifica que todas las propiedades del producto estén definidas

    if ( pedido.isEmpty || productId.isEmpty) {
      Get.snackbar('Formulario no válido', 'Por favor ingresa todos los datos', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return;
    }

    print('CANTIDAD: ${pedido}');
    ProgressDialog progressDialog = ProgressDialog(context: context);


    if (isValidForm( pedido)) { //valida que no esten vacios los campos
      Product myproduct = Product(
          id: product!.id,
          pedido: pedido,
          //pedido: double.parse(cantidad),
          estatus: 'RECIBIDO'
      );
      //Mostrar mensaje de éxito
      // Get.snackbar('Éxito', 'Producto actualizado correctamente');

      try {
        ProgressDialog progressDialog = ProgressDialog(context: context);
        progressDialog.show(max: 100, msg: 'Actualizando producto...');

        // Realizar la solicitud de actualización
        ResponseApi responseApi = await productProvider.updated(myproduct);

        progressDialog.close();

        // Mostrar el resultado de la solicitud
        Get.snackbar(
          responseApi.success! ? 'Éxito'   : 'Error',
          responseApi.message ?? '',
        );
      } catch (e) {
        print('Error al actualizar el producto: $e');
        Get.snackbar('Error', 'Ocurrió un error al actualizar el producto', backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,);
      }
    }
  }
  bool isValidForm( String pedido) {
    if (pedido.isEmpty) {
      Get.snackbar('Formulario no valido', 'Llene todos los campos', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }

    return true;
  }
  void cancelar(BuildContext context) async {

    String productId = product?.id ?? '';
    print('ID del producto a actualizar: $productId');

    ProgressDialog progressDialog = ProgressDialog(context: context);

    if (productId.isNotEmpty) {
      Product myproduct = Product(
          id: productId,
          estatus: 'RECIBIDO'
      );

      try {
        progressDialog.show(max: 100, msg: 'Actualizando producto...');

        // Realizar la solicitud de actualización
        ResponseApi responseApi = await productProvider.cancelar(myproduct);

        progressDialog.close();

        // Mostrar el resultado de la solicitud
        Get.snackbar(
          responseApi.success! ? 'Éxito' : 'Error',
          responseApi.message ?? '', backgroundColor: Colors.green,
            colorText: Colors.white,
        );
      } catch (e) {
        print('Error al actualizar el producto: $e');
        Get.snackbar('Error', 'Ocurrió un error al actualizar el producto');
      }
    } else {
      Get.snackbar('Error', 'ID del producto no encontrado');
    }
  }
}




