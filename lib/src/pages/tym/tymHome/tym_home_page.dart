import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/pages/tym/list/tym_ot_list_page.dart';
import 'package:maquinados_correa/src/pages/tym/tabla/tym_tab_page.dart';
import 'package:maquinados_correa/src/pages/tym/tymHome/tym_home_controller.dart';
import 'package:maquinados_correa/src/utils/custom_animated_bottom_bar.dart';
import '../../profile/info/profile_info_page.dart';


class TymHomePage extends StatelessWidget {
  TymHomeController con = Get.put(TymHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _bottomBar(),
        body:Obx(() => IndexedStack(
          index: con.indexTab.value,
          children:[
            TymTabPage(),
            TymOtListPage()
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