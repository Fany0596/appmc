import 'package:flutter/material.dart'; // Importa Flutter para construir la interfaz
import 'package:get/get.dart'; // Importa GetX para la gestión de estados y navegación
import 'package:maquinados_correa/src/pages/roles/roles_controller.dart'; // Importa el controlador de roles
import 'package:maquinados_correa/src/models/Rol.dart'; // Importa el modelo de Rol
import 'package:cached_network_image/cached_network_image.dart'; // Importa para cargar imágenes de la red con caché

// Define la página de roles de usuario
class RolesPage extends StatelessWidget {
  // Crea una instancia del controlador RolesController y la inicializa con Get.put
  RolesController con = Get.put(RolesController());

  // Método principal de construcción de la interfaz
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // Devuelve un Scaffold como estructura principal de la página
      drawer: Drawer(  // Define el menú lateral (drawer) de la página
        child: Container(// Contenedor principal del drawer con un fondo blanco semitransparente
          color: Colors.white60,
          child: SingleChildScrollView(  // Usa SingleChildScrollView para permitir el scroll dentro del menú
            child: Column(   // Define una columna para alinear los elementos del menú
              children: [
                SizedBox(height: 57), // Espacio vacío en la parte superior del menú
                CircleAvatar(  // Si el usuario tiene una imagen, la carga desde la red; de lo contrario, usa una imagen local
                  backgroundImage: con.user.image != null
                      ? NetworkImage(con.user.image!)  // Imagen de red
                      : AssetImage('assets/img/LOGO1.png') as ImageProvider,  // Imagen local
                  radius: 70,  // Radio del avatar circular
                  backgroundColor: Colors.transparent,   // Fondo transparente detrás de la imagen
                ),
                SizedBox(height: 10),  // Espacio vacío debajo de la imagen del usuario
                Text(
                  '${con.user.name ?? ''}  ${con.user.lastname}',  // Muestra el nombre y apellido del usuario
                  style: TextStyle(  // Estilo del texto que muestra el nombre del usuario
                    fontSize: 16,  // Tamaño de fuente
                    color: Colors.black,  // Color de fuente
                    fontWeight: FontWeight.bold,  // Grosor de la fuente
                  ),
                ),
                // Widget para detectar toques en el texto 'Perfil'
                GestureDetector(
                  onTap: () => con.goToPerfilPage(),  // Cuando se toca, navega a la página de perfil
                  child: Container(  // Contenedor para el texto del perfil
                    margin: EdgeInsets.only(top: 40, left: 1),  // Margen en la parte superior y lateral izquierdo
                    padding: EdgeInsets.all(20),  // Espacio interior del contenedor
                    width: double.infinity,  // Anchura completa del contenedor
                    color: Colors.white,  // Color de fondo blanco
                    child: Text(  // Texto del perfil
                      'Perfil',
                      style: TextStyle(  // Estilo del texto del perfil
                        fontSize: 13,  // Tamaño
                        color: Colors.black,  // Color de fuente
                        fontWeight: FontWeight.bold,  // Grosor de la fuente
                      ),
                    ),
                  ),
                ),
                // Contenedor para el botón de cerrar sesión
                Container(
                  margin: EdgeInsets.only(top: 20, left: 160),// Margen en la parte superior e izquierdo
                  alignment: Alignment.topRight, // Alineación a la derecha del boton
                  child: IconButton(  // Boton de icono para cerrar sesión
                      onPressed: () => con.signOut(), // Al presionar, llama al método para cerrar sesión
                      icon: Icon( // Define el icono de cierre de sesión
                        Icons.power_settings_new,  // Icono de cierre de sesión
                        color: Colors.black,  // Color del icono
                        size: 30,  // Tamaño del icono
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
      // Barra de aplicación en la parte superior de la página
      appBar: AppBar(
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
