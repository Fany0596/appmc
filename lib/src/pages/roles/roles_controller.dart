import 'package:get/get.dart'; // Importa GetX para la gestión de estados y navegación
import 'package:get_storage/get_storage.dart'; // Importa GetStorage para almacenamiento persistente
import 'package:maquinados_correa/src/models/user.dart'; // Importa el modelo de usuario
import '../../models/Rol.dart'; // Importa el modelo de Rol

// Controlador para la gestión de roles de usuario
class RolesController extends GetxController {
  // Crea una instancia de User, inicializándola con los datos almacenados en 'user' o un objeto vacío
  User user = User.fromJson(
      GetStorage().read('user') ?? {}  // Obtiene los roles asignados del almacenamiento local
  );

  // Navega a la página asignada al rol especificado
  void goToPageRol(Rol rol) {
    Get.offNamedUntil(rol.route ?? '', (route) => false);  // Navega a la ruta del rol y elimina el historial de pantallas previas
  }

  // Método para cerrar sesión
  void signOut() {
    GetStorage().remove('user');  // Elimina los datos del usuario del almacenamiento local
    Get.offNamedUntil(
        '/',
        (route) =>
            false); // Navega a la pantalla de inicio de sesión y elimina el historial de pantallas
  }

  // Navega a la página de perfil
  void goToPerfilPage() {
    Get.toNamed('/profile/info');  // Navega a la ruta de perfil de usuario
  }
}
