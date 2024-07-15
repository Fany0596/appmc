import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/pages/Generico/genericoHome/generico_home_controller.dart';
import 'package:maquinados_correa/src/pages/Generico/list/list_page.dart';
import 'package:maquinados_correa/src/utils/custom_animated_bottom_bar.dart';
import '../../produccion/orders/list/produccion_ot_list_page.dart';
import '../../profile/info/profile_info_page.dart';


class GenericoHomePage extends StatelessWidget {
  GenericoHomeController con = Get.put(GenericoHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _bottomBar(),
        body:Obx(() => IndexedStack(
          index: con.indexTab.value,
          children:[
            ListPage(),
            ProduccionOtListPage(),
            ProfileInfoPage()
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
            icon: Icon(Icons.create),
            title:Text( 'Crear'),
            activeColor: Colors.white,
            inactiveColor: Colors.black
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.add),
            title:Text( 'Añadir'),
            activeColor: Colors.white,
            inactiveColor: Colors.black
        ),
      ],
    ));
  }
}