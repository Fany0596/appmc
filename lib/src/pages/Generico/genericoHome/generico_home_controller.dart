import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/pages/Generico/list/list_page.dart';
import 'package:maquinados_correa/src/pages/Generico/tab_compras/compras_tab_page.dart';
import 'package:maquinados_correa/src/pages/Generico/tab_tiempos/tab_tym_controller.dart';
import 'package:maquinados_correa/src/pages/Generico/tab_tiempos/tab_tym_page.dart';

class GenericoHomeController extends GetxController{

  var indexTab = 0.obs;

  List<Widget> pages = [
    ComprasTabPage2(),
    TabTymPage(),
    ListPage(),
  ];

  @override
  void onInit() {
    super.onInit();
    print("TymHomeController initialized");
  }

  void changeTab(int index){
    indexTab.value = index;
    updatePage(index);
  }
  void updatePage(int index) {
    // Re-create the page when the tab is changed to ensure it's refreshed
    switch (index) {
      case 0:
        pages[index] = ComprasTabPage2();
        break;
      case 1:
        pages[index] = TabTymPage();
        break;
    }
  }
  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); //Elimina el historial de las pantallas y regresa al login
  }
}