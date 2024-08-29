import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maquinados_correa/src/models/comprador.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/models/provedor.dart';
import 'package:maquinados_correa/src/providers/comprador_provider.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/oc_provider.dart';
import 'package:maquinados_correa/src/providers/provedor_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class OcPageController extends GetxController {

  TextEditingController numberController = TextEditingController();
  TextEditingController entController = TextEditingController();
  TextEditingController soliController = TextEditingController();
  TextEditingController comentController = TextEditingController();
  TextEditingController condicionesController = TextEditingController();
  TextEditingController monedaController = TextEditingController();
  TextEditingController tipoController = TextEditingController();
  Rx<String> selectedCondition = Rx<String>('');
  Rx<String> selectedMoneda = Rx<String>('');
  Rx<String> selectedTipo = Rx<String>('');

  OcProvider ocProvider = OcProvider();
  ProvedorProvider provedorProvider = ProvedorProvider();
  CotizacionProvider cotizacionProvider = CotizacionProvider();
  CompradorProvider compradorProvider = CompradorProvider();

  ImagePicker picker = ImagePicker();

  var idCotizaciones = ''.obs;
  List<Cotizacion> cotizacion = <Cotizacion>[].obs;
  var idComprador = ''.obs;
  List<Comprador> comprador = <Comprador>[].obs;
  var idProvedor = ''.obs;
  List<Provedor> provedor = <Provedor>[].obs;

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
    List<Oc> oc = await ocProvider.getAll();
    int year = DateTime.now().year;
    String yearSuffix = year.toString().substring(2); // Obtiene los últimos dos dígitos del año
    int nextSequentialNumber = 1;

    if (oc.isNotEmpty) {
      // Si hay OC registradas, obtén el último número de la última OC
      String lastQuoteNumber = oc.last.number ?? ""; // Obtén el número de OC
      RegExp regex = RegExp(r'OC-(\d+)-(\d{2})');
      Match? match = regex.firstMatch(lastQuoteNumber);

      if (match != null) {
        String lastYearSuffix = match.group(2)!;
        int lastSequentialNumber = int.parse(match.group(1)!);

        if (lastYearSuffix == yearSuffix) {
          nextSequentialNumber = lastSequentialNumber + 1;
        }
      }
    }

    String formattedSequentialNumber = nextSequentialNumber.toString().padLeft(3, '0');
    newNumb = "OC-$formattedSequentialNumber-$yearSuffix";
    numberController.text = newNumb!;
    update(); // Actualiza para que la UI muestre los nuevos números
  }


    OcPageController() {
    getCotizacion();
    getProvedor();
    getComprador();
  }
  void getComprador() async {
    var result = await compradorProvider.getAll();
    comprador.clear();
    comprador.addAll(result);
  }
  void getCotizacion() async {
    var result = await cotizacionProvider.getAll();
    cotizacion.clear();
    cotizacion.addAll(result);
  }
  void getProvedor() async {
    var result = await provedorProvider.getAll();
    provedor.clear();
    provedor.addAll(result);
  }

  void createOc(BuildContext context) async {

    String number = numberController.text;
    String ent = entController.text;
    String soli = soliController.text;
    String coment = comentController.text;
    String condiciones = condicionesController.text;
    String moneda = monedaController.text;
    String tipo = tipoController.text;
    print('NUMBER: ${number}');
    print('CONDICIONES: ${condiciones}');
    print('ID COTIZACION: ${idCotizaciones}');
    print('ID CLIENTE: ${idProvedor}');
    print('ID Comprador: ${idComprador}');
    ProgressDialog progressDialog = ProgressDialog(context: context);

    if (isValidForm(idProvedor.value, ent, soli, condiciones, tipo, moneda)){ //valida que no esten vacios los campos
      Oc oc = Oc(
        number: number,
        ent: ent,
          soli: soli,
          condiciones: condiciones,
        moneda: moneda,
        coment: coment,
        tipo: tipo,
        idComprador: idComprador.value,
        idCotizaciones: idCotizaciones.value,
        idProvedor: idProvedor.value
      );
      progressDialog.show(max: 100, msg:'Espere un momento...');

      List<File> images =[];
      Stream stream = await ocProvider.create(oc, images);
      stream.listen((res) {

        ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
        progressDialog.close();
        Get.snackbar('Proceso terminado', responseApi.message ?? '',backgroundColor: Colors.green,
          colorText: Colors.white,);
        clearForm();
      });
    }
  }
  bool isValidForm(String number, String ent, String condiciones, String soli, String tipo, String moneda) {
    if (number.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa número de oc',  backgroundColor: Colors.red,
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
    if (soli.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa fecha de solicitud',  backgroundColor: Colors.red,
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
    if (idComprador == null) {
      Get.snackbar('Formulario no valido', 'Selecciona un comprador',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (idCotizaciones == null) {
      Get.snackbar('Formulario no valido', 'Selecciona una cotizacion',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (idProvedor == null) {
      Get.snackbar('Formulario no valido', 'Selecciona un proveedor',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (tipo.isEmpty) {
      Get.snackbar('Formulario no valido', 'Selecciona un tipo de compra',  backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      return false;
    }
    if (moneda.isEmpty) {
      Get.snackbar('Formulario no valido', 'Selecciona un tipo de moneda',  backgroundColor: Colors.red,
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
    entController.text = '';
    soliController.text = '';
    idCotizaciones.value = '';
    idProvedor.value = '';
    update();
  }

}
