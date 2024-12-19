import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart'; // Importa Get para gestión de estado
import 'package:get_storage/get_storage.dart';  // Importa el paquete para almacenamiento
import 'package:maquinados_correa/src/models/cotizacion.dart'; // Importa el modelo cotización
import 'package:maquinados_correa/src/models/producto.dart';  // Importa el modelo producto
import 'package:maquinados_correa/src/models/user.dart';  // Importa el modelo user
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';  // Importa para obtener datos de cotizaciones desde el backend

class CalidadOtListController extends GetxController {  // Define el controlador que extiende GetxController para gestionar la lógica
  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;  // Define una variable observable de usuario obtenida desde el almacenamiento local
  CotizacionProvider cotizacionProvider = CotizacionProvider();  // Instancia del proveedor de cotizaciones
  List<String> estatus = <String>['EN PROCESO', 'SUSPENDIDO', 'SIG. PROCESO','RETRABAJO','RECHAZADO','LIBERADO','ENTREGADO',].obs;  // Lista de estatus posibles para los productos, observables para actualizar la UI automaticamente
  final ZoomDrawerController zoomDrawerController = ZoomDrawerController();

  RxList<Producto> allProducts = <Producto>[].obs;  // Lista observable de todos los productos de las cotizaciones
  RxList<Producto> filteredProducts = <Producto>[].obs;  // Lista observable de productos filtraos basada en criterios de busqueda y estado
  var searchQuery = ''.obs;  // Variable observable para la consulta de búsqueda
  var selectedStatus = 'EN ESPERA'.obs;  // Variable observable para el estatus seleccionado de productos

  @override  // Método que se ejecuta cuando el controlador es inicializado
  void onInit() {
    super.onInit();
    getProductsFromCotizaciones('GENERADA');  // Llama a la funcion para obtener productos de la cotización con status 'GENERADA'
    searchQuery.listen((query) {  // Escucha cambios en la consulta de búsqueda y filtra los productos
      filterProducts();
    });
    selectedStatus.listen((status) {  // Escucha cambios en el estatus seleccionado
      filterProducts();  // Filtra los productos
    });
  }

  Future<void> getProductsFromCotizaciones(String status) async {  // Método para obtener productos desde las cotizaciones filtradas por un status especifico
    List<Cotizacion> cotizaciones = await cotizacionProvider.findByStatus(status);  // Obtiene las cotizaciones que coinciden con el status especifico
    List<Producto> products = [];  // Crea una lista temporal de productos
    for (var cotizacion in cotizaciones) { // Recorre cada cotización
      products.addAll(  // Añade los productos que no esten en estatus 'CANCELADO'
        cotizacion.producto!.where((producto) => producto.estatus != 'CANCELADO').toList(),
      );
    }
    allProducts.value = products;  // Asigna la lista e productos a la lista observable 'allProducts' y aplica el filtro inicial
    filterProducts();
  }

  void filterProducts() {  // Método para filtrar los productos según el estatus seleccionado y la consulta de busqueda
    var filteredByStatus = allProducts.where((producto) => producto.estatus == selectedStatus.value).toList();  // Filtra los productos segun el estatus seleccionado
    if (searchQuery.value.isEmpty) {  // Si no hay consulta de busqueda, asigna los productos filtrados por estatus a filteredProducts
      filteredProducts.value = filteredByStatus;
    } else { // Si hay consulta de busqueda
      filteredProducts.value = filteredByStatus.where((producto) {  // Filtra los productos por estatus
        return producto.articulo!.toLowerCase().contains(searchQuery.value.toLowerCase()) || // Y filtra por nombre o número de OT
            producto.ot!.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  void updateProducts() {  // Método para actualizar la lista de prodcutos obteniendolos de nuevo de las cotizaciones
    getProductsFromCotizaciones('GENERADA');
  }

  void goToOt(Producto producto) {  // Método para navegar a la página de detalle del prodcuto
    print('Producto seleccionado: $producto');  // Imprime el producto seleccionado
    Get.toNamed('/calidad/orders/liberacion', arguments: {'producto': producto.toJson()});  // Envia en argumento el producto seleccionado
  }

  void signOut() {  // Método para cerrar sesión
    GetStorage().remove('user'); // Elimina el historial de las pantallas y regresa al login
    Get.offNamedUntil('/', (route) => false); // Navega al login y elimina el historial de navegación
  }

  void goToPerfilPage() {  // Método para navegar a la página de perfil el usuario
    Get.toNamed('/profile/info');
  }

  void goToRoles() {  // Método para navegar a la página de selección de roles
    Get.offNamedUntil('/roles', (route) => false);
  }

  void reloadPage() {  // Método para recargar la página
    onInit();  // Invoca a onInit y actualiza el controlador
    update();  // Actualizar el controlador
  }
}