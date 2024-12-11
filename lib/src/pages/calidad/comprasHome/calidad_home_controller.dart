import 'package:flutter/cupertino.dart';  // Importa el paquete Cupertino de Flutter para elementos visuales estilo iOS
import 'package:get/get.dart';  // Importa Get para la gestión de estado y controladores
import 'package:get_storage/get_storage.dart';  // Importa GetStorage para la persistencia de datos en almacenamiento local
import 'package:maquinados_correa/src/pages/tym/list/tym_ot_list_controller.dart';  // Importa el controlador TymOtListController
import 'package:maquinados_correa/src/pages/tym/tabla/tym_tab_page.dart';  // Importa la página TymTabPage que muestra la tabla de Tym (Tiempo y Materiales)
import 'package:maquinados_correa/src/pages/tym/list/tym_ot_list_page.dart';  // Importa la página TymOtListPage que muestra la lista de órdenes de trabajo de Tym

class CalidadHomeController extends GetxController {  // Define la clase CalidadHomeController que extiende GetxController para gestionar estado y logica
  var indexTab = 0.obs;  // Variable observable que almacena el índice actual de la pestaña seleccionada

  List<Widget> pages = [  // Lista de widgets que contiene las páginas para cada pestaña
    TymTabPage(),  // Página de tlabla te TyM
    TymOtListPage(),  // Pagina de las ordenes de trabajo de TyM
  ];

  @override
  void onInit() {  // Método que se ejecuta al inicializar el controlador
    super.onInit();
    print("CalidadHomeController initialized");  // Imprime un mensaje en la consola al inicializar el controlador
  }

  void changeTab(int index) {  // Método para cambiar el indice de la pestaña activa
    indexTab.value = index;  //Actualiza el valor de indexTab al nuevo indice de pestaña seleccionado
    updatePage(index);  //Llama al método updatePage para actualizar la página correspondiente
  }

  void updatePage(int index) {  // Método para recrear la página seleccionada y asegurar que se refresque
    switch (index) {  // Revisa el índice para determinar qué página se debe actualizar
      case 0:
        pages[index] = TymTabPage(); // Si el indice es 0, recrea TymTabPage
        break;
      case 1:
        pages[index] = TymOtListPage();  // si el índice es 1, recrea TymOtListPage y actualiza los productos
        Get.find<TymOtListController>()
            .updateProducts(); // Llama a la actualización de productos a traves del controlador TymOtListController
        break;
    }
  }

  void signOut() {  // Método para cerrar sesión del usuario
    GetStorage().remove('user');  // Elimina el dato 'user' alamacenado en GetStorage
    Get.offNamedUntil(  // Redirige al usuario a la pantalla de inicio de sesión eliminando el historial de navegación
        '/',
        (route) => false);
  }
}
