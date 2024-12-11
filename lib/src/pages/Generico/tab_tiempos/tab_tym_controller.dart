import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/promedio.dart';
import 'package:maquinados_correa/src/models/tiempo.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:maquinados_correa/src/providers/promedio_provider.dart';
import 'package:maquinados_correa/src/providers/tiempo_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';

class TabTymController extends GetxController{
  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  var cotizaciones = Future.value(<Cotizacion>[]).obs; // Usamos Future.value para inicializar la lista de cotizaciones

  TextEditingController clienteController = TextEditingController();

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  ProductoProvider productoProvider = ProductoProvider();
  TiempoProvider tiempoProvider = TiempoProvider();
  PromedioProvider promedioProvider = PromedioProvider();

  List<String> status = <String>['GENERADA'].obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startAutoRefresh();
    refreshCotizaciones(); // Recargar cotizaciones al iniciar
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      refreshCotizaciones();
    });
  }

  void refreshCotizaciones() async {
    cotizaciones.value = getCotizacion('GENERADA');
  }

  Future<List<Cotizacion>> getCotizacion(String status) async {
    return await cotizacionProvider.findByStatus(status);
  }

  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); //Elimina el historial de las pantallas y regresa al login
  }

  void goToPerfilPage() {
    Get.toNamed('/profile/info');
  }

  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }


  void goToRegisterPage() {
    Get.toNamed('/tym/newOperador');
  }

  Future<List<Map<String, String>>> obtenerTiemposEstimados(String parte) async {
    try {


      String parteCodificada = Uri.encodeComponent(parte);

      List<Promedio> promedios = await promedioProvider.findByStatus(parteCodificada);

      return promedios.map((promedio) => {
        'proceso': promedio.proceso ?? '',
        'tiempo': promedio.tiempo ?? '00:00'
      }).toList();
    } catch (e) {
      print('Error al obtener tiempos estimados: $e');
      return [];
    }
  }

  int calcularTiempoTrabajadoConProcesosSimultaneos(List<Tiempo> tiempos) {
    int tiempoTotal = 0; // Acumula el tiempo total de todos los procesos
    Map<String, DateTime?> inicioProcesos = {}; // Almacena el inicio por cada proceso
    Map<String, DateTime?> suspensiones = {};  // Almacena suspensiones por cada proceso

    // Ordenar los tiempos cronológicamente
    tiempos.sort((a, b) => DateTime.parse(a.time!).compareTo(DateTime.parse(b.time!)));

    for (var tiempo in tiempos) {
      if (tiempo.time == null) continue;
      DateTime fechaTiempo = DateTime.parse(tiempo.time!);
      String? idProceso = tiempo.proceso; // Usar el identificador único del proceso

      print('Procesando tiempo: ${tiempo.time}, Estado: ${tiempo.estado}, Proceso: $idProceso');

      switch (tiempo.estado) {
        case 'INICIO':
          inicioProcesos[idProceso!] = fechaTiempo;
          suspensiones.remove(idProceso); // Limpiar cualquier suspensión previa
          print('Inicio del proceso "$idProceso" en: $fechaTiempo');
          break;

        case 'SUSPENDIDO':
          if (inicioProcesos.containsKey(idProceso) && inicioProcesos[idProceso] != null) {
            // Calcular tiempo efectivo del proceso suspendido
            int tiempoParcial = calcularTiempoEfectivo(inicioProcesos[idProceso]!, fechaTiempo);
            tiempoTotal += tiempoParcial;
            suspensiones[idProceso!] = fechaTiempo;
            print('Proceso "$idProceso" suspendido en: $fechaTiempo. Tiempo acumulado: $tiempoTotal');
            inicioProcesos[idProceso] = null; // Detener el proceso activo
          }
          break;

        case 'REANUDAR':
          if (suspensiones.containsKey(idProceso)) {
            inicioProcesos[idProceso!] = fechaTiempo;
            suspensiones.remove(idProceso); // Eliminar la suspensión
            print('Proceso "$idProceso" reanudado en: $fechaTiempo');
          }
          break;

        case 'TERMINÓ':
          if (inicioProcesos.containsKey(idProceso) && inicioProcesos[idProceso] != null) {
            // Calcular tiempo efectivo del proceso terminado
            int tiempoParcial = calcularTiempoEfectivo(inicioProcesos[idProceso]!, fechaTiempo);
            tiempoTotal += tiempoParcial;
            print('Proceso "$idProceso" terminado en: $fechaTiempo. Tiempo parcial: $tiempoParcial, Total: $tiempoTotal');
            inicioProcesos.remove(idProceso); // Eliminar el proceso terminado
          }
          break;
      }
    }

    // Manejar procesos en curso al final
    DateTime ahora = DateTime.now();
    for (var idProceso in inicioProcesos.keys) {
      if (inicioProcesos[idProceso] != null && !suspensiones.containsKey(idProceso)) {
        // Calcular tiempo efectivo para procesos en curso
        int tiempoParcial = calcularTiempoEfectivo(inicioProcesos[idProceso]!, ahora);
        tiempoTotal += tiempoParcial;
        print('Proceso "$idProceso" en curso hasta: $ahora. Tiempo final: $tiempoParcial, Total: $tiempoTotal');
      }
    }

    return tiempoTotal;
  }

  Future<Map<String, String>> calcularTiempoTotal(String productoId, String parte) async {
    try {
      List<Tiempo> tiempos = await tiempoProvider.getTiemposByProductId(productoId);
      if (tiempos.isEmpty) {
        return {'total': '', 'estimado': '', 'actual': ''};
      }

      // Calcula el tiempo total trabajado
      int tiempoTotalTrabajado = calcularTiempoTotalConProcesos(tiempos);

      // Calcula el tiempo del último proceso activo
      int tiempoProcesoActual = calcularTiempoProcesoActual(tiempos);

      List<Map<String, String>> tiemposEstimados = await obtenerTiemposEstimados(parte);

      String formatTiempo(int minutos) {
        int horas = minutos ~/ 60;
        int minutosRestantes = minutos % 60;
        return '${horas.toString().padLeft(2, '0')}:${minutosRestantes.toString().padLeft(2, '0')}';
      }

      String tiempoEstimado = '';
      if (tiemposEstimados.isNotEmpty) {
        int tiempoTotalEstimado = tiemposEstimados.fold(0, (sum, tiempo) {
          List<String> partes = tiempo['tiempo']!.split(':');
          return sum + int.parse(partes[0]) * 60 + int.parse(partes[1]);
        });
        tiempoEstimado = formatTiempo(tiempoTotalEstimado);
      }

      // Retorna el mapa con el tiempo total y el tiempo del último proceso activo
      return {
        'total': formatTiempo(tiempoTotalTrabajado),
        'actual': formatTiempo(tiempoProcesoActual),
        'estimado': tiempoEstimado
      };
    } catch (e) {
      print('Error al calcular tiempo: $e');
      return {'total': 'Error', 'actual': 'Error', 'estimado': ''};
    }
  }
  int calcularTiempoProcesoIndividual(List<Tiempo> tiempos) {
    int tiempoTotal = 0;
    DateTime? inicioProceso;
    DateTime? inicioSuspension;

    // Ordenar los tiempos cronológicamente
    tiempos.sort((a, b) => DateTime.parse(a.time!).compareTo(DateTime.parse(b.time!)));

    for (var i = 0; i < tiempos.length; i++) {
      var tiempo = tiempos[i];
      if (tiempo.time == null) continue;
      DateTime fechaTiempo = DateTime.parse(tiempo.time!);

      print('Procesando tiempo: ${tiempo.time}, Estado: ${tiempo.estado}');

      switch (tiempo.estado) {
        case 'INICIO':
          inicioProceso = fechaTiempo;
          inicioSuspension = null;
          print('Inicio de proceso: $inicioProceso');
          break;

        case 'SUSPENDIDO':
          if (inicioProceso != null) {
            // Calcula tiempo trabajado hasta el momento de la suspensión
            tiempoTotal += calcularTiempoEfectivo(inicioProceso, fechaTiempo);
            inicioSuspension = fechaTiempo;
            print('Proceso suspendido en: $inicioSuspension. Tiempo acumulado: $tiempoTotal');
            inicioProceso = null;
          }
          break;

        case 'REANUDAR':
          if (inicioSuspension != null) {
            // Reactiva el proceso desde el momento de la reanudación
            inicioProceso = fechaTiempo;
            inicioSuspension = null;
            print('Proceso reanudado en: $fechaTiempo');
          }
          break;

        case 'TERMINÓ':
          if (inicioProceso != null) {
            int tiempoParcial = calcularTiempoEfectivo(inicioProceso, fechaTiempo);
            tiempoTotal += tiempoParcial;
            print('Proceso terminado en: $fechaTiempo. Tiempo parcial: $tiempoParcial, Total: $tiempoTotal');
            inicioProceso = null;
          }
          break;
      }
    }

    // Si hay un proceso en curso, calcula el tiempo hasta el momento actual
    if (inicioProceso != null && inicioSuspension == null) {
      DateTime ahora = DateTime.now();
      int tiempoFinal = calcularTiempoEfectivo(inicioProceso, ahora);
      tiempoTotal += tiempoFinal;
      print('Proceso en curso hasta: $ahora. Tiempo final: $tiempoFinal, Total: $tiempoTotal');
    }

    return tiempoTotal;
  }

  int calcularTiempoProcesoActual(List<Tiempo> tiempos) {
    // Ordenamos todos los tiempos cronológicamente
    tiempos.sort((a, b) => DateTime.parse(a.time!).compareTo(DateTime.parse(b.time!)));

    // Identificamos el último tiempo registrado (más reciente)
    Tiempo? ultimoTiempo = tiempos.isNotEmpty ? tiempos.last : null;

    if (ultimoTiempo != null && ultimoTiempo.proceso != null) {
      // Filtramos los tiempos del proceso correspondiente al más reciente
      List<Tiempo> tiemposUltimoProceso = tiempos.where((t) => t.proceso == ultimoTiempo.proceso).toList();

      // Calculamos el tiempo trabajado solo para el último proceso actualizado
      int tiempoProceso = calcularTiempoProcesoIndividual(tiemposUltimoProceso);

      print('Proceso más reciente: ${ultimoTiempo.proceso}, Tiempo: $tiempoProceso minutos');
      return tiempoProceso;
    }

    return 0; // Si no hay tiempos registrados, regresamos 0
  }


  int calcularTiempoEfectivo(DateTime inicio, DateTime fin) {
    int minutos = 0;
    DateTime actual = inicio;

    while (actual.isBefore(fin)) {
      // Si estamos en la hora de comida (13:00 - 14:00), saltamos a las 14:00
      if (actual.hour == 13 && actual.minute == 0) {
        actual = DateTime(actual.year, actual.month, actual.day, 14, 0);
        continue;
      }

      // Calculamos el siguiente minuto
      DateTime siguiente = actual.add(Duration(minutes: 1));

      // Si el siguiente minuto está después del fin, usamos el fin
      if (siguiente.isAfter(fin)) {
        siguiente = fin;
      }

      // Si no estamos en la hora de comida, sumamos el tiempo
      if (actual.hour != 13) {
        minutos += siguiente
            .difference(actual)
            .inMinutes;
      }

      actual = siguiente;
    }

    return minutos;
  }

  Map<String, List<Tiempo>> agruparTiemposPorProceso(List<Tiempo> tiempos) {
    Map<String, List<Tiempo>> tiemposPorProceso = {};

    for (var tiempo in tiempos) {
      if (tiempo.proceso != null) {
        tiemposPorProceso.putIfAbsent(tiempo.proceso!, () => []).add(tiempo);
      }
    }

    return tiemposPorProceso;
  }

  int calcularTiempoTotalConProcesos(List<Tiempo> tiempos) {
    // Agrupa los tiempos por proceso
    Map<String, List<Tiempo>> tiemposPorProceso = agruparTiemposPorProceso(tiempos);

    int tiempoTotal = 0;

    // Calcula el tiempo total para cada grupo de tiempos (por proceso)
    tiemposPorProceso.forEach((proceso, tiemposProceso) {
      tiempoTotal += calcularTiempoTrabajadoConProcesosSimultaneos(tiemposProceso); // Reutiliza tu método existente
    });

    return tiempoTotal;
  }


  final logger = Logger(
    printer: PrettyPrinter(),
    filter: ProductionFilter(), // Solo registra mensajes de nivel de advertencia o superior en producción
  );

  String formatTiempo(int minutos) {
    int horas = minutos ~/ 60;
    int minutosRestantes = minutos % 60;
    return '${horas.toString().padLeft(2, '0')}:${minutosRestantes.toString().padLeft(2, '0')}';
  }
}

