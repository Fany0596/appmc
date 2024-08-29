import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/pages/tym/list/tym_ot_list_controller.dart';
import 'package:maquinados_correa/src/pages/tym/tabla/tym_tab_page.dart';
import 'package:maquinados_correa/src/pages/tym/list/tym_ot_list_page.dart';

class TymHomeController extends GetxController {
  var indexTab = 0.obs;

  List<Widget> pages = [
    TymTabPage(),
    TymOtListPage(),
  ];

  @override
  void onInit() {
    super.onInit();
    print("TymHomeController initialized");
  }

  void changeTab(int index) {
    indexTab.value = index;
    updatePage(index);
  }

  void updatePage(int index) {
    // Re-create the page when the tab is changed to ensure it's refreshed
    switch (index) {
      case 0:
        pages[index] = TymTabPage();
        break;
      case 1:
        pages[index] = TymOtListPage();
        Get.find<TymOtListController>().updateProducts(); // Llama a la actualización de productos
        break;
    }
  }

  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); // Elimina el historial de las pantallas y regresa al login
  }
}
