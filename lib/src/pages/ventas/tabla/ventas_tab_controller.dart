import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/promedio.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/tiempo.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:excel/excel.dart';
import 'package:maquinados_correa/src/providers/promedio_provider.dart';
import 'package:maquinados_correa/src/providers/tiempo_provider.dart';
import 'package:maquinados_correa/src/utils/grafic_circle.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class VentasTabController extends GetxController{

  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  var tiemposEstimados = <Promedio>[].obs;
  static const double costoPorHora = 180.0;

  RxInt totalCots = 0.obs;
  RxInt cotCerradas = 0.obs;
  RxInt cotIng = 0.obs;
  RxInt cotOpen = 0.obs;
  var solicitada = 0.0.obs;
  var aceptada = 0.0.obs;
  RxList<GDPData> chartData = <GDPData>[].obs;
  RxList<GDPData> chartData2 = <GDPData>[].obs;
  RxList<GDPData> chartDataClientes = <GDPData>[].obs;
  RxList<CotData> chartDataClientes2 = <CotData>[].obs;

  TextEditingController clienteController = TextEditingController();

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  ProductoProvider productoProvider = ProductoProvider();
  TiempoProvider tiempoProvider = TiempoProvider();
  PromedioProvider promedioProvider = PromedioProvider();


  var totalt = 0.0.obs;
  List<String> status = <String>['GENERADA'].obs;

  @override
  void onInit() {
    super.onInit();
    obtenerTotalOTs();
    obtenerIngCot();
    obtenerIngresosVendedores();
    obtenerIngresosPorCliente();
    obtenerCotizacionesAceptadas();
    obtenerCotizacionesPorCliente();
  }
  void loadData() async {
    try {
      await obtenerTotalOTs();
      await obtenerIngCot();
      await obtenerIngresosVendedores();
      await obtenerIngresosPorCliente();
      await obtenerCotizacionesPorCliente();
      await obtenerCotizacionesAceptadas();();
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }
  Future<List<Cotizacion>> getCotizacion(String status) async {
    return await cotizacionProvider.findByStatusP(status);

  }

  Future<void> obtenerTotalOTs() async {
    ResponseApi response = await cotizacionProvider.getCotCount();

    if (response != null && (response.success ?? false)) {
      int totalCotizaciones = int.parse(response.data['total_cotizaciones'] ?? '0'); // Convierte el valor a int
      int cerradas = int.parse(response.data['cotizaciones_cerradas'] ?? '0');
      int abiertas = int.parse(response.data['cotizaciones_confirmadas_generadas'] ?? '0');

      totalCots.value = totalCotizaciones; // Asigna el valor a la variable observada RxInt
      cotCerradas.value = cerradas;
      cotOpen.value = abiertas;
    } else {
      print('Error al obtener total cotizaciones: ${response?.message}');
    }
  }
  Future<void> obtenerIngCot() async {
    ResponseApi response = await cotizacionProvider.getCotIng();

    if (response != null && (response.success ?? false)) {
      int totalIngreso = 0; // Variable para almacenar el total de ingresos

      // Recorre cada objeto de la lista de datos y suma los ingresos
      for (var item in response.data) {
        int ingreso = item['ingresos'] ?? '0'; // Convierte a int
        totalIngreso += ingreso; // Suma al total
      }

      cotIng.value = totalIngreso; // Asigna el total a la variable RxInt

    } else {
      print('Error al obtener ingreso de cotizaciones: ${response?.message}');
    }
  }

  Future<void> obtenerIngresosVendedores() async {
    var response = await cotizacionProvider.getCotIng(); // Llamas a tu backend

    if (response.success! && response.data != null) {


      chartData.value = []; // Reiniciar los datos previos

      // Asegúrate de que response.data sea una lista
      for (var item in response.data) {
        String vendedor = item['vendedor_nombre'] ?? 'Desconocido'; // Verificar nulos
        double ingresos = double.tryParse(item['ingresos']?.toString() ?? '0') ?? 0; // Convertir a double y verificar nulos


        // Agregar al gráfico solo si hay datos válidos
        chartData.add(GDPData(vendedor, ingresos, asignarColor(vendedor)));
      }

      if (chartData.isEmpty) {
        print('No se encontraron ingresos para mostrar.');
      }
    } else {
      print('Error al obtener ingresos por vendedor: ${response.message}');
    }
  }
  Future<void> obtenerCotizacionesAceptadas() async {
    var response = await cotizacionProvider.getCotCount(); // Llamas a tu backend para obtener los datos

    if (response.success! && response.data != null) {
      print('Datos recibidos: ${response.data}'); // Verifica los datos recibidos

      chartData2.value = []; // Reiniciar los datos previos

      int totalCotizaciones = 0;
      int cotizacionesAceptadas = 0;
      int cotizacionesNoAceptadas = 0;

      // Verifica si 'response.data' es un 'Map' en lugar de 'List'
      if (response.data is Map<String, dynamic>) {
        var item = response.data; // Trata los datos como un mapa

        // Acceder a los valores dentro del mapa
        int total = int.parse(item['total_cotizaciones']?.toString() ?? '0');
        int aceptadas = int.parse(item['cotizaciones_confirmadas_generadas_cerradas']?.toString() ?? '0');

        totalCotizaciones = total;
        cotizacionesAceptadas = aceptadas;
      }
      // Calcular cotizaciones no aceptadas
      cotizacionesNoAceptadas = totalCotizaciones - cotizacionesAceptadas;
      // **Calcular los porcentajes**
      double porcentajeAceptadas = (cotizacionesAceptadas / totalCotizaciones) * 100;
      double porcentajeNoAceptadas = (cotizacionesNoAceptadas / totalCotizaciones) * 100;

      // Agregar al gráfico los porcentajes
      chartData2.add(GDPData('% Aceptado', porcentajeAceptadas, Colors.green));
      chartData2.add(GDPData('% No Aceptado', porcentajeNoAceptadas, Colors.red));

      if (chartData2.isEmpty) {
        print('No se encontraron cotizaciones para mostrar.');
      }
    } else {
      print('Error al obtener cotizaciones: ${response.message}');
    }
  }
  Map<String, Color> _colorPorVendedor = {
    'Israel Correa O.': Colors.amber,
    'David Hernandez C.': Colors.blue,
    'Alejandro Correa O.': Colors.orange,
    'Amado Correa': Colors.indigoAccent,
  };

  Color asignarColor(String vendedor) {
    // Devuelve el color personalizado si el vendedor está en el mapa, de lo contrario, un color predeterminado
    return _colorPorVendedor[vendedor] ?? Colors.grey;
  }
  void actualizarGraficaClientes(Map<String, double> ingresosPorCliente) {
    chartDataClientes.value = [];  // Limpia datos previos
    ingresosPorCliente.forEach((cliente, ingresos) {
      chartDataClientes.add(GDPData(cliente, ingresos, asignarColor(cliente)));
    });
  }
  Future<void> obtenerIngresosPorCliente() async {
    var response = await cotizacionProvider.getIngresosClientes();

    if (response.success! && response.data != null) {
      Map<String, double> ingresosPorCliente = {};
      response.data.forEach((item) {
        String cliente = item['cliente_nombre'].toString();
        double ingresos = 0.0;

        // Manejo seguro para convertir 'ingresos' a double
        if (item['ingresos'] is int) {
          ingresos = (item['ingresos'] as int).toDouble();  // Convierte int a double si es necesario
        } else if (item['ingresos'] is double) {
          ingresos = item['ingresos'];  // Si ya es double, úsalo directamente
        }
        print('cliente: $cliente, Ingresos: $ingresos'); // Imprimir para depuración
        ingresosPorCliente[cliente] = ingresos;  // Añade los ingresos a la lista
      });

      actualizarGraficaClientes(ingresosPorCliente);  // Actualiza los datos de la gráfica
    } else {
      print('Error al obtener ingresos por cliente: ${response.message}');
    }
  }
  void actualizarCotClientes(String cliente, String solicitada, String aceptada) {
    chartDataClientes2.add(CotData(
      cliente: cliente,
      solicitada: double.parse(solicitada), // Convertir a double
      aceptada: double.parse(aceptada),     // Convertir a double
    ));
  }
  Future<void> obtenerCotizacionesPorCliente() async {
    var response = await cotizacionProvider.getCotClientes();

    if (response.success! && response.data != null) {
      // Limpiar los datos anteriores si es necesario
      chartDataClientes2.clear();

      response.data.forEach((item) {
        String cliente = item['cliente_nombre'].toString();
        String solicitada = item['total_cotizaciones'].toString();
        String aceptada = item['cotizaciones_confirmadas_generadas_cerradas'].toString();

        // Imprimir para depuración
        print('cliente: $cliente, solicitadas: $solicitada, aceptadas: $aceptada');

        // Actualiza los datos de la gráfica dentro del bucle
        actualizarCotClientes(cliente, solicitada, aceptada);
      });
    } else {
      print('Error al obtener ingresos por cliente: ${response.message}');
    }
  }

  Future<List<Map<String, String>>> obtenerTiemposEstimados(String parte) async {
    try {
      List<Promedio> promedios = await promedioProvider.findByStatus(parte);

      return promedios.map((promedio) => {
        'proceso': promedio.proceso ?? '',
        'tiempo': promedio.tiempo ?? '00:00'
      }).toList();

    } catch (e) {
      print('Error al obtener tiempos estimados: $e');
      return [];
    }
  }
  int calcularTiempoTrabajado(List<Tiempo> tiempos) {
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
            tiempoTotal += calcularTiempoEfectivo(inicioProceso, fechaTiempo);
            inicioSuspension = fechaTiempo;
            print('Proceso suspendido en: $inicioSuspension. Tiempo acumulado: $tiempoTotal');
            inicioProceso = null;
          }
          break;

        case 'REANUDAR':
          if (inicioSuspension != null) {
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

    // Si hay un proceso en curso
    if (inicioProceso != null && inicioSuspension == null) {
      DateTime ahora = DateTime.now();
      int tiempoFinal = calcularTiempoEfectivo(inicioProceso, ahora);
      tiempoTotal += tiempoFinal;
      print('Proceso en curso hasta: $ahora. Tiempo final: $tiempoFinal, Total: $tiempoTotal');
    }

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

  double calcularCostoTotal(int minutosTrabajados) {
    // Convierte minutos a horas y calcula el costo
    double horasTrabajadas = minutosTrabajados / 60.0;
    return horasTrabajadas * costoPorHora;
  }

  Future<Map<String, String>> calcularTiempoTotal(String productoId, String parte) async {
    try {
      List<Tiempo> tiempos = await tiempoProvider.getTiemposByProductId(productoId);
      if (tiempos.isEmpty) {
        return {'total': '', 'estimado': '', 'actual': '', 'costo': ''};
      }
      int tiempoTotalTrabajado = calcularTiempoTrabajado(tiempos);
      double costoTotal = calcularCostoTotal(tiempoTotalTrabajado);

      // Obtén el tiempo actual y estimado
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

      return {
        'total': formatTiempo(tiempoTotalTrabajado),
        'actual': formatTiempo(tiempoProcesoActual),
        'estimado': tiempoEstimado,
        'costo': '\$${costoTotal.toStringAsFixed(2)}', // Formato a dos decimales
      };
    } catch (e) {
      print('Error al calcular tiempo: $e');
      return {'total': 'Error', 'actual': 'Error', 'estimado': '', 'costo': 'Error'};
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
      } else if (tiempo.estado == 'TERMINÓ') {
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
  void goToNewVendedorPage(){
    Get.toNamed('/ventas/newVendedor');
  }
  void goToNewClientePage(){
    Get.toNamed('/ventas/newClient');
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
  void goToPrice(Producto producto) {
    print('Producto seleccionado: $producto');
    Get.toNamed('/ventas/update/price', arguments: {'producto': producto.toJson()});
  }
  Future<List<Cotizacion>> getCotizaciones() async {
    return await cotizacionProvider.getExcel();
  }
  void exportToExcel() async {
    var excel = Excel.createExcel(); // Crear una instancia de Excel

    // Obtener los datos que deseas exportar
    List<Cotizacion> cotizaciones = await getCotizaciones();

    // Crear una hoja en el archivo de Excel
    Sheet sheetObject = excel['Cotizaciones'];

    // Agregar encabezados
    sheetObject.appendRow(['COTIZACIÓN','TOTAL','FECHA','REQUERIMIENTO', 'CLIENTE', 'TIEMPO DE ENTREGA', 'VENDEDOR','STATUS']);

    // Llenar las filas con datos
    for (var cotizacion in cotizaciones) {
      double totalCotizacion = 0.0; // Variable para acumular el total de la cotización

      for (var producto in cotizacion.producto!.where((producto) => producto.estatus != 'CANCELADO')) {
        totalCotizacion += producto.total ?? 0.0; // Acumular el total de cada producto
      }
        sheetObject.appendRow([
          cotizacion.number ?? '',
          '\$${totalCotizacion.toStringAsFixed(2)}',
          cotizacion.fecha ?? '',
          cotizacion.req ?? '',
          cotizacion.clientes!.name.toString(),
          cotizacion.ent ?? '',
          cotizacion.vendedores!.name.toString(),
          cotizacion.status,
        ]);

    }
    // Guardar el archivo de Excel en el almacenamiento del dispositivo
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      Get.snackbar('Error', 'No se pudo obtener el directorio de descargas');
      return;
    }

    final filePath = '${directory.path}/cotizaciones.xlsx';
    final fileBytes = excel.encode(); // Obtener los bytes del archivo
    final file = File(filePath);
    await file.writeAsBytes(fileBytes!); // Escribir los bytes en el archivo

    // Mostrar una notificación o mensaje al usuario
    Get.snackbar('DOCUMENTO DESCARGADO EN:', '${filePath}', backgroundColor: Colors.green,
      colorText: Colors.white,);
    print('Archivo Excel guardado en: $filePath');
  }
}
