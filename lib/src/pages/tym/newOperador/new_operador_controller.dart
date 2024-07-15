import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/operador.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/operador_provider.dart';

class OperadorPageController extends GetxController {

  TextEditingController nameController = TextEditingController();

  OperadorProvider operadorProvider = OperadorProvider();

  void createOperador() async {

    String name = nameController.text;

    if (name.isNotEmpty){ //valida que no esten vacios los campos
      Operador operador = Operador(
        name: name,
      );

      ResponseApi responseApi = await operadorProvider.create(operador);
      Get.snackbar('Proceso terminado', responseApi.message ?? '', backgroundColor: Colors.green,
        colorText: Colors.white,);
      if (responseApi.success == true){
         clearForm();
      }

    }
    else {
      Get.snackbar('Formulario no vslido', 'Ingresa todos los datos para registrar al operador', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
    }
  }

  void clearForm(){
    nameController.text = '';
  }

}




