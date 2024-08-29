import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/user.dart';
import '../../models/Rol.dart';

class RolesController extends GetxController {

  User user = User.fromJson(GetStorage().read('user') ?? {}); //traeralos roles asifnados

void goToPageRol(Rol rol){
  Get.offNamedUntil(rol.route ?? '', (route) => false);
}
  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); //Elimina el historial de las pantallas y regresa al login
  }
  void goToPerfilPage(){
    Get.toNamed('/profile/info');
  }
}