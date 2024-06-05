import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/material_provider.dart';


class MaterialesController extends GetxController {


  TextEditingController nameController = TextEditingController();

  MaterialesProvider materialesProvider = MaterialesProvider();

  void createMateriales() async {

    String name = nameController.text;

    if (name.isNotEmpty){ //valida que no esten vacios los campos
      Materiales materiales = Materiales(
        name: name,
      );

      ResponseApi responseApi = await materialesProvider.create(materiales);
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







