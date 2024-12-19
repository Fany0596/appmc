import 'package:flutter/material.dart';// Importa el paquete de flutter para construir la interfaz
import 'package:get/get.dart';  // Importa Get para la gestión de estado y controladores
import 'package:maquinados_correa/src/pages/compras/comprasHome/compras_home_controller.dart';  // Importa elcontrolador
import 'package:maquinados_correa/src/pages/compras/list/compras_oc_list_page.dart';  // Importa la pagina OcListPage
import 'package:maquinados_correa/src/pages/compras/orders/create_oc/create_oc_page.dart';  // Importa la pagina CreateOcPage
import 'package:maquinados_correa/src/pages/compras/tabla/compras_tab_page.dart';  // Importa la pagina ComprasTabPage
import 'package:maquinados_correa/src/utils/custom_animated_bottom_bar.dart';  // Importa el widget CustomAnimatedBottomBar

class ComprasHomePage extends StatelessWidget {  // Define la clase que extiende StatelessWidget
  ComprasHomeController con = Get.put(ComprasHomeController());  // Crea una instancia del controlador y la inicializa con Get.put

  @override
  Widget build(BuildContext context) {  // Metodo principal de construcción de la interfaz
    return Scaffold(  // Devuelve un scaffold que estructura la página
      bottomNavigationBar: _bottomBar(),  // Añande la barra de navegación inferior
      body: Obx(() => IndexedStack( // Usa Obx para observar cambios en el indice de la pestaña activa
            index: con.indexTab.value,  // Indice que determina la pestaña activa
            children: [ // Contiene las pàginas para cada pestaña
              ComprasTabPage(),
              ComprasOcListPage(),
              CombinedOcProductPage(),
            ],
          )
      ),
    );
  }

  Widget _bottomBar() {  // Método para construir la barra de navegación inferior
    return Obx(() => CustomAnimatedBottomBar(  // Obx para observar cambios en el indice seleccionado de la barra
          containerHeight: 55, // Altura del contenedor de la barra
          backgroundColor: Colors.grey,  // Color de fondo de la barra
          showElevation: true, // Muestra una sombra en la barra
          itemCornerRadius: 24,  // Radio de esquina de cada item de la barra
          curve: Curves.easeIn,  // Curva de animación para el cambio de item
          selectedIndex: con.indexTab.value,  // Ìndice del item seleccionado
          onItemSelected: (index) => con.changeTab(index),  // Cambia la pestaña activa cuando se selecciona un item
          items: [  // Elementos de la barra de navegación inferior
            BottomNavyBarItem(  // Primer item de la barra de navegación
              icon: Icon(Icons.home),  // Icono de la pestaña
              title: Text('Home'),  // Titulo de la pestaña
              activeColor: Colors.white, //Color activo del item
              inactiveColor: Colors.black,  // Color inactivo del item
            ),
            BottomNavyBarItem(  // Segundo item de la barra de navegación
              icon: Icon(Icons.list),  // Icono de la pestaña
              title: Text('Listado'),  // Titulo de la pestaña
              activeColor: Colors.white,  // Color activo del item
              inactiveColor: Colors.black,  // Color inactivo del item
            ),
            BottomNavyBarItem(  // Tercer item de la barra de navegacion
              icon: Icon(Icons.add),  // Icono de la pestaña
              title: Text('OC'),  // Titulo de la pestaña
              activeColor: Colors.white,  // Color activo del item
              inactiveColor: Colors.black,  // color inactivo del item
            ),
          ],
        )
    );
  }
}
