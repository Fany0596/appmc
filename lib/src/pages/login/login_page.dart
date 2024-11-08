import 'package:flutter/material.dart'; // Importa los widgets de Flutter para la UI
import 'package:get/get.dart'; // Importa GetX para gestión de estado y controladores
import 'package:maquinados_correa/src/pages/login/login_controler.dart'; // Importa el controlador de login

class LoginPage extends StatelessWidget {
  // Declara una clase de tipo StatelessWidget para la página de inicio de sesión

  LoginController con = Get.put(
      LoginController()); // Llama al controlador de login y lo pone en memoria para su uso en la página

  @override
  Widget build(BuildContext context) {
    // Método build que construye la UI
    return Scaffold(
      // Retorna un Scaffold, que estructura la página
      body: Stack(
        // Usa un Stack para superponer elementos uno sobre otro
        children: [
          _backGroundCover(context),
          // Llama a la función que muestra el fondo de pantalla
          _boxForm(context),
          // Llama a la función que muestra el formulario
          Column(
            // Organiza elementos en columna, apilándolos en sentido vertical
            children: [
              _imageCover(), // Llama a la función que muestra la imagen de logo
            ],
          )
        ],
      ),
    );
  }

  // Widget para mostrar el fondo de pantalla
  Widget _backGroundCover(BuildContext context) {
    return SafeArea(
      // Evita que el contenido se solape con la barra de estado
      child: Container(
        // Contenedor para el fondo de pantalla
        child: Image.asset(
          // Muestra una imagen de fondo desde los assets
          'assets/img/fondo1.jpg', // Ruta de la imagen en los assets
          width: MediaQuery.of(context)
              .size
              .width, // Ajusta el ancho de la imagen al ancho de la pantalla
          height: MediaQuery.of(context)
              .size
              .height, // Ajusta la altura de la imagen al alto de la pantalla
          fit: BoxFit
              .cover, // Ajusta la imagen para que cubra toda el área del contenedor
        ),
      ),
    );
  }

  // caja de formulario de inicio
  Widget _boxForm(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.38,
      // Ajusta la altura del formulario
      margin: EdgeInsets.only(top: 320, left: 50, right: 50),
      // Márgenes superiores y laterales del formulario
      decoration: BoxDecoration(// Decoración de la caja
          boxShadow: <BoxShadow>[
        // Sombra de la caja
        BoxShadow(
            color: Colors.white60, // Color de la sombra
            blurRadius: 15, // Radio de desenfoque de la sombra
            offset: Offset(0, 0.075) // Desplazamiento de la sombra
            )
      ]),
      child: SingleChildScrollView(
        // Permite desplazar la vista si el contenido es demasiado grande
        child: Column(
          // Column para organizar los widgets del formulario
          children: [
            _textFielUser(),
            // Llama a la función para el campo de usuario
            _textFielPassword(),
            // Llama a la función para el campo de contraseña
            _buttonLogin(),
            // Llama a la función para el botón de login
          ],
        ),
      ),
    );
  }

  // Widget para el campo de usuario
  Widget _textFielUser() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      // Márgenes del campo
      child: TextField(
          // Campo de texto para ingresar el usuario
          controller: con.emailController,
          // Controlador para capturar el texto ingresado
          keyboardType: TextInputType.emailAddress,
          // Establece el tipo de teclado con el símbolo "@"
          decoration: InputDecoration(
            // Decoración del campo
            hintText: 'Usuario',
            // Texto que se muestra cuando el campo está vacío
            prefixIcon: Icon(Icons
                .perm_identity_outlined), // Icono que representa al usuario
          )),
    );
  }

  // Widget para el campo de contraseña
  Widget _textFielPassword() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      // Márgenes del campo
      child: TextField(// Campo de texto para ingresar la contraseña
        controller: con.passwordController, // Controlador para capturar el texto ingresado
        keyboardType: TextInputType.text, // Tipo de entrada de texto
        obscureText: true, // Oculta el texto ingresado (para contraseñas)
        decoration: InputDecoration( // Decoración del campo
            hintText: 'Contraseña', // Texto que se muestra cuando el campo está vacío
            prefixIcon:
                Icon(Icons.lock_outline) // Icono que representa un candado
            ),
      ),
    );
  }

  // Widget para el botón de inicio de sesión
  Widget _buttonLogin() {
    return Container(
      width: double.infinity, // Ajusta el ancho al máximo disponible
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10), // Márgenes del botón
      child: ElevatedButton( // Botón elevado
          onPressed: () => con.login(), // Llama al método login del controlador al presionar
          style: ElevatedButton.styleFrom( // Estilo del botón
              padding: EdgeInsets.symmetric(
                  vertical: 15 // Añade un padding vertical
              )
              ),
          child: Text( // Texto dentro del botón
            'LOGIN', // Texto que se muestra en el botón
            style: TextStyle(
              color: Colors.white, // Color del texto
            ),
          )),
    );
  }

// Widget para mostrar la imagen del logo
  Widget _imageCover() {
    return Container(
      margin: EdgeInsets.only(top: 70), // Margen superior de la imagen
      alignment: Alignment.center, // Centra la imagen
      child: Image.asset( // Muestra una imagen desde los assets
        'assets/img/LOGO1.png', // Ruta de la imagen en los assets
        width: 280, // Ancho de la imagen
        height: 280, // Alto de la imagen
      ),
    );
  }
}
