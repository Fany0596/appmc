import 'package:flutter/material.dart'; // Importa Flutter para construir la interfaz
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart'; // Importa GetX para la gestión de estados y navegación
import 'package:maquinados_correa/src/pages/roles/roles_controller.dart'; // Importa el controlador de roles
import 'package:maquinados_correa/src/models/Rol.dart'; // Importa el modelo de Rol
import 'package:cached_network_image/cached_network_image.dart'; // Importa para cargar imágenes de la red con caché

// Define la página de roles de usuario
class RolesPage extends StatelessWidget {
  // Crea una instancia del controlador RolesController y la inicializa con Get.put
  RolesController con = Get.put(RolesController());
  final RxBool isHoveredPerfil = false.obs; // Estado para el hover del botón "Perfil"
  final RxBool isHoveredRoles = false.obs;
  final RxBool isHoveredSalir = false.obs;

  // Método principal de construcción de la interfaz
  @override
  Widget build(BuildContext context) {
    // Determinar el ancho del drawer basado en el ancho de la pantalla
    double drawerWidth = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width *
        0.45 // Celulares (ancho menor a 600)
        : MediaQuery.of(context).size.width * 0.14; // Pantallas más grandes

    return  ZoomDrawer(
      controller: con.zoomDrawerController,
      menuScreen: _buildMenuScreen(context),
      mainScreen: _buildMainScreen(context),
      mainScreenScale: 0.0,
      slideWidth: drawerWidth,
      // Usar el ancho calculado
      menuScreenWidth: drawerWidth,
      // Mismo ancho para el menú
      borderRadius: 0,
      showShadow: false,
      angle: 0.0,
      menuBackgroundColor: Colors.grey,
      mainScreenTapClose: true,
    );
  }

  Widget _buildMenuScreen(BuildContext context) {
    // Obtener el tamaño de la pantalla
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
                    child: Column(children: [
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
                                backgroundImage: con.user.image != null
                                    ? NetworkImage(con.user.image!)
                                    : AssetImage('assets/img/LOGO1.png')
                                as ImageProvider,
                                radius: screenWidth * 0.2,
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10, bottom: 0),
                              child: Text(
                                '${con.user.name ?? ''}  ${con.user.lastname}',
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
                                '${con.user.email ?? ''}',
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
                    ]))),

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
                    onEnter: (_) => isHoveredSalir.value = true,
                    onExit: (_) => isHoveredSalir.value = false,
                    child: GestureDetector(
                      onTap: () => con.signOut(),
                      child: Obx(
                            () => Container(
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
          ],
        ),
      ),
    );
  }

  Widget _buildMainScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // Barra de aplicación en la parte superior de la página
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => con.zoomDrawerController.toggle?.call(),
        ),
        toolbarHeight: 100, // Altura de la barra de herramientas
        title: _encabezado(context),   // Título de la barra de herramientas, llama a un método para construir el encabezado
      ),
      // Cuerpo de la página
      body: LayoutBuilder(  // LayoutBuilder para construir la cuadrícula de roles en función del ancho disponible
        builder: (context, constraints) {
          double gridCrossAxisCount = 1; // Número de columnas de la cuadrícula, inicialmente una por defecto

          // Ajustar el número de columnas según el ancho disponible
          if (constraints.maxWidth > 600) {
            gridCrossAxisCount = 2;  // Cambia a dos columnas si el ancho es mayor a 600
          }
          if (constraints.maxWidth > 900) {
            gridCrossAxisCount = 3;  // Cambia a tres columnas si el ancho es mayor a 900
          }

          // Contenedor principal del cuerpo de la cuadrícula
          return Container(
            margin: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.04),  // Margen vertical proporcional al alto disponible
            child: con.user.roles != null  // Comprueba si el usuario tiene roles asignados
                ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(  //  Define las propiedades de la cuadricula
                crossAxisCount: gridCrossAxisCount.toInt(),  // Número de columnas según el ancho de pantalla
                crossAxisSpacing: 10.0,  // Espacio entre columnas
                mainAxisSpacing: 10.0,  // Espacio entre filas
                childAspectRatio: 1.5,  // Relación de aspecto de cada tarjeta de rol
              ),
              itemCount: con.user.roles!.length,  // Número de elementos de la cuadrícula segun los roles de usuario
              itemBuilder: (context, index) {  // Construye cada tarjeta de rol
                return _cardRol(con.user.roles![index]);
              },
            )
                : Center(child: Text('No hay roles disponibles')),  // Muestra un mensaje si no hay roles asignados
          );
        },
      ),
    );
  }


  // Metodo para construir cada tarjeta de rol
  Widget _cardRol(Rol rol) {
    return GestureDetector( // Detecta toques sobre el rol
      onTap: () => con.goToPageRol(rol), // Navega a la página del rol cuando se selecciona
      child: Column( // Columna para organisar el contenido de la tarjeta de rol
        children: [
          Container( // Contenedor de la imagen del rol
            margin: EdgeInsets.only(bottom: 1, top: 30),  // Margen superior e inferior de la imagen
            height: 150, // Altura de la imagen del rol
            child: CachedNetworkImage(  // Usa CachedNetworkImage para cargar la imagen desde una URL con caché
              imageUrl: rol.image!, // URL de la imagen del rol
              fit: BoxFit.contain,  // Ajusto de imagen
              fadeInDuration: Duration(milliseconds: 50), // Duración del efecto de entrada
              placeholder: (context, url) => CircularProgressIndicator(), // Indicador de carga mientras se carga la imagen
              errorWidget: (context, url, error) => Icon(Icons.error), // Icono de error si la imagen no carga
            ),
          ),
          Text( // Muestra el nombre del rol debajo de la imagen
            rol.name ?? '',  // Nombre del rol
            style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold), // Estilo del texto
          ),
        ],
      ),
    );
  }

  // Metodo para construir el encabezado de la AppBar
  Widget _encabezado(BuildContext context) {
    return Container(  // Contenedor del encabezado
      margin: EdgeInsets.only(top: 5, left: 10),  // Margen superior e izquierdo
      child: Column(  // Columna para alinear el logo
        mainAxisAlignment: MainAxisAlignment.start, // Aineación a la izquierda
        children: [
          Image.asset(  // Muestra el logo de la aplicación
            'assets/img/LOGO1.png', // Ruta de la imagen del logo
            width: 100,  // Ancho del logo
            height: 100,  // Altura del logo
          ),
        ],
      ),
    );
  }
}
