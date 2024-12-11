import 'package:flutter/material.dart'; // Importa el paquete de Flutter para construir la interfaz gráfica
import 'package:get/get.dart'; // Importa Get para la gestión de estado y controladores
import 'package:maquinados_correa/src/pages/calidad/comprasHome/calidad_home_controller.dart'; // Importa el controlador de CalidadHomeController
import 'package:maquinados_correa/src/pages/calidad/orders/list/calidad_ot_list_page.dart'; // Importa la página CalidadOtListPage de la lista de órdenes de trabajo de calidad
import 'package:maquinados_correa/src/pages/calidad/tabla/calidad_tab_page.dart';  // Importa la página CalidadTabPage que muestra la tabla de calidad
import 'package:maquinados_correa/src/utils/custom_animated_bottom_bar.dart';  // Importa el widget CustomAnimatedBottomBar para personalizar la barra de navegación inferior

class CalidadHomePage extends StatelessWidget { // Define la clase CalidadHomePage, que extiende StatelessWidget
  CalidadHomeController con = Get.put(CalidadHomeController()); // Crea una instancia del controlador CalidadHomeControlller y la inicializa con Get.put

  @override
  Widget build(BuildContext context) {// Método principal de construcción de la interfaz
    return Scaffold( // Devuelve un Scaffold que estructura la página
        bottomNavigationBar: _bottomBar(), // Añade la barra de navegación inferior
        body: Obx(() => IndexedStack(  // Usa Obx para observar cambios en el índice de la pestaña activa
              index: con.indexTab.value,  // Índice que determina la pestaña activa
              children: [// Contiene las páginas para cada pestaña
                CalidadTabPage(),
                CalidadOtListPage()
              ],
            )
        )
    );
  }

  Widget _bottomBar() {  //Método para construir la barra de navegación inferior
    return Obx(() => CustomAnimatedBottomBar( // Obx para observar cambios en el índice seleccionado de la barra
          containerHeight: 45, // Altura del contenedor de la barra
          backgroundColor: Colors.grey, // Color de fondo de la barra
          showElevation: true, // Muestra una sombra en la barra
          itemCornerRadius: 24, // Radio de esquina de cada ítem de la barra
          curve: Curves.easeIn, // Curva de animación para el cambio de ítem
          selectedIndex: con.indexTab.value,  // Índice del ítem seleccionado
          onItemSelected: (index) => con.changeTab(index),  // Cambia la pestaña activa cuando se selecciona un ítem
          items: [  // Elementos de la barra de navegación inferior
            BottomNavyBarItem( // Primer ítem de la barra de navegación
                icon: Icon(Icons.home), // Icono de la pestaña
                title: Text('Home'),  // Titulo de la pestaña
                activeColor: Colors.white, // Color activo del ítem
                inactiveColor: Colors.black // Color inactivo del ítem
            ),
            BottomNavyBarItem( // Segundo ítem de la barra de navegación
                icon: Icon(Icons.list),  // Icono de la pestaña
                title: Text('Lista'),  // Titulo de la pestaña
                activeColor: Colors.white,  // Color activo del ítem
                inactiveColor: Colors.black  // Color inactivo del item
            ),
          ],
        ));
  }
}
