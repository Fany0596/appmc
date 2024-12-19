import 'dart:async';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/models/product.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/providers/oc_provider.dart';
import 'package:maquinados_correa/src/providers/product_provider.dart';
import 'package:path_provider/path_provider.dart';

class ComprasTabController extends GetxController{
  final ZoomDrawerController zoomDrawerController = ZoomDrawerController();

  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  var oc = Future.value(<Oc>[]).obs; // Usamos Future.value para inicializar la lista de cotizaciones

  TextEditingController clienteController = TextEditingController();

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  OcProvider ocProvider = OcProvider();
  ProductProvider productProvider = ProductProvider();


  List<String> status = <String>['ABIERTA'].obs;
  Timer? _timer;

  Future<List<Oc>> getOc(String status) async {
    return await ocProvider.findByStatus(status);
  }


  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); //Elimina el historial de las pantallas y regresa al login
  }
  void goToNewProveedorPage(){
    Get.toNamed('/compras/newProveedor');
  }
  void goToPerfilPage(){
    Get.toNamed('/profile/info');
  }
  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }

  void goToDetalles(Oc oc){
    Get.toNamed('/compras/list', arguments: {
      'oc': oc.toJson()
    });
  }
  void goToProduct(Product product) {
    print('Producto seleccionado: $product');
    Get.toNamed(
        '/compras/orders/product', arguments: {'product': product.toJson()});
  }
  Future<List<Oc>> getOcs() async {
    return await ocProvider.getExcel();
  }
  void exportToExcel() async {
    var excel = Excel.createExcel(); // Crear una instancia de Excel

    // Obtener los datos que deseas exportar
    List<Oc> oc = await getOcs();

    // Crear una hoja en el archivo de Excel
    Sheet sheetObject = excel['Ocs'];

    // Agregar encabezados
    sheetObject.appendRow(['OC','PROVEEDOR','FECHA DE SOLICITUD','TOTAL', 'FECHA DE ENTREGA', 'STATUS']);

    // Llenar las filas con datos
    for (var oc in oc) {
      double totalOc = 0.0; // Variable para acumular el total de la cotización

      for (var product in oc.product!.where((product) => product.estatus != 'CANCELADO')) {
        totalOc += product.total ?? 0.0; // Acumular el total de cada producto
      }
      sheetObject.appendRow([
        oc.number ?? '',
        oc.provedor!.name.toString(),
        oc.soli,
        '\$${totalOc.toStringAsFixed(2)}',
        oc.ent,
        oc.status,
      ]);

    }
    // Guardar el archivo de Excel en el almacenamiento del dispositivo
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      Get.snackbar('Error', 'No se pudo obtener el directorio de descargas');
      return;
    }

    final filePath = '${directory.path}/ocs.xlsx';
    final fileBytes = excel.encode(); // Obtener los bytes del archivo
    final file = File(filePath);
    await file.writeAsBytes(fileBytes!); // Escribir los bytes en el archivo

    // Mostrar una notificación o mensaje al usuario
    Get.snackbar('DOCUMENTO DESCARGADO EN:', '${filePath}', backgroundColor: Colors.green,
      colorText: Colors.white,);
    print('Archivo Excel guardado en: $filePath');
  }
}