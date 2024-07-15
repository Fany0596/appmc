import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/Client.dart';
import 'package:maquinados_correa/src/models/provedor.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/provedor_provider.dart';

class NewProveedorController extends GetxController {


  TextEditingController nameController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController direcController = TextEditingController();

  ProvedorProvider provedorProvider = ProvedorProvider();

  void createNewClient() async {

    String name = nameController.text;
    String nombre = nombreController.text;
    String correo = correoController.text;
    String direc = direcController.text;
    String telefono = telefonoController.text;

    if (name.isNotEmpty){ //valida que no esten vacios los campos
      Provedor provedor = Provedor(
        name: name,
        nombre: nombre,
        correo: correo,
        direc: direc,
        telefono: telefono,
      );

      ResponseApi responseApi = await provedorProvider.create(provedor);
      Get.snackbar('Proceso terminado', responseApi.message ?? '', backgroundColor: Colors.green,
        colorText: Colors.white,);
      if (responseApi.success == true){
         clearForm();
      }

    }
    else {
      Get.snackbar('Formulario no valido', 'Ingresa todos los datos para crear un nuevo proveedor', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
    }
  }

  void clearForm(){
    nameController.text = '';
    nombreController.text = '';
    correoController.text = '';
    direcController.text = '';
    telefonoController.text = '';

  }

}







