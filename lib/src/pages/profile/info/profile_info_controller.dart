import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../models/user.dart';

class ProfileInfoController extends GetxController {

  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); //Elimina el historial de las pantallas y regresa al login
  }

  void goToProfileUpdate() {
    Get.toNamed('/profile/info/update');
  }
  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }
}
