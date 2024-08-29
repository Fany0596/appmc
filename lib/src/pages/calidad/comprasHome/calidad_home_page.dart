import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/pages/calidad/comprasHome/calidad_home_controller.dart';
import 'package:maquinados_correa/src/pages/calidad/orders/list/calidad_ot_list_page.dart';
import 'package:maquinados_correa/src/pages/calidad/tabla/calidad_tab_page.dart';
import 'package:maquinados_correa/src/pages/tym/list/tym_ot_list_page.dart';
import 'package:maquinados_correa/src/pages/tym/tabla/tym_tab_page.dart';
import 'package:maquinados_correa/src/utils/custom_animated_bottom_bar.dart';

class CalidadHomePage extends StatelessWidget {
  CalidadHomeController con = Get.put(CalidadHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _bottomBar(),
        body:Obx(() => IndexedStack(
          index: con.indexTab.value,
          children:[
            CalidadTabPage(),
            CalidadOtListPage()
          ],
        ))
    );
  }

  Widget _bottomBar(){
    return Obx (() => CustomAnimatedBottomBar(
      containerHeight: 70,
      backgroundColor: Colors.grey,
      showElevation: true,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      selectedIndex: con.indexTab.value,
      onItemSelected: (index) => con.changeTab(index), //cambia e valor segun el boton presionado en la barra
      items: [
        BottomNavyBarItem(
            icon: Icon(Icons.home),
            title:Text( 'Home'),
            activeColor: Colors.white,
            inactiveColor: Colors.black
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.list),
            title:Text( 'Lista'),
            activeColor: Colors.white,
            inactiveColor: Colors.black
        ),
      ],
    ));
  }
}