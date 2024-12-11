import 'package:get/get.dart';  // Importa Get para la gestioin de estados y controladores
import 'package:get_storage/get_storage.dart'; // Importa GetStorage para la persistencia de datos en almacenamiento local

class ComprasHomeController extends GetxController {  // Define la clase que extiende GetxController para gestionar estado y logica
  var indexTab = 0.obs;  // Variable observable que almacena el indice actual de la pestaña seleccionada

  void changeTab(int index) {  // Metodo para cambiar el indice de la pestaña activa
    indexTab.value = index;  // Actualiza el valor de indexTab al nuevo indice de pestaña seleccionada
  }

  void signOut() {  // Metodo para cerrar sesión del usuario
    GetStorage().remove('user');  // Elimina el dato user almacenado en GetStorage
    Get.offNamedUntil(  // Redirige al usuario a la pantalla de inicio de sesion eliminando el historial de navegación
        '/',
        (route) => false);
  }
}
