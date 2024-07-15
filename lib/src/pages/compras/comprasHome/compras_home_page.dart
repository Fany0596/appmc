import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/pages/compras/comprasHome/compras_home_controller.dart';
import 'package:maquinados_correa/src/pages/compras/list/compras_oc_list_page.dart';
import 'package:maquinados_correa/src/pages/compras/orders/list/compras_page.dart';
import 'package:maquinados_correa/src/pages/compras/orders/new_order/create_product_page.dart';
import 'package:maquinados_correa/src/pages/compras/orders/new_order/oc/create_oc_page.dart';
import 'package:maquinados_correa/src/pages/compras/tabla/compras_tab_page.dart';
import 'package:maquinados_correa/src/utils/custom_animated_bottom_bar.dart';

class ComprasHomePage extends StatelessWidget {
  ComprasHomeController con = Get.put(ComprasHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomBar(),
      body: Obx(() => IndexedStack(
        index: con.indexTab.value,
        children: [
          ComprasTabPage(),
          ComprasOcListPage(),
          OcPage(),
          ProductPage(),
        ],
      )),
    );
  }

  Widget _bottomBar() {
    return Obx(() => CustomAnimatedBottomBar(
      containerHeight: 70,
      backgroundColor: Colors.grey,
      showElevation: true,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      selectedIndex: con.indexTab.value,
      onItemSelected: (index) => con.changeTab(index),
      items: [
        BottomNavyBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
          activeColor: Colors.white,
          inactiveColor: Colors.black,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.list),
          title: Text('Listado'),
          activeColor: Colors.white,
          inactiveColor: Colors.black,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.create),
          title: Text('Crear'),
          activeColor: Colors.white,
          inactiveColor: Colors.black,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.add),
          title: Text('Añadir'),
          activeColor: Colors.white,
          inactiveColor: Colors.black,
        ),
      ],
    ));
  }
}