import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/oc_provider.dart';

class ComprasOcListController extends GetxController {
  final ZoomDrawerController zoomDrawerController = ZoomDrawerController();
  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;

  OcProvider ocProvider = OcProvider();
  List<String> status = <String>['ABIERTA', 'CERRADA', 'CANCELADA'].obs;
  var filteredOc = <Oc>[].obs;
  var oc = <Oc>[].obs;
  var searchText = ''.obs;


  void filterOc(String status, int tabIndex) async {
    List<Oc> allOc = await getOc(status);
    if (searchText.isEmpty) {
      filteredOc.value = allOc;
    } else {
      filteredOc.value = allOc
          .where((oc) =>
              oc.number!.toLowerCase().contains(searchText.toLowerCase()) ||
              oc.provedor!.name!
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
          .toList();
    }
  }

  Future<List<Oc>> getOc(String status) async {
    List<Oc> ocList = await ocProvider.findByStatus(status);

    if (ocList != null) {
      // Ordenar la lista de OC numéricamente por el número de OC
      ocList.sort((a, b) => a.number!.compareTo(b.number!));
      return ocList;
    } else {
      return []; // Devolver una lista vacía si ocList es null
    }
  }

  void deleteOc(Oc oc) async {
    ResponseApi responseApi = await ocProvider
        .deleted(oc.id!); // Llama al backend para eliminar el producto
    if (responseApi.success == true) {
      Get.snackbar(
        'Éxito',
        responseApi.message ?? 'Producto eliminado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        responseApi.message ?? 'Error al eliminar el producto',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil(
        '/',
        (route) =>
            false); //Elimina el historial de las pantallas y regresa al login
  }

  void goToNewProveedorPage() {
    Get.toNamed('/compras/newProveedor');
  }


  void goToPerfilPage() {
    Get.toNamed('/profile/info');
  }

  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }

  void goToDetalles(Oc oc) {
    Get.toNamed('/compras/orders/list', arguments: {'oc': oc.toJson()});
  }
}
