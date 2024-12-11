import 'package:get/get.dart'; // Importa GetX para manejo de controladores y navegación
import 'package:flutter/cupertino.dart'; // Importa componentes de UI de Flutter
import 'package:get_storage/get_storage.dart'; // Importa GetStorage para almacenamiento local
import 'package:maquinados_correa/src/models/response_api.dart'; // Importa el modelo de respuesta de API
import 'package:maquinados_correa/src/providers/users_provider.dart'; // Importa el proveedor para usuarios

class LoginController extends GetxController {// Define el controlador de login extendiendo GetxController
  TextEditingController emailController = TextEditingController();// Controlador para el campo de email
  TextEditingController passwordController = TextEditingController();// Controlador para el campo de contraseña

  UsersProvider usersProvider = UsersProvider();// Instancia del proveedor de usuarios para manejar API

  // Método de login asíncrono
  void login() async {
    String email = emailController.text.trim();// Obtiene y limpia el texto ingresado en el campo email
    String password = passwordController.text.trim(); // Obtiene y limpia el texto ingresado en el campo contraseña

    print('Email ${email}'); // Imprime el email en la consola para depuración
    print('Password ${password}'); // Imprime la contraseña en la consola para depuración

    // Verifica si el formulario es válido antes de continuar
    if (isValidForm(email, password)) {
      ResponseApi responseApi = await usersProvider.login(email, password); // Realiza la llamada de login a la API

      print('Response Api:${responseApi.toJson()}'); // Imprime la respuesta de la API en formato JSON para depuración

      if (responseApi.success == true) { // Verifica si el login fue exitoso
        GetStorage()
            .write('user', responseApi.data); // Almacena los datos del usuario en el almacenamiento local
        goToRolesPage(); // Llama a la función para ir a la página de roles
      } else {
        Get.snackbar('Inicio de sesion fallido', responseApi.message ?? ''); // Muestra un mensaje si el login falla
      }
    }
  }

  // Método para ir a la página de roles
  void goToRolesPage() {
    Get.offNamedUntil('/roles', (route) => false); // Navega a la página de roles y elimina las rutas anteriores
  }

  // Método para validar el formulario
  bool isValidForm(String email, String password) {
    if (email.isEmpty) { // Verifica si el campo de email está vacío
      Get.snackbar('Formulario no valido', 'Debes ingresar usuario'); // Muestra un mensaje si el email está vacío
      return false; // Retorna false indicando que el formulario no es válido
    }

    if (!GetUtils.isEmail(email)) { // Verifica si el email tiene un formato válido
      Get.snackbar('Formulario no valido', 'Debes ingresar usuario valido'); // Muestra un mensaje si el email es inválido
      return false; // Retorna false indicando que el formulario no es válido
    }

    if (password.isEmpty) { // Verifica si el campo de contraseña está vacío
      Get.snackbar('Formulario no valido', 'Debes ingresar contraseña'); // Muestra un mensaje si la contraseña está vacía
      return false; // Retorna false indicando que el formulario no es válido
    }
    return true; // Retorna true indicando que el formulario es válido
  }
}
