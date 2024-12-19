import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';

class ListController extends GetxController{

  final ZoomDrawerController zoomDrawerController = ZoomDrawerController();

  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  List<String> status = <String>['CONFIRMADA', 'GENERADA', 'CERRADA'].obs;
  var cotizaciones = <Cotizacion>[].obs;
  var filteredCotizaciones = <Cotizacion>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCotizaciones();
  }

  Future<void> _loadCotizaciones() async {
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
   Get.toNamed('/generico/detalles', arguments: {
     'cotizacion': cotizacion.toJson()
   });
  }
}

