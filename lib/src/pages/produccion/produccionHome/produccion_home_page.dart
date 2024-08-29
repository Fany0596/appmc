import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/pages/produccion/produccionHome/produccion_home_controller.dart';
import 'package:maquinados_correa/src/pages/produccion/tabla/produccion_tab_page.dart';
import 'package:maquinados_correa/src/pages/ventas/cotizacion/create_cotizacion/create_cotizacion_page.dart';
import 'package:maquinados_correa/src/utils/custom_animated_bottom_bar.dart';
import '../../produccion/orders/list/produccion_ot_list_page.dart';
import '../../profile/info/profile_info_page.dart';


class ProduccionHomePage extends StatelessWidget {
  ProduccionHomeController con = Get.put(ProduccionHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _bottomBar(),
        body:Obx(() => IndexedStack(
          index: con.indexTab.value,
          children:[
            ProduccionTabPage(),
            ProduccionOtListPage()
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