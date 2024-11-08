import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/models/product.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/providers/oc_provider.dart';
import 'package:maquinados_correa/src/providers/product_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';

class ComprasTabController2 extends GetxController{

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
}