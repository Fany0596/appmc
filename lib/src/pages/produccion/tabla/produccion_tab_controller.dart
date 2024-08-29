import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/tiempo.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:maquinados_correa/src/providers/tiempo_provider.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ProduccionTabController extends GetxController{

  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  TextEditingController clienteController = TextEditingController();

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  ProductoProvider productoProvider = ProductoProvider();
  TiempoProvider tiempoProvider = TiempoProvider();

  List<String> status = <String>['GENERADA'].obs;
  Future<List<Cotizacion>> getCotizacion(String status) async {
    return await cotizacionProvider.findByStatus(status);

  }


  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); //Elimina el historial de las pantallas y regresa al login
  }
  void goToRegisterPage(){
    Get.toNamed('/registro');
  }
  void goToPerfilPage(){
    Get.toNamed('/profile/info');
  }
  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }

  void goToDetalles(Cotizacion cotizacion){
    Get.toNamed('/produccion/orders/detalles_produccion', arguments: {
      'cotizacion': cotizacion.toJson()
    });
  }
  int calcularTiempoTrabajado(List<Tiempo> tiempos) {
    int tiempoTotal = 0;
    DateTime? inicioProceso;
    DateTime ahora = DateTime.now();
    DateTime? inicioSuspension;

    for (var i = 0; i < tiempos.length; i++) {
      var tiempo = tiempos[i];
      if (tiempo.time == null) continue;
      DateTime fechaTiempo = DateTime.parse(tiempo.time!);

      print('Procesando tiempo: ${tiempo.time}, Estado: ${tiempo.estado}');

      if (tiempo.estado == 'INICIO') {
        inicioProceso = fechaTiempo;
        print('Inicio de proceso: $inicioProceso');
      } else if (tiempo.estado == 'SUSPENDIDO') {
        if (inicioProceso != null && inicioSuspension == null) {
          inicioSuspension = fechaTiempo;
          print('Proceso suspendido en: $inicioSuspension');
        }
      } else if (tiempo.estado == 'REANUDAR') {
        if (inicioSuspension != null) {
          int tiempoSuspendido = calcularTiempoEntreFechas(inicioSuspension, fechaTiempo);
          print('Proceso reanudado en: $fechaTiempo, Tiempo suspendido: $tiempoSuspendido minutos');
          tiempoTotal -= tiempoSuspendido;
          inicioSuspension = null;
        }
      } else if (tiempo.estado == 'SIG. PROCESO') {
        if (inicioProceso != null) {
          int tiempoParcial = calcularTiempoEntreFechas(inicioProceso, fechaTiempo);
          tiempoTotal += tiempoParcial;
          print('Proceso completado en: $fechaTiempo, Tiempo parcial: $tiempoParcial minutos');
          inicioProceso = null;
        }
      }
    }

    // Si el proceso sigue en curso
    if (inicioProceso != null) {
      int tiempoParcial = calcularTiempoEntreFechas(inicioProceso, ahora);
      tiempoTotal += tiempoParcial;
      print('Proceso en curso, calculado hasta ahora: $ahora, Tiempo parcial: $tiempoParcial minutos');
    }

    print('Tiempo total calculado: $tiempoTotal minutos');
    return tiempoTotal;
  }

  int calcularTiempoEntreFechas(DateTime inicio, DateTime fin) {
    int tiempoTrabajado = 0;
    DateTime actual = inicio;

    while (actual.isBefore(fin)) {
      if (!esHorarioExcluido(actual)) {
        DateTime finHora = DateTime(actual.year, actual.month, actual.day, actual.hour, 59, 59);
        if (finHora.isAfter(fin)) finHora = fin;
        int minutosEnEstaHora = finHora.difference(actual).inMinutes + 1;
        tiempoTrabajado += minutosEnEstaHora;
      }
      actual = DateTime(actual.year, actual.month, actual.day, actual.hour + 1); // Avanza a la siguiente hora
    }

    return tiempoTrabajado;
  }

  bool esHorarioExcluido(DateTime fecha) {
    int hora = fecha.hour;
    return hora >= 13 && hora < 14; // Excluye el tiempo entre 1 pm y 2 pm
  }

  Future<Map<String, String>> calcularTiempoEstimado(String productoId) async {
    try {
      List<Tiempo> tiempos = await tiempoProvider.getTiemposByProductId(productoId);
      print('Tiempos obtenidos para el producto $productoId: ${tiempos.length}');
      if (tiempos.isEmpty) {
        return {'total': 'N/A', 'actual': 'N/A'};
      }
      int tiempoTotalTrabajado = calcularTiempoTrabajado(tiempos);
      int tiempoProcesoActual = calcularTiempoProcesoActual(tiempos);
      print('Tiempo total trabajado: $tiempoTotalTrabajado minutos');
      print('Tiempo del proceso actual: $tiempoProcesoActual minutos');

      String formatTiempo(int minutos) {
        int horas = minutos ~/ 60;
        int minutosRestantes = minutos % 60;
        return '${horas.toString().padLeft(2, '0')}:${minutosRestantes.toString().padLeft(2, '0')}';
      }

      String tiempoActualFormatted = formatTiempo(tiempoProcesoActual);
      print('Tiempo actual formateado: $tiempoActualFormatted');

      return {
        'total': formatTiempo(tiempoTotalTrabajado),
        'actual': tiempoActualFormatted
      };
    } catch (e) {
      print('Error al calcular tiempo estimado: $e');
      return {'total': 'Error', 'actual': 'Error'};
    }
  }
  int calcularTiempoProcesoActual(List<Tiempo> tiempos) {
    int tiempoTotal = 0;
    DateTime? inicioProceso;
    DateTime? inicioSuspension;

    for (var tiempo in tiempos) {
      if (tiempo.time == null) continue;
      DateTime fechaTiempo = DateTime.parse(tiempo.time!);

      if (tiempo.estado == 'INICIO') {
        // Reinicia el conteo para el nuevo proceso
        inicioProceso = fechaTiempo;
        inicioSuspension = null;
        tiempoTotal = 0; // Reiniciar el tiempo total al iniciar un nuevo proceso
      } else if (tiempo.estado == 'SUSPENDIDO') {
        if (inicioProceso != null) {
          tiempoTotal += calcularTiempoEfectivo(inicioProceso, fechaTiempo);
          inicioSuspension = fechaTiempo;
          inicioProceso = null;
        }
      } else if (tiempo.estado == 'REANUDAR') {
        if (inicioSuspension != null) {
          inicioProceso = fechaTiempo;
          inicioSuspension = null;
        }
      } else if (tiempo.estado == 'SIG. PROCESO') {
        if (inicioProceso != null) {
          tiempoTotal += calcularTiempoEfectivo(inicioProceso, fechaTiempo);
          inicioProceso = null;
        }
      }
    }

    if (inicioProceso != null) {
      DateTime ahora = DateTime.now();
      tiempoTotal += calcularTiempoEfectivo(inicioProceso, ahora);
    }

    return tiempoTotal;
  }
  int calcularTiempoEfectivo(DateTime inicio, DateTime fin) {
    int minutos = 0;
    DateTime temp = inicio;

    while (temp.isBefore(fin)) {
      // Excluye el tiempo entre 1 pm y 2 pm
      if (temp.hour >= 13 && temp.hour < 14) {
        temp = DateTime(temp.year, temp.month, temp.day, 14, 0);
      } else {
        DateTime siguienteMinuto = temp.add(Duration(minutes: 1));
        if (siguienteMinuto.isAfter(fin)) {
          siguienteMinuto = fin;
        }
        minutos += siguienteMinuto.difference(temp).inMinutes;
        temp = siguienteMinuto;
      }
    }

    return minutos;
  }
  void exportToExcel() async {
    var excel = Excel.createExcel(); // Crear una instancia de Excel

    // Obtener los datos que deseas exportar
    List<Cotizacion> cotizaciones = await getCotizacion('GENERADA');

    // Crear una hoja en el archivo de Excel
    Sheet sheetObject = excel['Cotizaciones'];

    // Agregar encabezados
    sheetObject.appendRow(['COTIZACIÓN', 'O.T.', 'PEDIDO', 'CLIENTE', 'No. PARTE/PLANO', 'ARTICULO', 'CANTIDAD', 'ESTATUS', 'OPERADOR', 'TIEMPO ESTIMADO', 'FECHA DE ENTREGA']);

    // Llenar las filas con datos
    for (var cotizacion in cotizaciones) {
      for (var producto in cotizacion.producto!.where((producto) => producto.estatus != 'CANCELADO')) {
        sheetObject.appendRow([
          cotizacion.number ?? '',
          producto.ot ?? '',
          producto.pedido ?? '',
          cotizacion.clientes!.name.toString(),
          producto.parte ?? '',
          producto.articulo ?? '',
          producto.cantidad.toString(),
          producto.estatus ?? '',
          producto.operador ?? '',
          await calcularTiempoEstimado(producto.id!).then((value) => value['total'] ?? 'N/A'),
          producto.fecha ?? '',
        ]);
      }
    }
    // Guardar el archivo de Excel en el almacenamiento del dispositivo
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      Get.snackbar('Error', 'No se pudo obtener el directorio de descargas');
      return;
    }

    final filePath = '${directory.path}/produccion.xlsx';
    final fileBytes = excel.encode(); // Obtener los bytes del archivo
    final file = File(filePath);
    await file.writeAsBytes(fileBytes!); // Escribir los bytes en el archivo

    // Mostrar una notificación o mensaje al usuario
    Get.snackbar('DOCUMENTO DESCARGADO EN:', '${filePath}', backgroundColor: Colors.green,
      colorText: Colors.white,);
    print('Archivo Excel guardado en: $filePath');
  }
}