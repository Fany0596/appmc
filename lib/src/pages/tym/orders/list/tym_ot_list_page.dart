import 'package:flutter/material.dart';
import 'package:maquinados_correa/src/pages/tym/orders/list/tym_ot_list_controller.dart';
import 'package:get/get.dart';

import '../../../../utils/custom_animated_bottom_bar.dart';
import '../../../produccion/orders/list/produccion_ot_list_page.dart';
import '../../../profile/info/profile_info_page.dart';

class TiemposOtListPage extends StatelessWidget {
  TiemposOtListController con = Get.put(TiemposOtListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _bottomBar(),
        body:Obx(() => IndexedStack(
          index: con.indexTab.value,
          children:[
            ProduccionOtListPage(),
            ProfileInfoPage()
          ],
        ))
    );
  }
  Widget _bottomBar(){
    return Obx(() => CustomAnimatedBottomBar(
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
            icon: Icon(Icons.add),
            title:Text( 'Añadir'),
            activeColor: Colors.white,
            inactiveColor: Colors.black
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.person),
            title:Text( 'Usuario'),
            activeColor: Colors.white,
            inactiveColor: Colors.black
        ),
      ],
    ));
  }
}
