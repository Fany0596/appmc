import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class VentasTabController extends GetxController{

  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  TextEditingController clienteController = TextEditingController();

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  ProductoProvider productoProvider = ProductoProvider();

  var totalt = 0.0.obs;
  List<String> status = <String>['GENERADA'].obs;
  Future<List<Cotizacion>> getCotizacion(String status) async {
    return await cotizacionProvider.findByStatus(status);

  }

  void goToNewVendedorPage(){
    Get.toNamed('/ventas/newVendedor');
  }
  void goToNewClientePage(){
    Get.toNamed('/ventas/newClient');
  }
  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); //Elimina el historial de las pantallas y regresa al login
  }
  void goToRegisterPage(){
    Get.toNamed('/registro');
  }
  void goToPerfilPage(){
    Get.toNamed('/profile/info');
  }
  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }

  void goToDetalles(Cotizacion cotizacion){
    Get.toNamed('/produccion/orders/detalles_produccion', arguments: {
      'cotizacion': cotizacion.toJson()
    });
  }
  void goToPrice(Producto producto) {
    print('Producto seleccionado: $producto');
    Get.toNamed('/ventas/update/price', arguments: {'producto': producto.toJson()});
  }
  Future<List<Cotizacion>> getCotizaciones() async {
    return await cotizacionProvider.getExcel();  // Supongo que tienes un método que obtiene todas las cotizaciones
  }
  void exportToExcel() async {
    var excel = Excel.createExcel(); // Crear una instancia de Excel

    // Obtener los datos que deseas exportar
    List<Cotizacion> cotizaciones = await getCotizaciones();

    // Crear una hoja en el archivo de Excel
    Sheet sheetObject = excel['Cotizaciones'];

    // Agregar encabezados
    sheetObject.appendRow(['COTIZACIÓN','TOTAL','FECHA','REQUERIMIENTO', 'CLIENTE', 'TIEMPO DE ENTREGA', 'VENDEDOR']);

    // Llenar las filas con datos
    for (var cotizacion in cotizaciones) {
      double totalCotizacion = 0.0; // Variable para acumular el total de la cotización

      for (var producto in cotizacion.producto!.where((producto) => producto.estatus != 'CANCELADO')) {
        totalCotizacion += producto.total ?? 0.0; // Acumular el total de cada producto
      }
        sheetObject.appendRow([
          cotizacion.number ?? '',
          '\$${totalCotizacion.toStringAsFixed(2)}',
          cotizacion.fecha ?? '',
          cotizacion.req ?? '',
          cotizacion.clientes!.name.toString(),
          cotizacion.ent ?? '',
          cotizacion.vendedores!.name.toString(),
        ]);

    }
    // Guardar el archivo de Excel en el almacenamiento del dispositivo
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      Get.snackbar('Error', 'No se pudo obtener el directorio de descargas');
      return;
    }

    final filePath = '${directory.path}/cotizaciones.xlsx';
    final fileBytes = excel.encode(); // Obtener los bytes del archivo
    final file = File(filePath);
    await file.writeAsBytes(fileBytes!); // Escribir los bytes en el archivo

    // Mostrar una notificación o mensaje al usuario
    Get.snackbar('DOCUMENTO DESCARGADO EN:', '${filePath}', backgroundColor: Colors.green,
      colorText: Colors.white,);
    print('Archivo Excel guardado en: $filePath');
  }
}