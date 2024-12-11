import 'package:flutter/material.dart';  // Importa widgets y utilidades principales de flutter
import 'package:get/get.dart'; // Importa para manjeo de estado y navegación en flutter
import 'package:get_storage/get_storage.dart';  // Importa para almacenamiento de datos
import 'package:maquinados_correa/src/models/cotizacion.dart';  // Importa el modelo cotización
import 'package:maquinados_correa/src/models/producto.dart';  // Importa el modelo producto
import 'package:maquinados_correa/src/models/tiempo.dart';  // Importa el modelo tiempo
import 'package:maquinados_correa/src/models/user.dart';  // Importa el modelo user
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';  // Importa el proveedor de cotización
import 'package:maquinados_correa/src/providers/producto_provider.dart';  // Importa el proveedor de producto
import 'package:maquinados_correa/src/providers/tiempo_provider.dart';  // Importa el proveedor de tiempo

class CalidadTabController extends GetxController {  // Controlador que gestiona lógica de la pagina calidadTabPage
  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;  // Obtiene y almacena el usuario actual desde almacenamiento

  CotizacionProvider cotizacionProvider = CotizacionProvider();  // Instancia del proveedor de cotizaciones
  ProductoProvider productoProvider = ProductoProvider();  // Instancia del proveedor de producto
  TiempoProvider tiempoProvider = TiempoProvider();  // Instancia del proveedor de tiempo

  List<String> status = <String>['GENERADA'].obs;  // Lista reactiva que contiene los status posibles

  Future<List<Cotizacion>> getCotizacion(String status) async {  // Metodo asíncrono para obtener cotizaciones segun status
    return await cotizacionProvider.findByStatus(status);  // Consulta proveedor y devuelve la lista cotizaciones
  }

  void signOut() {  // Método para cerrar sesión
    GetStorage().remove('user');  // Elimina el usuario del almacenamiento
    Get.offNamedUntil('/', (route) => false); //Elimina el historial de las pantallas y regresa al login
  }

  void goToPerfilPage() {  // Método para navegar a la página de perfil
    Get.toNamed('/profile/info');  // Navega a la ruta de perfil
  }

  void goToRoles() {  // Método para navegar a la página de roles
    Get.offNamedUntil('/roles', (route) => false);  // Elimina el historial y navega a la página de roles
  }

  void goToDetalles(Cotizacion cotizacion) {  // Método para navegar a los detalles de producción de una cotización
    Get.toNamed('/produccion/orders/detalles_produccion',
        arguments: {'cotizacion': cotizacion.toJson()});  // Pasa la cotización como argumento
  }

  void goToOt(Producto producto) {  // Método para navegar a la liberación de calidad de un producto
    print('Producto seleccionado: $producto');  // Muestra en consola el producto seleccionado
    Get.toNamed('/calidad/orders/liberacion',
        arguments: {'producto': producto.toJson()});  // Pasa el producto como argumento
  }

  int calcularTiempoTrabajadoConProcesosSimultaneos(List<Tiempo> tiempos) {
    int tiempoTotal = 0; // Acumula el tiempo total de todos los procesos
    Map<String, DateTime?> inicioProcesos = {}; // Almacena el inicio por cada proceso
    Map<String, DateTime?> suspensiones = {};  // Almacena suspensiones por cada proceso

    tiempos.sort((a, b) => DateTime.parse(a.time!).compareTo(DateTime.parse(b.time!)));  // Ordenar los tiempos cronológicamente

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
  int calcularTiempoEntreFechas(DateTime inicio, DateTime fin) {
    int tiempoTrabajado = 0;
    DateTime actual = inicio;

    while (actual.isBefore(fin)) {
      if (!esHorarioExcluido(actual)) {
        DateTime finHora = DateTime(
            actual.year, actual.month, actual.day, actual.hour, 59, 59);
        if (finHora.isAfter(fin)) finHora = fin;
        int minutosEnEstaHora = finHora.difference(actual).inMinutes + 1;
        tiempoTrabajado += minutosEnEstaHora;
      }
      actual = DateTime(actual.year, actual.month, actual.day,
          actual.hour + 1); // Avanza a la siguiente hora
    }

    return tiempoTrabajado;
  }

  bool esHorarioExcluido(DateTime fecha) {
    int hora = fecha.hour;
    return hora >= 13 && hora < 14; // Excluye el tiempo entre 1 pm y 2 pm
  }

  Future<Map<String, String>> calcularTiempoEstimado(String productoId) async {
    try {
      List<Tiempo> tiempos =
          await tiempoProvider.getTiemposByProductId(productoId);
      print(
          'Tiempos obtenidos para el producto $productoId: ${tiempos.length}');
      if (tiempos.isEmpty) {
        return {'total': '', 'actual': ''};
      }
      int tiempoTotalTrabajado = calcularTiempoTrabajadoConProcesosSimultaneos(tiempos);
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
        tiempoTotal =
            0; // Reiniciar el tiempo total al iniciar un nuevo proceso
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
}
