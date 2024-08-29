import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';

class ProduccionOtListController extends GetxController {
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
  void reloadPage() {
    onInit();
    update();         // Actualizar el controlador
  }
  Future<void> _loadCotizaciones() async {
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
}