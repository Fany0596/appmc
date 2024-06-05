import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../../../models/user.dart';
import '../../../../providers/users_provider.dart';
import '../profile_info_controller.dart';

class ProfileUpdateController extends GetxController {

  User user = User.fromJson(GetStorage().read('user') ?? {});

  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();

  ImagePicker picker = ImagePicker();
  File? imageFile;

  UsersProvider usersProvider = UsersProvider();

  ProfileInfoController profileInfoController = Get.find();

  ProfileUpdateController(){
    print('USER SESION: ${GetStorage().read('user')}');
    nameController.text = user.name ?? '';
    lastnameController.text = user.lastname ?? '';
  }

  void updateInfo(BuildContext context) async {
    String name = nameController.text;
    String lastname = lastnameController.text;


    if (isValidForm(name, lastname )) {
      ProgressDialog progressDialog = ProgressDialog(context: context);
      progressDialog.show(max: 100, msg: 'Actualizando datos...');

      User myUser = User(
        id: user.id,
        name: name,
        lastname: lastname,
          sessionToken: user.sessionToken
      );

      if (imageFile == null) {
        ResponseApi responseApi = await usersProvider.update(myUser);
        print('Response Api Update: ${responseApi.data}');
        Get.snackbar('Proceso terminado', responseApi.message ?? '');
        progressDialog.close();
        if (responseApi.success == true){

          GetStorage().write('user', responseApi.data);
          profileInfoController.user.value = User.fromJson(responseApi.data);
          //print('Response Api Update: ${responseApi.data}');
        }
      }
      else {
        Stream stream = await usersProvider.updateWithImage(myUser, imageFile!);
        stream.listen((res) {

          progressDialog.close();
          ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
          Get.snackbar('Proceso terminado', responseApi.message ?? '');
          print('Response Api Update: ${responseApi.data}');


          if (responseApi.success == true){

            GetStorage().write('user', responseApi.data);
            profileInfoController.user.value = User.fromJson(responseApi.data);
          }
          else {
            Get.snackbar('Registro fallido', responseApi.message ?? '');
          }
        });
      }

    }
  }
    bool isValidForm(
        String name,
        String lastname) {

      if (name.isEmpty) {
        Get.snackbar('Formulario no valido', 'Debes ingresar nombre');
        return false;
      }
      if (lastname.isEmpty) {
        Get.snackbar('Formulario no valido', 'Debes ingresar apellido');
        return false;
      }

      return true;
    }

    Future selectImage(ImageSource imageSource) async {
      XFile? image = await picker.pickImage(source: imageSource);
      if (image != null) {
        imageFile = File(image.path); // guarda la ruta de la imagen
        update(); //actualiza la pagina automaticamente
      }
    }

    void showAlertDialog(BuildContext context) {
      Widget galleryButton = ElevatedButton(
          onPressed: () {
            Get.back(); //cierra la ventana de alerta
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
          onPressed: () {
            Get.back(); //cierra la ventana de alerta
            selectImage(ImageSource.camera);
          },
          child: Text(
            'CAMARA',
            style: TextStyle(
                color: Colors.white
            ),
          )
      );

      AlertDialog alertDialog = AlertDialog( // ventana emergente
        title: Text('Selecciona una opcion'),
        actions: [
          galleryButton,
          cameraButton
        ],
      );

      showDialog(context: context, builder: (BuildContext context) {
        return alertDialog;
      });
    }
  }
