import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/material_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ProduccionOtController extends GetxController {
  Producto? producto;

  @override
  void onInit() {
    super.onInit();
    print('Argumentos recibidos: ${Get.arguments}');
    producto = Producto.fromJson(Get.arguments['producto']);
    print('Producto recibido: ${producto?.articulo}');
  }


  TextEditingController articuloController = TextEditingController();
  TextEditingController cantidadController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController parteController = TextEditingController();


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
    articuloController.text = producto.articulo!;
    cantidadController.text = producto.cantidad!.toString();
    precioController.text = producto.precio!.toString();
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
    String precio = precioController.text;
    String cantidad = cantidadController.text;
    String parte = parteController.text;

    // Asegúrate de tener el ID del producto que deseas actualizar
    String productId = producto?.id ??
        ''; // Esto asume que el ID está presente en el objeto producto
    print('ID del producto a actualizar: $productId');
    // Verifica que todas las propiedades del producto estén definidas
    if (articulo.isEmpty || precio.isEmpty || cantidad.isEmpty ||
        productId.isEmpty|| parte.isEmpty) {
      Get.snackbar('Formulario no válido', 'Por favor ingresa todos los datos');
      return;
    }

    // Calcula el total multiplicando precio y cantidad
    double total = double.parse(precio) * double.parse(cantidad);

    print('ARTICULO: ${articulo}');
    print('PRECIO: ${precio}');
    print('TOTAL: ${total}');
    print('CANTIDAD: ${cantidad}');
    print('No. Parte: ${parte}');
    print('ID MATERIAL: ${idMateriales}');
    ProgressDialog progressDialog = ProgressDialog(context: context);


    if (isValidForm(articulo, precio, total.toString(), cantidad, parte)) { //valida que no esten vacios los campos
      Producto myproducto = Producto(
          id: producto!.id,
          articulo: articulo,
          precio: double.parse(precio),
          total: total,
          cantidad: double.parse(cantidad),
          parte: parte,
          idMateriales: idMateriales.value,
          estatus: 'EN ESPERA'
      );
      //Mostrar mensaje de éxito
             // Get.snackbar('Éxito', 'Producto actualizado correctamente');

      try {
        ProgressDialog progressDialog = ProgressDialog(context: context);
        progressDialog.show(max: 100, msg: 'Actualizando producto...');

        // Realizar la solicitud de actualización
        ResponseApi responseApi = await productoProvider.updated(myproducto);

        progressDialog.close();

        // Mostrar el resultado de la solicitud
        Get.snackbar(
          responseApi.success! ? 'Éxito' : 'Error',
          responseApi.message ?? '',
        );
      } catch (e) {
        print('Error al actualizar el producto: $e');
        Get.snackbar('Error', 'Ocurrió un error al actualizar el producto');
      }
    }
    }
    bool isValidForm(String articulo, String precio, String total,
        String cantidad, String parte) {
      if (articulo.isEmpty) {
        Get.snackbar('Formulario no valido', 'Llene todos los campos');
        return false;
      }
      if (idMateriales == null) {
        Get.snackbar('Formulario no valido', 'Selecciona un material');
        return false;
      }

      return true;
    }
  void cancelar(BuildContext context) async {
    String articulo = articuloController.text;
    String precio = precioController.text;
    String cantidad = cantidadController.text;
    String parte = parteController.text;

    // Asegúrate de tener el ID del producto que deseas actualizar
    String productId = producto?.id ?? ''; // Esto asume que el ID está presente en el objeto producto
    print('ID del producto a actualizar: $productId');
    // Verifica que todas las propiedades del producto estén definidas
    if ( materiales.isEmpty) {
      Get.snackbar('Formulario no válido', 'Por favor ingresa el material');
      return;
    }

    // Calcula el total multiplicando precio y cantidad
    double total = double.parse(precio) * double.parse(cantidad);

    print('ARTICULO: ${articulo}');
    print('PRECIO: ${precio}');
    print('TOTAL: ${total}');
    print('CANTIDAD: ${cantidad}');
    print('ID MATERIAL: ${idMateriales}');
    ProgressDialog progressDialog = ProgressDialog(context: context);


    if (isValidForm(articulo, precio, total.toString(),
      cantidad, parte,)) { //valida que no esten vacios los campos
      Producto myproducto = Producto(
          id: producto!.id,
          articulo: articulo,
          precio: double.parse(precio),
          total: total,
          //parte: parte,
          cantidad: double.parse(cantidad),
          idMateriales: idMateriales.value,
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
          responseApi.message ?? '',
        );

      } catch (e) {
        print('Error al actualizar el producto: $e');
        Get.snackbar('Ocurrió un error al actualizar el producto', 'Verifique los campos');
      }
    }
  }
  }


