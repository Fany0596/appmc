import 'package:get/get.dart';
import 'dart:async';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';

class VentasOcListController extends GetxController{

  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  List<String> status = <String>['ABIERTA','CONFIRMADA', 'CERRADA', 'CANCELADA'].obs;


 Future<List<Cotizacion>> getCotizacion(String status) async {
   return await cotizacionProvider.findByStatus(status);
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
}

