import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';

class VentasOcListController extends GetxController{

  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  List<String> status = <String>['ABIERTA','CONFIRMADA','GENERADA', 'CERRADA', 'CANCELADA'].obs;
  var cotizaciones = <Cotizacion>[].obs;
  var filteredCotizaciones = <Cotizacion>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCotizaciones();
  }
  Future<void> loadCotizaciones() async {
    cotizaciones.clear();
    filteredCotizaciones.clear();
    for (var status in this.status) {
      var cotizacionesList = await cotizacionProvider.findByStatus(status);
      cotizaciones.addAll(cotizacionesList);
      filteredCotizaciones.addAll(cotizacionesList);
    }
  }

  void filterCotizaciones(String query) {
    var lowerCaseQuery = query.toLowerCase();
    filteredCotizaciones.value = cotizaciones.where((cotizacion) {
      return cotizacion.number!.toLowerCase().contains(lowerCaseQuery) ||
          cotizacion.clientes!.name!.toLowerCase().contains(lowerCaseQuery) ?? false;
    }).toList();
  }

  Future<List<Cotizacion>> getCotizacion(String status) async {
    return filteredCotizaciones.where((cotizacion) => cotizacion.status == status).toList();
  }

  void deleteCotizacion(Cotizacion cotizacion) async {
    ResponseApi responseApi = await cotizacionProvider.deleted(cotizacion.id!); // Llama al backend para eliminar el producto
    if (responseApi.success == true) {
      Get.snackbar('Éxito', responseApi.message ?? 'Producto eliminado correctamente', backgroundColor: Colors.green,
        colorText: Colors.white,);
      if (responseApi.success!) { // Si la respuesta es exitosa, navegar a la página de roles
        reloadPage();
      }
    } else {
      Get.snackbar('Error', responseApi.message ?? 'Error al eliminar el producto', backgroundColor: Colors.red,
        colorText: Colors.white,);
    }
  }

  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); //Elimina el historial de las pantallas y regresa al login
  }
  void goToNewVendedorPage(){
    Get.toNamed('/ventas/newVendedor');
  }
  void goToNewClientePage(){
    Get.toNamed('/ventas/newClient');
  }
  void goToPerfilPage(){
    Get.toNamed('/profile/info');
  }
  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }

  void goToDetalles(Cotizacion cotizacion){
   Get.toNamed('/ventas/orders/detalles', arguments: {
     'cotizacion': cotizacion.toJson()
   });
  }
  void reloadPage() {
    onInit();
    update();         // Actualizar el controlador
  }
}

