import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/users_provider.dart';

class LoginController extends GetxController{

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  UsersProvider usersProvider = UsersProvider();
  void goToRegisterPage(){
    Get.toNamed('/registro');
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    print('Email ${email}');
    print('Password ${password}');

    if (isValidForm(email, password)){
      ResponseApi responseApi = await usersProvider.login(email, password);

      print('Response Api:${responseApi.toJson()}');

      if (responseApi.success == true){

        GetStorage().write('user', responseApi.data); // Alamacena los datos del us
        //goToHomePage();
        goToRolesPage();
      }
      else {
        Get.snackbar('Inicio de sesion fallido', responseApi.message ?? '');
      }


    }
  }
  void goToHomePage(){
    Get.offNamedUntil('/home', (route) => false);
    
  }
  void goToRolesPage(){
    Get.offNamedUntil('/roles', (route) => false);

  }
  
  bool isValidForm(String email, String password){

    if (email.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar usuario');
      return false;
    }

    if (!GetUtils.isEmail(email)){
      Get.snackbar('Formulario no valido', 'Debes ingresar usuario valido');
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar contraseña');
      return false;
    }
    return true;
  }
}