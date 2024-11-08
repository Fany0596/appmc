import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/material_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ProduccionOtController extends GetxController {
  Producto? producto;
  File? planopdf;
  final Rx<String> planopdfName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('Argumentos recibidos: ${Get.arguments}');
    producto = Producto.fromJson(Get.arguments['producto']);
    print('Producto recibido: ${producto?.descr}');
  }


  TextEditingController articuloController = TextEditingController();
  TextEditingController cantidadController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController parteController = TextEditingController();
  TextEditingController descrController = TextEditingController();


  var idMateriales = ''.obs;
  List<Materiales> materiales = <Materiales>[].obs;

  ProductoProvider productoProvider = ProductoProvider();
  MaterialesProvider materialesProvider = MaterialesProvider();

  ProduccionOtController() {
    Producto producto = Producto.fromJson(Get.arguments['producto']);
    print('Producto recibido: $producto');
    precioController.addListener(updateTotal);
    cantidadController.addListener(updateTotal);
    getMateriales();
    articuloController.text = producto.articulo ?? '';
    parteController.text = producto.parte ?? '';
    descrController.text = producto.descr!;
    cantidadController.text = producto.cantidad!.toString();
    precioController.text = producto.precio!.toString();
  }

  void selectPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      planopdf = File(result.files.single.path!);
      print('PDF Seleccionado: ${planopdf!.path}');
      planopdfName.value = result.files.single.name; // Actualiza el nombre del archivo
      update();
    }
  }

  void getMateriales() async {
    var result = await materialesProvider.getAll();
    materiales.addAll(result);
  }

  void updateTotal() {
    double precio = double.tryParse(precioController.text) ?? 0;
    double cantidad = double.tryParse(cantidadController.text) ?? 0;
    double total = precio * cantidad;

    // Actualiza el valor del controlador de "Total"
    totalController.text = total.toStringAsFixed(2);
  }

  void updated(BuildContext context) async {
    String articulo = articuloController.text;
    String cantidad = cantidadController.text;
    String parte = parteController.text;

    // Asegúrate de tener el ID del producto que deseas actualizar
    String productId = producto?.id ?? ''; // Esto asume que el ID está presente en el objeto producto
    print('ID del producto a actualizar: $productId');
    // Verifica que todas las propiedades del producto estén definidas
    /*if (articulo.isEmpty || cantidad.isEmpty ||
        productId.isEmpty|| parte.isEmpty) {
      Get.snackbar('Formulario no válido', 'Por favor ingresa todos los datos', backgroundColor: Colors.red,
        colorText: Colors.white,);
      return;
    }*/

    print('ARTICULO: ${articulo}');
    print('CANTIDAD: ${cantidad}');
    print('No. Parte: ${parte}');
    print('ID MATERIAL: ${idMateriales}');
    ProgressDialog progressDialog = ProgressDialog(context: context);


    if (isValidForm(articulo, cantidad, parte)) { //valida que no esten vacios los campos
      Producto myproducto = Producto(
          id: producto!.id,
          articulo: articulo,
          cantidad: double.parse(cantidad),
          parte: parte,
          idMateriales: idMateriales.value,
          estatus: 'EN ESPERA'
      );
      //Mostrar mensaje de éxito
             // Get.snackbar('Éxito', 'Producto actualizado correctamente');

      try {
        ////ProgressDialog progressDialog = ProgressDialog(context: context);
        progressDialog.show(max: 100, msg: 'Actualizando producto...');

        // Realizar la solicitud de actualización
        ResponseApi responseApi = await productoProvider.updated(myproducto, planopdf: planopdf,);

        progressDialog.close();

        if (responseApi.success != true) {
          progressDialog.close();
          Get.snackbar(
              'Error', 'Verifique informacón',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
        Get.back();
        Get.snackbar('Éxito', 'Producto actualizado',
            backgroundColor: Colors.green, colorText: Colors.white);


      } catch (e) {
        print('Error al actualizar el producto: $e');
        Get.snackbar('Error', 'Ocurrió un error al actualizar el producto', backgroundColor: Colors.red,
          colorText: Colors.white,
          );
      }

    }
    }
    bool isValidForm(String articulo,
        String cantidad, String parte) {
      if (articulo.isEmpty) {
        Get.snackbar('Formulario no valido', 'Llene el campo Articulo', backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      if (parte.isEmpty) {
        Get.snackbar('Formulario no valido', 'Llene el campo No. Parte/Plano', backgroundColor: Colors.red,
          colorText: Colors.white,
          );
        return false;
      }
      if (cantidad.isEmpty) {
        Get.snackbar('Formulario no valido', 'Llene el campo Cantidad', backgroundColor: Colors.red,
          colorText: Colors.white,
          );
        return false;
      }
      if (idMateriales == null) {
        Get.snackbar('Formulario no valido', 'Selecciona un material', backgroundColor: Colors.red,
          colorText: Colors.white,
          );
        return false;
      }

      return true;
    }
  void cancelar(BuildContext context) async {
    String articulo = articuloController.text;

    // Asegúrate de tener el ID del producto que deseas actualizar
    String productId = producto?.id ?? ''; // Esto asume que el ID está presente en el objeto producto
    print('ID del producto a actualizar: $productId');
    // Verifica que todas las propiedades del producto estén definidas
    if ( materiales.isEmpty) {
      Get.snackbar('Formulario no válido', 'Por favor ingresa el material', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return;
    }

    print('ARTICULO: ${articulo}');
    print('ID MATERIAL: ${idMateriales}');
    ProgressDialog progressDialog = ProgressDialog(context: context);


    if (isValidForms(articulo)) { //valida que no esten vacios los campos
      Producto myproducto = Producto(
          id: producto!.id,
          articulo: articulo,
          estatus: 'CANCELADO'
      );
      //Mostrar mensaje de éxito

      try {
        ProgressDialog progressDialog = ProgressDialog(context: context);
        progressDialog.show(max: 100, msg: 'Actualizando producto...');

        // Realizar la solicitud de actualización
        ResponseApi responseApi = await productoProvider.cancelar(myproducto);

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
  bool isValidForms(String articulo) {
    if (articulo.isEmpty) {
      Get.snackbar('Formulario no valido', 'Llene todos los campos', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    return true;
  }
  }


