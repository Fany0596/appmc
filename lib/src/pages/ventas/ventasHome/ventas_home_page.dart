import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/pages/ventas/cotizacion/create_producto/create_producto_page.dart';
import 'package:maquinados_correa/src/pages/ventas/newClient/new_client_page.dart';
import 'package:maquinados_correa/src/pages/ventas/newVendedor/new_vendedor_page.dart';
import 'package:maquinados_correa/src/pages/ventas/orders/list/ventas_oc_list_page.dart';
import 'package:maquinados_correa/src/pages/ventas/tabla/ventas_tab_page.dart';
import 'package:maquinados_correa/src/pages/ventas/ventasHome/ventas_home_controller.dart';
import 'package:maquinados_correa/src/utils/custom_animated_bottom_bar.dart';



import '../../produccion/orders/list/produccion_ot_list_page.dart';
import '../../profile/info/profile_info_page.dart';
import '../cotizacion/create_cotizacion/create_cotizacion_page.dart';


class VentasHomePage extends StatelessWidget {
  VentasHomeController con = Get.put(VentasHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _bottomBar(),
        body:Obx(() => IndexedStack(
          index: con.indexTab.value,
          children:[
            VentasTabPage(),
            VentasOcListPage(),
            CotizacionPage(),
            ProductoPage(),
            //ProfileInfoPage(),
            //NewClientPage(),
           // VendedoresPage()
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
            title:Text( 'Listado'),
            activeColor: Colors.white,
            inactiveColor: Colors.black
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.create),
            title:Text( 'Cotización'),
            activeColor: Colors.white,
            inactiveColor: Colors.black
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.add),
            title:Text( 'Producto'),
            activeColor: Colors.white,
            inactiveColor: Colors.black
        ),
      ],
    ));
  }
}