import 'package:flutter/material.dart'; // Importa el paquete para la interfaz del usuario
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:maquinados_correa/src/models/producto.dart';  // Importa el modelo producto
import 'package:maquinados_correa/src/pages/calidad/orders/list/calidad_ot_list_controller.dart';  // Importa el controlador
import 'package:get/get.dart';  // Importa Get para gestión de estado y navegación
import 'package:maquinados_correa/src/widgets/no_data_widget.dart';  // Importa el widget para mostrar mensaje cuando no hay datos

class CalidadOtListPage extends StatelessWidget {  // Define la clase que se extiende a StatelessWidget
  CalidadOtListController con = Get.put(CalidadOtListController()); // Crea una instancia del controlador usando Get
  final RxBool isHoveredPerfil = false.obs;
  final RxBool isHoveredRoles = false.obs;
  final RxBool isHoveredSalir = false.obs;

  @override
  Widget build(BuildContext context) {
    // Determinar el ancho del drawer basado en el ancho de la pantalla
    double drawerWidth = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.45
        : MediaQuery.of(context).size.width * 0.14;


    return Obx(() => ZoomDrawer(
      controller: con.zoomDrawerController,
      menuScreen: _buildMenuScreen(context),
      mainScreen: _buildMainScreen(context),
      mainScreenScale: 0.0,
      slideWidth: drawerWidth,
      menuScreenWidth: drawerWidth,
      borderRadius: 0,
      showShadow: false,
      angle: 0.0,
      menuBackgroundColor: Colors.grey,
      mainScreenTapClose: true,
    ));
  }

  Widget _buildMenuScreen(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.75
        : MediaQuery.of(context).size.width * 0.25;
    final screenHeight = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.75
        : MediaQuery.of(context).size.width * 0.25;
    final containerHeight = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.48
        : MediaQuery.of(context).size.width * 0.145;
    final textHeight = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.48
        : MediaQuery.of(context).size.width * 0.11;
    return Scaffold(
        backgroundColor: Colors.grey,
        body: Container(
            width: double.infinity,
            height:
            MediaQuery.of(context).size.height, // Altura total de la pantalla
            child: Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                              children: [
                                Container(
                                  height: containerHeight,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/img/fondo2.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.topCenter,
                                        margin: EdgeInsets.only(top: screenHeight * 0.02),
                                        child: CircleAvatar(
                                          backgroundImage: con.user.value.image != null
                                              ? NetworkImage(con.user.value.image!)
                                              : AssetImage('assets/img/LOGO1.png')
                                          as ImageProvider,
                                          radius: screenWidth * 0.2,
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10, bottom: 0),
                                        child: Text(
                                          '${con.user.value.name ?? ''}  ${con.user.value.lastname}',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.05,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 1, bottom: 0),
                                        child: Text(
                                          '${con.user.value.email ?? ''}',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Opciones del menú
                                MouseRegion(
                                  onEnter: (_) => isHoveredPerfil.value = true,
                                  onExit: (_) => isHoveredPerfil.value = false,
                                  child: GestureDetector(
                                    onTap: () => con.goToPerfilPage(),
                                    child: Obx(() => Container(
                                      margin:
                                      EdgeInsets.only(top: screenHeight * 0.05, left: 1),
                                      padding: EdgeInsets.all(screenWidth * 0.009),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: isHoveredPerfil.value
                                            ? Colors.blueGrey
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width: 15),
                                              Icon(
                                                Icons.person,
                                                size: textHeight * 0.15,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 20),
                                              Text(
                                                'Perfil',
                                                style: TextStyle(
                                                  fontSize: textHeight * 0.09,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                                  ),
                                ),
                              ]
                          )
                      )
                  ),
                  // Botones en la parte inferior
                  Container(
                    decoration: BoxDecoration(
                        border: BorderDirectional(
                            top: BorderSide(
                              width: 2,
                              color: Color.fromARGB(070, 080, 080, 600),
                            ))),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    // Espaciado alrededor de los botones
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MouseRegion(
                          onEnter: (_) => isHoveredRoles.value = true,
                          onExit: (_) => isHoveredRoles.value = false,
                          child:GestureDetector(
                            onTap: () => con.goToRoles(),
                            child: Obx(() => Container(
                              padding: EdgeInsets.all(screenWidth * 0.009),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isHoveredRoles.value
                                    ? Colors.blueGrey
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(width: 15),
                                      Icon(
                                        Icons.supervised_user_circle,
                                        //size: textHeight * 0.15,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 20),
                                      Text(
                                        'Roles',
                                        style: TextStyle(
                                          fontSize: textHeight * 0.09,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ),

                          ),
                        ),
                        MouseRegion(
                          onEnter: (_) => isHoveredSalir.value = true,
                          onExit: (_) => isHoveredSalir.value = false,
                          child:GestureDetector(
                            onTap: () => con.signOut(),
                            child: Obx(() => Container(
                              padding: EdgeInsets.all(screenWidth * 0.009),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isHoveredSalir.value
                                    ? Colors.blueGrey
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(width: 15),
                                      Icon(
                                        Icons.output,
                                        //size: textHeight * 0.15,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 20),
                                      Text(
                                        'Salir',
                                        style: TextStyle(
                                          fontSize: textHeight * 0.09,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ),

                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ]
            )
        )
    );
  }

  Widget _buildMainScreen(BuildContext context) {
    return DefaultTabController(
      length: con.estatus.length,
      child: Scaffold(
        appBar: AppBar( // Define el titulo de la barra de aplicaciones
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => con.zoomDrawerController.toggle?.call(),
          ),
          title: Row(  // Ordena horizontalmende los elementos
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Alineación de los elementos
            children: [
              _encabezado(context),  // Muestra el encabezado
              _buttonReload(),  // Muestra el botón de recarga
            ],
          ),
          bottom: TabBar(
            isScrollable: true,  // Permite desplazar las pestañas
            indicatorColor: Colors.grey, // Color de la pestaña seleccionada
            labelColor: Colors.white,  // Color de texto de la pestaña seleccionada
            unselectedLabelColor: Colors.black,  // Color de texto de pestaña no seleccionada
            onTap: (index) {
              con.selectedStatus.value = con.estatus[index];  // Cambia el estatud seleccionado al tocar una pestaña
            },
            tabs: con.estatus
                .map((estatus) => Tab(child: Text(estatus))) // Crea una pestaña con cada estatus
                .toList(),
          ),
        ),
        body: Column(  // Columna del cuerpo de la página
          children: [
            _buildSearchBar(),  // Widget de la barra de busqueda
            Expanded(
              child: TabBarView(
                children: con.estatus.map((estatus) {  // Muestra una vista por cada pestaña
                  return Obx(() {
                    if (con.filteredProducts.isEmpty) {  // Verifica si hay productos filtrados
                      return Center(
                          child: NoDataWidget(text: 'No hay productos')  // Muestra mensaje si no hay productos
                      );
                    } else {
                      return ListView.builder(  // Crea una lista de productos filtrados
                        itemCount: con.filteredProducts.length,  // Número de productos filtrados
                        itemBuilder: (_, index) {
                          return _cardProduct(con.filteredProducts[index]); // Tarjeta de producto filtrado
                        },
                      );
                    }
                  });
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {  // Widget para la barra buscadora
    return Padding(
      padding: const EdgeInsets.all(8.0),  // Define el espacio alrededor
      child: TextField(
        onChanged: (value) => con.searchQuery.value = value,  // Actualiza la consulta de búsqueda
        decoration: InputDecoration(  // Decoración de la barra
          hintText: 'Buscar por nombre o OT',  // Texto de sugerencia
          prefixIcon: Icon(Icons.search),  // Icono de busqueda
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),  // Borde redondeado
          ),
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {  // Encabezado con logo
    return Container(  // Contenedor del encabezado
      child: Image.asset(
        'assets/img/LOGO1.png',  // Ruta de la imagen de logo
        width: 55, // Ancho de imagen
        height: 55, // Alto de imagen
      ),
    );
  }

  Widget _cardProduct(Producto producto) {  //Widget de la tarjeta del producto
    return GestureDetector(
      onTap: () => con.goToOt(producto),  // Navega a los detalles del producto
      child: Card(
        elevation: 3.0,  // Sombra de la tarjeta
        color: Colors.white,  // Color de fondo
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),  // Borde redondeado
        ),
        child: Column(  // Columna para los elementos de la tarjeta
          crossAxisAlignment: CrossAxisAlignment.stretch,  // Alineación de los elementos
          children: [
            Container(
              height: 30,  // Altura del encabezado de la tarjeta
              decoration: BoxDecoration(
                color: Colors.grey,  // Color de fondo
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),  // Esquina superior izquierda redondeada
                  topRight: Radius.circular(15),  // Esquina superior derecha redondeada
                ),
              ),
              child: Center(
                child: Text(
                  '${producto.articulo}',  // Nombre del producto
                  style: TextStyle(  // Estilo del texto
                    fontWeight: FontWeight.bold,  // Texto en negrita
                    fontSize: 15,  // Tamaño de fuente
                  ),
                ),
              ),
            ),
            ListTile(  // Lista de los datos del producto
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Alineación de los datos del producto
                children: [
                  Text('OT: ${producto.ot ?? ''}'),  // Número de OT
                  Text('Cantidad: ${producto.cantidad.toString()}'),  // Cantidad del producto
                  Text('Status: ${producto.estatus ?? ''}'),  // Estatus del producto
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer() { // Widget del menu lateral
    return Drawer(
      child: Container(  // Contenedor del drawer
        color: Colors.white60,  // Color de fondo
        child: SingleChildScrollView(  // Se hace desplazable verticalmente
          child: Column(  // Columna para ordenar los elementos
            children: [
              Container(  // Contenedor e la imagen de usuario
                margin: EdgeInsets.only(top: 57),  // Margen superior
                child: CircleAvatar(
                  backgroundImage: con.user.value.image != null
                      ? NetworkImage(con.user.value.image!)  // Muestra la imagen del usuario si tiene una
                      : AssetImage('assets/img/LOGO1.png') as ImageProvider,  // Muestra la imagen predeterminada si el usuario no tiene una
                  radius: 75,  // Tamaño del cirdulo donde se muestra la imagen
                ),
              ),
              Container(  // Contenedor del nombe de usuario
                margin: EdgeInsets.only(top: 10), // Margen superior
                child: Text(
                  '${con.user.value.name ?? ''}  ${con.user.value.lastname}',  // Nombre y apellido
                  style: TextStyle(  // Estilo de texto
                    fontSize: 16,  // Tamaño de fuente
                    color: Colors.black,  // Color de texto
                    fontWeight: FontWeight.bold,  // Texto en negritas
                  ),
                ),
              ),
              GestureDetector(  // Detecta el toque en el contenedor
                onTap: () => con.goToPerfilPage(),  // Navega a la página de perfil
                child: Container(
                  margin: EdgeInsets.only(top: 40), // Margen superior
                  padding: EdgeInsets.all(10), // Espacio interior
                  width: double.infinity,  // Ancho completo
                  color: Colors.white,  // Color de fondo
                  child: Text(  // Texto del bóton
                    'Perfil',
                    style: TextStyle(  // Estilo del texto
                      fontSize: 13,  // Tamaño de fuente
                      color: Colors.black,  // Color de texto
                      fontWeight: FontWeight.bold,  // Texto en negritas
                    ),
                  ),
                ),
              ),
              Row(  // Fila para mostrar los botones
                children: [
                  Container( // Contenedor para bóton de roles
                    margin: EdgeInsets.only(top: 20, left: 20),  // Márgen superior e izquierdo
                    child: IconButton( // Bóton de icono
                      onPressed: () => con.goToRoles(),  // Navega a la pagina de roles
                      icon: Icon(
                        Icons.supervised_user_circle,  // Icono
                        color: Colors.black,  // Color del icono
                        size: 30,  // Tamaño del icono
                      ),
                    ),
                  ),
                  Container(  // Contenedor para bóton de cerrar sesión
                    margin: EdgeInsets.only(top: 20, left: 160),  // Margen superior e izquierdo
                    child: IconButton(  // Bóton de icono
                      onPressed: () => con.signOut(),  // Cierra sesión
                      icon: Icon(
                        Icons.power_settings_new,  // Icono
                        color: Colors.black,  // Color de icono
                        size: 30,  // Tamaño del icono
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttonReload() {  // Bóton de recargar la página
    return SafeArea( // Deja espacio de la barra del telefono
      child: Container(
        alignment: Alignment.topRight,  // Alineación superior derecha
        margin: EdgeInsets.only(right: 20),  // Margen derecho
        child: IconButton(  // Bóton de icono
            onPressed: () => con.reloadPage(),  // Recarga la página
            icon: Icon(
              Icons.refresh,  // Icono
              color: Colors.white,  // Color del icono
              size: 30,  // Tamaño del icono
            )),
      ),
    );
  }
}
