import 'package:flutter/material.dart';
import 'package:maquinados_correa/src/pages/calidad/orders/list/calidad_ot_list_controller.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/pages/ventas/cotizacion/create_cotizacion/create_cotizacion_page.dart';
import 'package:maquinados_correa/src/utils/custom_animated_bottom_bar.dart';


import '../../../profile/info/profile_info_page.dart';

class CalidadOtListPage extends StatelessWidget {
  CalidadOtListController con = Get.put(CalidadOtListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _bottomBar(),
        body:Obx(() => IndexedStack(
          index: con.indexTab.value,
          children:[
            CotizacionPage(),
            ProfileInfoPage()
          ],
        ))
    );
  }

  Widget _bottomBar(){
    return CustomAnimatedBottomBar(
      containerHeight: 70,
      backgroundColor: Colors.blue,
      showElevation: true,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      selectedIndex: con.indexTab.value,
      onItemSelected: (index) => con.changeTab(index), //cambia e valor segun el boton presionado en la barra
      items: [
        BottomNavyBarItem(
            icon: Icon(Icons.home),
            title:Text( 'Home'),
            activeColor: Colors.grey,
            inactiveColor: Colors.black
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.add),
            title:Text( 'Añadir'),
            activeColor: Colors.grey,
            inactiveColor: Colors.black
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.person),
            title:Text( 'Usuario'),
            activeColor: Colors.grey,
            inactiveColor: Colors.black
        ),
      ],
    );
  }
}