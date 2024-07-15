import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maquinados_correa/src/models/Client.dart';
import 'package:maquinados_correa/src/models/vendedor.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/client_provider.dart';
import 'package:maquinados_correa/src/providers/vendedor_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class CotizacionPageController extends GetxController {


  TextEditingController numberController = TextEditingController();
  TextEditingController entController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController condicionesController = TextEditingController();
  TextEditingController descuentoController = TextEditingController();
  TextEditingController reqController = TextEditingController();
  TextEditingController fechaController = TextEditingController();

  VendedoresProvider vendedoresProvider = VendedoresProvider();
  ClientesProvider clientesProvider = ClientesProvider();

  ImagePicker picker = ImagePicker();

  var idVendedores = ''.obs;
  List<Vendedores> vendedores = <Vendedores>[].obs;
  var idClientes = ''.obs;
  List<Clientes> clientes = <Clientes>[].obs;
  CotizacionProvider cotizacionProvider = CotizacionProvider();
  String? prevNumb; // Variable para almacenar el último número de cotización registrado
  String? newNumb;

  @override
  void onInit() {
    super.onInit();
    // Llama al método para obtener el último número de cotización registrado
    getNextQuoteNumber();
  }

  void getNextQuoteNumber() async {
    // Llama al proveedor de cotizaciones para obtener el último número de cotización
    List<Cotizacion> cotizaciones = await cotizacionProvider.getAll();
    if (cotizaciones.isNotEmpty) {
      // Si hay cotizaciones registradas, obtén el último número de la última cotización
      String lastQuoteNumber = cotizaciones.last.number ?? ""; // Obtén el número de cotización
      int lastIndex = lastQuoteNumber.lastIndexOf(RegExp(r'\d')); // Encuentra el índice del último dígito en el número
      String prevNumber = lastQuoteNumber.substring(lastIndex); // Extrae el número final
      String prevLetters = lastQuoteNumber.substring(0, lastIndex); // Extrae las letras iniciales

      int prevNumbInt = int.parse(prevNumber); // Convierte el número de cotización a entero
      prevNumb = prevLetters + (prevNumbInt.toString()); // Almacena el número de cotización como una cadena

      int newNumbInt = prevNumbInt + 1; // Suma uno al número de cotización
      newNumb = prevLetters + newNumbInt.toString(); // Almacena el nuevo número de cotización como una cadena
    } else {
      prevNumb = null; // Si no hay cotizaciones registradas, prevNumb es null
      newNumb = "COT-1"; // Si no hay cotizaciones registradas, el nuevo número de cotización es A1
    }
    numberController.text = newNumb!;
    update(); // Actualiza para que la UI muestre los nuevos números
  }

  CotizacionPageController() {
    getVendedores();
    getClientes();
  }

  void getVendedores() async {
    var result = await vendedoresProvider.getAll();
    vendedores.clear();
    vendedores.addAll(result);
  }
  void getClientes() async {
    var result = await clientesProvider.getAll();
    clientes.clear();
    clientes.addAll(result);
  }

  void createCotizacion(BuildContext context) async {

    String number = numberController.text;
    String ent = entController.text;
    String nombre = nombreController.text;
    String correo = correoController.text;
    String telefono = telefonoController.text;
    String descuento = descuentoController.text;
    String condiciones = condicionesController.text;
    String req = reqController.text;
    String fecha = fechaController.text;
    print('NUMBER: ${number}');
    print('NOMBRE: ${nombre}');
    print('CORREO: ${correo}');
    print('TELEFONO: ${telefono}');
    print('ID VENDEDOR: ${idVendedores}');
    print('ID CLIENTE: ${idClientes}');
    ProgressDialog progressDialog = ProgressDialog(context: context);



    if (isValidForm(idClientes.value, ent, condiciones)){ //valida que no esten vacios los campos
      Cotizacion cotizacion = Cotizacion(
        number: number,
        ent: ent,
          fecha: fecha,
        nombre: nombre,
        correo: correo,
          req: req,
          condiciones: condiciones,
        descuento:descuento,
        telefono: telefono,
        idVendedores: idVendedores.value,
        idClientes: idClientes.value
      );
      progressDialog.show(max: 100, msg:'Espere un momento...');

      List<File> images =[];
      Stream stream = await cotizacionProvider.create(cotizacion, images);
      stream.listen((res) {

        ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
        progressDialog.close();
        Get.snackbar('Proceso terminado', responseApi.message ?? '',backgroundColor: Colors.green,
          colorText: Colors.white,);
        if (responseApi.success!) { // Si la respuesta es exitosa, navegar a la página de roles
          goToRoles();
        }
      });
    }
  }
  bool isValidForm(String number, String ent, String condiciones) {
    if (number.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa número de cotización',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (ent.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa tiempo de entrega',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (condiciones.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa las condiciones de pago',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (idVendedores == null) {
      Get.snackbar('Formulario no valido', 'Selecciona un vendedor',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (idClientes == null) {
      Get.snackbar('Formulario no valido', 'Selecciona un cliente',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }


    return true;
  }

  void showAlertDialog(BuildContext context, int numberFile){
    Widget galleryButton = ElevatedButton(
        onPressed: (){
          Get.back();//cierra la ventana de alerta
          //selectImage(ImageSource.gallery, numberFile);
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
          //selectImage(ImageSource.camera, numberFile);
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

  void clearForm(){
    numberController.text = '';

  }
  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }

}
