import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/Client.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/client_provider.dart';



class NewClientController extends GetxController {


  TextEditingController nameController = TextEditingController();

  ClientesProvider clientesProvider = ClientesProvider();

  void createNewClient() async {

    String name = nameController.text;

    if (name.isNotEmpty){ //valida que no esten vacios los campos
      Clientes clientes = Clientes(
        name: name,
      );

      ResponseApi responseApi = await clientesProvider.create(clientes);
      Get.snackbar('Proceso terminado', responseApi.message ?? '');
      if (responseApi.success == true){
         clearForm();
      }

    }
    else {
      Get.snackbar('Formulario no valido', 'Ingresa todos los datos para crear un nuevo cliente');
    }
  }

  void clearForm(){
    nameController.text = '';

  }

}







