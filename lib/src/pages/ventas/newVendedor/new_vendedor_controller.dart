import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/vendedor.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/vendedor_provider.dart';



class VendedoresPageController extends GetxController {


  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  VendedoresProvider vendedoresProvider = VendedoresProvider();

  void createVendedores() async {

    String name = nameController.text;
    String number = numberController.text;
    String email = emailController.text;

    if (name.isNotEmpty){ //valida que no esten vacios los campos
      Vendedores vendedores = Vendedores(
        name: name,
        number: number,
        email: email,
      );

      ResponseApi responseApi = await vendedoresProvider.create(vendedores);
      Get.snackbar('Proceso terminado', responseApi.message ?? '');
      if (responseApi.success == true){
         clearForm();
      }

    }
    else {
      Get.snackbar('Formulario no vslido', 'Ingresa todos los datos para crear una nueva cotizacion');
    }
  }

  void clearForm(){
    nameController.text = '';
    numberController.text = '';
    emailController.text = '';

  }

}




