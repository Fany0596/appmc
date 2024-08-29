import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/operador.dart';
import 'package:maquinados_correa/src/models/tiempo.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/providers/operador_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:maquinados_correa/src/providers/tiempo_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class TiemposController extends GetxController {
  Producto? producto;
  @override
  void onInit() {
    super.onInit();
    print('Argumentos recibidos: ${Get.arguments}');
    producto = Producto.fromJson(Get.arguments['producto']);
    print('Producto recibido: ${producto?.articulo}');
    checkInitialRecord();
  }

  void onProcesoSelected(String? value) {
    selectedOperacion.value = value ?? '';
    procesoController.text = value ?? '';
    checkInitialRecord();
    getLastState();
  }

  TextEditingController procesoController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController comentController = TextEditingController();
  TextEditingController estadoController = TextEditingController();
  TextEditingController operadorController = TextEditingController();
  Rx<String> selectedOperacion = Rx<String>('');
  Rx<String> selectedStatus = Rx<String>('');
  RxBool hasInitialRecord = false.obs;
  RxString lastState = RxString('');
  RxBool hasRecords = RxBool(false);

  var idOperador = ''.obs;
  List<Operador> operador = <Operador>[].obs;

  ProductoProvider productoProvider = ProductoProvider();
  TiempoProvider tiempoProvider = TiempoProvider();
  OperadorProvider operadorprovider = OperadorProvider();

  TiemposController() {
    getOperador();}
  void getOperador() async {
    var result = await operadorprovider.getAll();
    operador.addAll(result);
  }
  Future<void> checkInitialRecord() async {
    bool result = await tiempoProvider.hasInitialRecord(producto!.id!, procesoController.text);
    hasInitialRecord.value = result;
  }
  Future<void> getLastState() async {
    if (producto != null && producto!.id != null) {
      try {
        Map<String, dynamic> result = await tiempoProvider.getLastStateByProductoAndProceso(producto!.id!, procesoController.text);
        lastState.value = result['lastState'] ?? '';
        hasRecords.value = result['hasRecords'] ?? false;
      } catch (e) {
        print('Error al obtener el último estado: $e');
        lastState.value = '';
        hasRecords.value = false;
      }
    } else {
      lastState.value = '';
      hasRecords.value = false;
    }
  }
  void createTiempo(BuildContext context) async {
    String proceso = procesoController.text;
    String time = timeController.text;
    String estado = estadoController.text;
    String coment = comentController.text;
    if (isValidForm(proceso, time, estado, coment)) {
      ProgressDialog progressDialog = ProgressDialog(context: context);
      progressDialog.show(max: 100, msg: 'Creando tiempo...');
      Tiempo tiempo = Tiempo(
        proceso: proceso,
        time: time,
        estado: estado,
        coment: coment,
        idOperador: idOperador.value,
        idProducto: producto?.id,
      );

      ResponseApi responseApi = await tiempoProvider.create(tiempo);
      progressDialog.close();

      if (responseApi.success == true) {
        Get.snackbar('Tiempo creado', responseApi.message ?? '',
            backgroundColor: Colors.green, colorText: Colors.white);
        updateEstatus(context, estado, proceso);
      } else {
        Get.snackbar('Error', 'No se pudo crear el tiempo',
            backgroundColor: Colors.red, colorText: Colors.white);
      }}}
  bool isValidForm(String proceso, String time, String estado, String coment) {
    if (proceso.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa proceso', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return false;}
    if (time.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa tiempo', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return false;}
    if (estado.isEmpty) {
      Get.snackbar('Formulario no valido', 'Ingresa status', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return false;}
    if (idOperador.isEmpty) {
      Get.snackbar('Formulario no valido', 'Selecciona un operador', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return false;}
    return true;
  }

  void updateEstatus(BuildContext context, String estado, String proceso) async {
    ProgressDialog progressDialog = ProgressDialog(context: context);
    if (estado.isNotEmpty) {
      progressDialog.show(max: 100, msg: 'Actualizando estatus del producto...');
      Operador? selectedOperador = operador.firstWhere(
              (operador) => operador.id == idOperador.value,
          orElse: () => Operador(name: 'Operador desconocido')
      );

      String nuevoEstatus;
      if (estado == 'INICIO' || estado == 'REANUDAR') {
        nuevoEstatus = 'EN PROCESO';
      } else {
        nuevoEstatus = estado;
      }

      Producto updatedProducto = Producto(
        id: producto!.id,
        estatus: nuevoEstatus,
        operacion: proceso,
        operador: selectedOperador?.name,
      );

      ResponseApi responseApi = await productoProvider.updateds(updatedProducto);
      progressDialog.close();

      if (responseApi.success == true) {
        Get.snackbar('Actualización exitosa', 'El estatus del producto ha sido actualizado',
            backgroundColor: Colors.green, colorText: Colors.white);
        producto?.estatus = nuevoEstatus;
        producto?.operacion = proceso;
      } else {
        Get.snackbar('Error', 'No se pudo actualizar el status del producto',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
    else {
      Get.snackbar('Error', 'El status no puede estar vacío',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}