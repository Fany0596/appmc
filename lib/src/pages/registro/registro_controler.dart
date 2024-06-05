import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/users_provider.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class RegisterController extends GetxController{

  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  UsersProvider usersProvider = UsersProvider();

  ImagePicker picker = ImagePicker();
  File? imageFile;

  void register(BuildContext context) async {
    String email = emailController.text.trim();
    String name = nameController.text;
    String lastname = lastnameController.text;
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    print('Email ${email}');
    print('Password ${password}');

    if (isValidForm(email,name, lastname, password, confirmPassword)){

      ProgressDialog progressDialog = ProgressDialog(context: context);
      progressDialog.show(max: 100, msg:'Registrando datos...');

      User user = User(
        email: email,
        name: name,
        lastname: lastname,
        password: password,
      );

     Stream stream = await usersProvider.createWithImage(user, imageFile!);
     stream.listen((res) {

       progressDialog.close();// cierra la ventana de registrando datos

       ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));

       if (responseApi.success == true){
         GetStorage().write('user', responseApi.data);
         goToCotizacionPage();
       }
       else{
         Get.snackbar('Registro fallido', responseApi.message ?? '');
         progressDialog.close();
       }

     });
    }
  }
  void goToCotizacionPage(){
    Get.offNamedUntil('/cot', (route) => false);
  }
  bool isValidForm(
      String email,
      String name,
      String lastname,
      String password,
      String confirmPassword
      )
  {
    if (name.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar nombre');
      return false;
    }
    if (lastname.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar apellido');
      return false;
    }

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
    if (confirmPassword.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes confirmar contraseña');
      return false;
    }
    if (password != confirmPassword) {
      Get.snackbar('Formulario no valido', 'Las contraseñas no coinciden');
      return false;
    }
    if (imageFile == null) {
      Get.snackbar('Formulario no valido', 'Debes seleccionar una foto de perfil');
      return false;
    }
    return true;
  }

  Future selectImage(ImageSource imageSource) async {
    XFile? image = await picker.pickImage(source: imageSource);
    if (image != null) {
      imageFile = File(image.path);// guarda la ruta de la imagen
      update();//actualiza la pagina automaticamente
    }
  }

  void showAlertDialog(BuildContext context){
    Widget galleryButton = ElevatedButton(
        onPressed: (){
          Get.back();//cierra la ventana de alerta
          selectImage(ImageSource.gallery);
        },
        child: Text(
            'GALERIA',
          style: TextStyle(
            color: Colors.white
          ),
        )
    );

    Widget cameraButton = ElevatedButton(
        onPressed: (){
          Get.back();//cierra la ventana de alerta
          selectImage(ImageSource.camera);
        },
        child: Text(
            'CAMARA',
          style: TextStyle(
              color: Colors.white
          ),
        )
    );

  AlertDialog alertDialog = AlertDialog(// ventana emergente
        title: Text('Selecciona una opcion'),
        actions: [
        galleryButton,
        cameraButton
      ],
  );

  showDialog(context: context, builder:(BuildContext context){
    return alertDialog;
  });

  }

}