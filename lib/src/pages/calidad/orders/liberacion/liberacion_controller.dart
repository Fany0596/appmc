import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class LiberacionController extends GetxController {
  Producto? producto;
  File? pdfFile;
  final Rx<String> pdfFileName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('Argumentos recibidos: ${Get.arguments}');
    producto = Producto.fromJson(Get.arguments['producto']);
    print('Producto recibido: ${producto?.articulo}');
  }

  ProductoProvider productoProvider = ProductoProvider();

  void rechazado(BuildContext context) async {
    String productId = producto?.id ?? ''; // Esto asume que el ID está presente en el objeto producto
    print('ID del producto a actualizar: $productId');
    // Verifica que todas las propiedades del producto estén definida
    ProgressDialog progressDialog = ProgressDialog(context: context);


    if (isValidForms()) { //valida que no esten vacios los campos
      Producto myproducto = Producto(
          id: producto!.id,
          estatus: 'RECHAZADO',
          operador: '',
          operacion: '',
      );
      //Mostrar mensaje de éxito

      try {
        ProgressDialog progressDialog = ProgressDialog(context: context);
        progressDialog.show(max: 100, msg: 'Actualizando producto...');

        // Realizar la solicitud de actualización
        ResponseApi responseApi = await productoProvider.rechazar(myproducto);

        progressDialog.close();

        // Mostrar el resultado de la solicitud
        Get.snackbar(
          responseApi.success! ? 'Éxito' : 'Error',
          responseApi.message ?? '', backgroundColor: Colors.green,
          colorText: Colors.white,
        );

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
  void retrabajo(BuildContext context) async {
    // Asegúrate de tener el ID del producto que deseas actualizar
    String productId = producto?.id ?? ''; // Esto asume que el ID está presente en el objeto producto
    print('ID del producto a actualizar: $productId');
    // Verifica que todas las propiedades del producto estén definida
    ProgressDialog progressDialog = ProgressDialog(context: context);


    if (isValidForm()) { //valida que no esten vacios los campos
      Producto myproducto = Producto(
          id: producto!.id,
          estatus: 'RETRABAJO',
          operador: '',
          operacion: '',
      );
      //Mostrar mensaje de éxito

      try {
        ProgressDialog progressDialog = ProgressDialog(context: context);
        progressDialog.show(max: 100, msg: 'Actualizando producto...');

        // Realizar la solicitud de actualización
        ResponseApi responseApi = await productoProvider.retrabajo(myproducto);

        progressDialog.close();

        // Mostrar el resultado de la solicitud
        Get.snackbar(
          responseApi.success! ? 'Éxito' : 'Error',
          responseApi.message ?? '', backgroundColor: Colors.green,
          colorText: Colors.white,
        );

      } catch (e) {
        print('Error al actualizar el producto: $e');
        Get.snackbar('Ocurrió un error al actualizar el producto', 'Verifique los campos', backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,);
      }
    }
  }
  bool isValidForm() {
    if (producto!.id!.isEmpty) {
      Get.snackbar('Formulario no valido', 'Llene todos los campos', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    return true;
  }
  void liberar(BuildContext context) async {
    String productId = producto?.id ??
        ''; // Esto asume que el ID está presente en el objeto producto
    print('ID del producto a actualizar: $productId');
    // Verifica que todas las propiedades del producto estén definida
    ProgressDialog progressDialog = ProgressDialog(context: context);


    if (isValidFormss()) { //valida que no esten vacios los campos
      Producto myproducto = Producto(
        id: producto!.id,
        estatus: 'LIBERADO',
        operador: '',
        operacion: '',
      );
      if (pdfFile == null) {
        Get.snackbar('Error', 'Por favor, selecciona un archivo PDF');
        return;
      }
      progressDialog.show(max: 100, msg: 'Espere un momento...');

      try {
        ResponseApi responseApi = await productoProvider.liberar(myproducto, pdfFile!);
        progressDialog.close();

        if (responseApi.success == true) {
          Get.snackbar('Producto liberado exitosamente','' ,backgroundColor: Colors.green,
            colorText: Colors.white,);
            goToHome();
        }
      } catch (e) {
        progressDialog.close();
        Get.snackbar('Error', 'No se pudo crear el producto: ${e.toString()}',backgroundColor: Colors.red,
          colorText: Colors.white,);
        print('No se pudo crear el producto: ${e.toString()}');
      }

    }
  }
  bool isValidFormss() {
    if (producto!.id!.isEmpty) {
      Get.snackbar('Formulario no valido', 'Llene todos los campos', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (pdfFile == null) {
      Get.snackbar('Formulario no válido', 'Selecciona un archivo PDF para el producto');
      return false;
    }
    return true;
  }
  Future selectPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      pdfFile = File(result.files.single.path!);
      pdfFileName.value = result.files.single.name; // Actualiza el nombre del archivo
      update();
    }
  }

  void showAlertDialog(BuildContext context) {
    Widget selectButton = ElevatedButton(
        onPressed: () {
          Get.back();
          selectPDF();
        },
        child: Text(
          'SELECCIONAR PDF',
          style: TextStyle(
              color: Colors.black
          ),
        )
    );

    AlertDialog alertDialog = AlertDialog(
      title: Text('Selecciona un archivo PDF'),
      actions: [
        selectButton
      ],
    );

    showDialog(context: context, builder: (BuildContext context) {
      return alertDialog;
    });
  }
  void goToHome() {
    Get.offNamedUntil('/calidad/home', (route) => false);
  }
}
