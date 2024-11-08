import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/comprador.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/models/product.dart';
import 'package:maquinados_correa/src/models/provedor.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/comprador_provider.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/providers/material_provider.dart';
import 'package:maquinados_correa/src/providers/oc_provider.dart';
import 'package:maquinados_correa/src/providers/product_provider.dart';
import 'package:maquinados_correa/src/providers/provedor_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class CombinedOcController extends GetxController {
  // Controladores de texto para oc
  TextEditingController numberController = TextEditingController();
  TextEditingController entController = TextEditingController();
  TextEditingController soliController = TextEditingController();
  TextEditingController comentController = TextEditingController();
  TextEditingController condicionesController = TextEditingController();
  TextEditingController monedaController = TextEditingController();
  TextEditingController tipoController = TextEditingController();

  // Controladores de texto para producto
  TextEditingController descrController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController cantidadController = TextEditingController();
  TextEditingController unidController = TextEditingController();

  // Variables observables
  var idCotizaciones = ''.obs;
  var idComprador = ''.obs;
  var idProvedor = ''.obs;
  var idOc = ''.obs;
  var idMateriales = ''.obs;
  String? prevNumb; // Variable para almacenar el último número de cotización registrado
  String? newNumb;
  Rx<String> selectedCondition = Rx<String>('');
  Rx<String> selectedMoneda = Rx<String>('');
  Rx<String> selectedTipo = Rx<String>('');
  Rx<String> selectedUnid = Rx<String>('');
  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;

  // Listas
  List<Cotizacion> cotizacion = <Cotizacion>[].obs;
  List<Comprador> comprador = <Comprador>[].obs;
  List<Provedor> provedor = <Provedor>[].obs;
  List<Materiales> materiales = <Materiales>[].obs;
  List<Product> productosPendientes = <Product>[].obs;
  List<Oc> oc = <Oc>[].obs;

  // Providers
  OcProvider ocProvider = OcProvider();
  ProvedorProvider provedorProvider = ProvedorProvider();
  CotizacionProvider cotizacionProvider = CotizacionProvider();
  CompradorProvider compradorProvider = CompradorProvider();
  ProductProvider productProvider = ProductProvider();
  MaterialesProvider materialesProvider = MaterialesProvider();

  @override
  void onInit() {
    super.onInit();
    getNextQuoteNumber();
    getCotizacion();
    getProvedor();
    getComprador();
    getMateriales();
    precioController.addListener(updateTotal);
    cantidadController.addListener(updateTotal);
  }
  void getComprador() async {
    var result = await compradorProvider.getAll();
    comprador.clear();
    comprador.addAll(result);
  }
  void getCotizacion() async {
    var result = await cotizacionProvider.getAll();
    cotizacion.clear();
    cotizacion.addAll(result);
  }
  void getProvedor() async {
    var result = await provedorProvider.getAll();
    provedor.clear();
    provedor.addAll(result);
  }
  void getNextQuoteNumber() async {
    // Llama al proveedor de cotizaciones para obtener el último número de cotización
    List<Oc> oc = await ocProvider.getAll();
    int year = DateTime.now().year;
    String yearSuffix = year.toString().substring(2); // Obtiene los últimos dos dígitos del año
    int nextSequentialNumber = 1;

    if (oc.isNotEmpty) {
      // Si hay OC registradas, obtén el último número de la última OC
      String lastQuoteNumber = oc.last.number ?? ""; // Obtén el número de OC
      RegExp regex = RegExp(r'OC-(\d+)-(\d{2})');
      Match? match = regex.firstMatch(lastQuoteNumber);

      if (match != null) {
        String lastYearSuffix = match.group(2)!;
        int lastSequentialNumber = int.parse(match.group(1)!);

        if (lastYearSuffix == yearSuffix) {
          nextSequentialNumber = lastSequentialNumber + 1;
        }
      }
    }

    String formattedSequentialNumber = nextSequentialNumber.toString().padLeft(3, '0');
    newNumb = "OC-$formattedSequentialNumber-$yearSuffix";
    numberController.text = newNumb!;
    update(); // Actualiza para que la UI muestre los nuevos números
  }


  void getMateriales() async {
    var result = await materialesProvider.getAll();
    materiales.clear();
    materiales.addAll(result);
  }

  void updateTotal() {
    double precio = double.tryParse(precioController.text) ?? 0;
    double cantidad = double.tryParse(cantidadController.text) ?? 0;
    double total = precio * cantidad;
    totalController.text = total.toStringAsFixed(2);
  }

  void agregarProducto(BuildContext context) {
    String descr = descrController.text;
    String precio = precioController.text;
    String unid = unidController.text;
    String cantidad = cantidadController.text;

    // Calcula el total multiplicando precio y cantidad
    double total = double.parse(precio) * double.parse(cantidad);

    if (isValidProductForm(descr, precio, total.toString(), cantidad)){ //valida que no esten vacios los campos
      Product product = Product(
          descr: descr,
          precio: double.parse(precio),
          total: total,
          unid: unid,
          cantidad: double.parse(cantidad),
          idOc: idOc.value,
          idMateriales: idMateriales.value
      );

      productosPendientes.add(product);
      clearForm2();
      update();
      Get.snackbar('Producto agregado', 'El producto se ha agregado a la lista',
          backgroundColor: Colors.green, colorText: Colors.white);
    }
  }

  bool isValidProductForm(String descr, String total, String precio, String cantidad) {
    if ( descr.isEmpty || precio.isEmpty || cantidad.isEmpty ||
        idMateriales.value.isEmpty) {
      Get.snackbar(
        'Formulario no válido',
        'Llenar todos los datos del producto',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (double.tryParse(precio) == null || double.tryParse(cantidad) == null) {
      Get.snackbar(
        'Formulario no válido',
        'El precio y la cantidad deben ser números válidos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }
  void guardarTodosLosProductos(BuildContext context) async {
    if (productosPendientes.isEmpty) {
      Get.snackbar('Error', 'No hay productos para guardar',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    ProgressDialog progressDialog = ProgressDialog(context: context);
    progressDialog.show(max: 100, msg: 'Guardando productos...');

    for (var product in productosPendientes) {
      List<File> images = [];
      Stream stream = await productProvider.create(product, images);
      await for (var res in stream) {
        ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
        if (responseApi.success != true) {
          progressDialog.close();
          Get.snackbar(
              'Error', 'No se pudo guardar el producto: ${product.descr}',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      }
    }

    progressDialog.close();

    clearForm2();
  }

  void removeProducto(int index) {
    productosPendientes.removeAt(index);
    update();
  }

  void guardarOcYProductos(BuildContext context) async {
    if (!isValidForms()) {
      Get.snackbar('Error', 'Por favor, complete todos los campos requeridos',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    ProgressDialog progressDialog = ProgressDialog(context: context);
    progressDialog.show(max: 100, msg: 'Guardando OC y productos...');

    try {
      // Crear objeto Cotizacion
      Oc oc = Oc(
          number: numberController.text,
          ent: entController.text,
          soli: soliController.text,
          condiciones: condicionesController.text,
          moneda: monedaController.text,
          coment: comentController.text,
          tipo: tipoController.text,
          idComprador: idComprador.value,
          idCotizaciones: idCotizaciones.value,
          idProvedor: idProvedor.value
      );

      // Guardar la cotización
      List<File> images = [];
      ResponseApi ocResponse = await ocProvider.create(oc, images).then((stream) => stream.first).then((res) => ResponseApi.fromJson(json.decode(res)));

      if (ocResponse.success == true) {
        int ocId = int.parse(ocResponse.data['id_oc'].toString());
        print('ID de oc generado: $ocId');

        // Si la cotización se guardó exitosamente, guarda los productos
        for (var product in productosPendientes) {
          product.idOc = ocId.toString();
          ResponseApi productResponse = await productProvider.create(product, images).then((stream) => stream.first).then((res) => ResponseApi.fromJson(json.decode(res)));

          if (productResponse.success != true) {
            throw Exception('Error al guardar producto: ${productResponse.message}');
          }
        }

        progressDialog.close();
        Get.snackbar('Éxito', 'Oc y productos guardados correctamente',
            backgroundColor: Colors.green, colorText: Colors.white);

        // Limpiar formularios y lista de productos pendientes
        clearForm();
        productosPendientes.clear();
        update();
      } else {
        throw Exception('Error al guardar la oc: ${ocResponse.message}');
      }
    } catch (e) {
      progressDialog.close();
      Get.snackbar('Error', 'No se pudo guardar la oc y/o productos: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  bool isValidForms() {
    return numberController.text.isNotEmpty &&
        entController.text.isNotEmpty &&
        soliController.text.isNotEmpty &&
        monedaController.text.isNotEmpty &&
        tipoController.text.isNotEmpty &&
        condicionesController.text.isNotEmpty &&
        idComprador.value.isNotEmpty &&
        idCotizaciones.value.isNotEmpty &&
        idProvedor.value.isNotEmpty &&
        productosPendientes.isNotEmpty;
  }

  void clearForm() {
    numberController.clear();
    entController.clear();
    soliController.clear();
    monedaController.clear();
    tipoController.clear();
    comentController.clear();
    condicionesController.clear();
    descrController.clear();
    precioController.clear();
    cantidadController.clear();
    totalController.clear();
    idMateriales.value = '';
    idComprador.value = '';
    idCotizaciones.value = '';
    idProvedor.value = '';
  }

  void clearForm2() {
    descrController.text = '';
    precioController.text = '';
    cantidadController.text = '';
    totalController.text = '';
    idMateriales.value = '';
    // update();
  }
  void reloadPage() {
    getMateriales(); // Recargar materiales
    update(); // Actualizar el controlador
  }
  void goToPerfilPage(){
    Get.toNamed('/profile/info');
  }
  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }
  void goToNewProveedorPage() {
    Get.toNamed('/compras/newProveedor');
  }
  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); //Elimina el historial de las pantallas y regresa al login
  }
}