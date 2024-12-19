import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';

class TymOtListController extends GetxController {
  final ZoomDrawerController zoomDrawerController = ZoomDrawerController();
  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  CotizacionProvider cotizacionProvider = CotizacionProvider();
  List<String> estatus = <String>['EN ESPERA', 'EN PROCESO', 'SUSPENDIDO', 'SIG. PROCESO', 'RETRABAJO','RECHAZADO', 'LIBERADO', 'ENTREGADO'].obs;

  RxList<Producto> allProducts = <Producto>[].obs;
  RxList<Producto> filteredProducts = <Producto>[].obs;
  var searchQuery = ''.obs;
  var selectedStatus = 'EN ESPERA'.obs;

  @override
  void onInit() {
    super.onInit();
    getProductsFromCotizaciones('GENERADA');
    searchQuery.listen((query) {
      filterProducts();
    });
    selectedStatus.listen((status) {
      filterProducts();
    });
  }

  Future<void> getProductsFromCotizaciones(String status) async {
    List<Cotizacion> cotizaciones = await cotizacionProvider.findByStatus(status);
    List<Producto> products = [];
    for (var cotizacion in cotizaciones) {
      products.addAll(
        cotizacion.producto!.where((producto) => producto.estatus != 'CANCELADO').toList(),
      );
    }
    allProducts.value = products;
    filterProducts();
  }

  void filterProducts() {
    var filteredByStatus = allProducts.where((producto) => producto.estatus == selectedStatus.value).toList();
    if (searchQuery.value.isEmpty) {
      filteredProducts.value = filteredByStatus;
    } else {
      filteredProducts.value = filteredByStatus.where((producto) {
        return producto.articulo!.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            producto.ot!.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  void updateProducts() {
    getProductsFromCotizaciones('GENERADA');
  }

  void goToOt(Producto producto) {
    print('Producto seleccionado: $producto');
    Get.toNamed('/tym/list/tiempos', arguments: {'producto': producto.toJson()});
  }

  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); // Elimina el historial de las pantallas y regresa al login
  }

  void goToPerfilPage() {
    Get.toNamed('/profile/info');
  }

  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }

  void goToDetalles(Cotizacion cotizacion) {
    Get.toNamed('/produccion/orders/detalles_produccion', arguments: {
      'cotizacion': cotizacion.toJson()
    });
  }

  void goToRegisterPage() {
    Get.toNamed('/tym/newOperador');
  }
  void reloadPage() {
    onInit();
    update();         // Actualizar el controlador
  }
}
