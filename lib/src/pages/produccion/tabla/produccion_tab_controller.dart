import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/promedio.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/tiempo.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:maquinados_correa/src/providers/promedio_provider.dart';
import 'package:maquinados_correa/src/providers/tiempo_provider.dart';
import 'package:excel/excel.dart';
import 'package:maquinados_correa/src/utils/grafic_circle.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProduccionTabController extends GetxController{

  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  RxInt totalOTs = 0.obs;
  RxInt otCerradas = 0.obs;
  RxInt productsFab = 0.obs;
  RxInt productsrr = 0.obs;
  var totalCompleted = 0.0.obs;
  var totalRechazo = 0.0.obs;
  var totalRetrabajo = 0.0.obs;
  RxInt totalEntregadas = 0.obs; // Total de OT entregadas
  RxInt entregadasEnTiempo = 0.obs; // OT entregadas a tiempo
  RxInt entregadasFueraDeTiempo = 0.obs; // OT entregadas fuera de tiempo
  var totalProducts = 0.obs;
  var productsEnTiempo = 0.obs;
  var productsFueraDeTiempo = 0.obs;
  RxList<GDPData> chartData = <GDPData>[].obs;  // Para el gráfico de eficacia
  RxList<GDPData> chartData2 = <GDPData>[].obs; // Para el gráfico de OT entregadas
  RxList<SalesData> chartData3 = <SalesData>[].obs; // Para el gráfico combinado
  RxList<GDPData> chartData4 = <GDPData>[].obs; // Para el gráfico de OT entregadas
  RxBool isYearFilterSelected = false.obs; // Controla si el filtro de año está seleccionado

  TextEditingController clienteController = TextEditingController();

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  ProductoProvider productoProvider = ProductoProvider();
  TiempoProvider tiempoProvider = TiempoProvider();
  PromedioProvider promedioProvider = PromedioProvider();

  List<String> status = <String>['GENERADA'].obs;
  Future<List<Cotizacion>> getCotizacion(String status) async {
    return await cotizacionProvider.findByStatus(status);

  }
  @override
  void onInit() {
    super.onInit();
    obtenerTotalOTs();
    obtenerLibOTs();
    obtenerTotalProducts();
    obtenerProductsrr();
    obtenerDatosPorA();
  }
  void loadData() async {
    try {
      await obtenerTotalOTs();
      await obtenerLibOTs();
      await obtenerTotalProducts();
      await obtenerProductsrr();
      await obtenerDatosPorA();
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }
  void actualizarDatosGraficoCombinado(int totalCompletados, int totalRechazos, int totalRetrabajos, String month) {
    chartData3.add(SalesData(
      month: month,
      completed: totalCompletados.toDouble(),
      rejected: totalRechazos.toDouble(),
      rework: totalRetrabajos.toDouble(),
    ));
  }

  void actualizarGrafica2() {
    chartData2.value = []; // Limpiar datos previos

    // Asegúrate de que los valores de entregadasEnTiempo y entregadasFueraDeTiempo sean válidos
    if (totalEntregadas.value > 0) {
      // Imprimir los valores para depurar
      print('Entregadas a tiempo: ${entregadasEnTiempo.value}');
      print('Entregadas fuera de tiempo: ${entregadasFueraDeTiempo.value}');

      // Solo agregar si los valores son mayores que 0
      if (entregadasEnTiempo.value > 0) {
        chartData2.add(GDPData('Ordenes a tiempo', entregadasEnTiempo.value.toDouble(), Colors.green));
      }
      if (entregadasFueraDeTiempo.value > 0) {
        chartData2.add(GDPData('Ordenes fuera de tiempo', entregadasFueraDeTiempo.value.toDouble(), Colors.red));
      }
    } else {
      // Si no hay OT entregadas, puedes agregar un mensaje o un valor predeterminado
      chartData2.add(GDPData('Sin OT entregadas', 1.0, Colors.grey));
    }
  }
  void actualizarGrafica4() {
    chartData4.value = []; // Limpiar datos previos

    if (totalProducts.value > 0) {
      // Imprimir los valores para depurar
      print('Produccion a tiempo: ${productsEnTiempo.value}');
      print('Produccion fuera de tiempo: ${productsFueraDeTiempo.value}');

      // Solo agregar si los valores son mayores que 0
      if (productsEnTiempo.value > 0) {
        chartData4.add(GDPData('Piezas a tiempo', productsEnTiempo.value.toDouble(), Colors.green));
      }
      if (productsFueraDeTiempo.value > 0) {
        chartData4.add(GDPData('Piezas fuera de tiempo', productsFueraDeTiempo.value.toDouble(), Colors.red));
      }
    }
  }
  void actualizarGrafica(double porcentajeCorrectos, double porcentajeRechazo, double porcentajeRetrabajo) {
    chartData.value = []; // Limpiar datos previos

    // Solo agregar elementos si el porcentaje es mayor que 0
    if (porcentajeRechazo > 0) {
      chartData.add(GDPData('Piezas con rechazo', porcentajeRechazo, Colors.red));
    }
    if (porcentajeRetrabajo > 0) {
      chartData.add(GDPData('Piezas con retrabajo', porcentajeRetrabajo, Colors.orange));
    }
    if (porcentajeCorrectos > 0) {
      chartData.add(GDPData('Piezas correctas', porcentajeCorrectos, Colors.green));
    }
  }
  // Filtrar datos por mes
  void obtenerDatosPorMes() async {
    isYearFilterSelected.value = false; // Establecer que se seleccionó el mes

    var response = await productoProvider.getlibProducts(); // Llamas a tu backend

    if (response.success!) {
      // Filtra los datos solo para el mes actual
      DateTime now = DateTime.now();
      String currentMonth = DateFormat('yyyy-MM').format(now); // Obtiene el mes actual en formato 'YYYY-MM'

      var filteredData = response.data.where((item) {
        String itemMonth = DateFormat('yyyy-MM').format(DateTime.parse(item['month']));
        return itemMonth == currentMonth; // Compara solo el mes y año
      }).toList();


      if (filteredData.isNotEmpty) {
        int totalCompletados = int.parse(filteredData[0]['completed_products']);
        int totalRechazos = int.parse(filteredData[0]['rech_products']);
        int totalRetrabajos = int.parse(filteredData[0]['ret_products']);

        // Cálculo de porcentajes
        double porcentajeRechazo = (totalRechazos / totalCompletados) * 100;
        double porcentajeRetrabajo = (totalRetrabajos / totalCompletados) * 100;
        double porcentajeCorrectos = 100 - porcentajeRechazo - porcentajeRetrabajo;

        totalCompleted.value = totalCompletados.toDouble();
        totalRechazo.value = porcentajeRechazo;
        totalRetrabajo.value = porcentajeRetrabajo;

        actualizarGrafica(porcentajeCorrectos, porcentajeRechazo, porcentajeRetrabajo);
        actualizarDatosGraficoCombinado(totalCompletados, totalRechazos, totalRetrabajos, currentMonth);
      } else {
        // Si no hay datos para el mes actual
        //actualizarDatosGraficoCombinado(0, 0, 0, currentMonth);
        totalCompleted.value = 0;
        totalRechazo.value = 0;
        totalRetrabajo.value = 0;
        actualizarGrafica(100, 0, 0); // 100% correcto si no hay datos
      }
    } else {
      print('Error al obtener productos: ${response.message}');
    }
    var response2 = await productoProvider.getEntOT();

    if (response2.success!) {
      totalEntregadas.value = 0;
      entregadasEnTiempo.value = 0;
      entregadasFueraDeTiempo.value = 0;

      DateTime now = DateTime.now();
      String currentMonth = DateFormat('yyyy-MM').format(now); // Mes actual

      response2.data.forEach((item) {
        String month = DateFormat('yyyy-MM').format(DateTime.parse(item['month']));
        if (month == currentMonth) {
          totalEntregadas.value += int.parse(item['total_entregadas']);
          entregadasEnTiempo.value += int.parse(item['entregadas_en_tiempo']);
          entregadasFueraDeTiempo.value += int.parse(item['entregadas_fuera_de_tiempo']);
        }
      });

      actualizarGrafica2(); // Actualizar grafic2() con los datos filtrados
    } else {
      print('Error al obtener OT entregadas por mes: ${response2.message}');
    }
    var response3 = await productoProvider.getlibProducts(); // Llama al backend

    if (response3.success!) {
      DateTime now = DateTime.now();
      String currentMonth = DateFormat('yyyy-MM').format(now); // Obtiene el mes actual en formato 'YYYY-MM'

      var filteredData = response3.data.where((item) {
        String itemMonth = DateFormat('yyyy-MM').format(DateTime.parse(item['month']));
        return itemMonth == currentMonth; // Compara solo el mes y año
      }).toList();

      // Reiniciar los datos del gráfico
      chartData3.value = []; // Limpiar datos previos

      if (filteredData.isNotEmpty) {
        int totalCompletados = int.parse(filteredData[0]['completed_products']);
        int totalRechazos = int.parse(filteredData[0]['rech_products']);
        int totalRetrabajos = int.parse(filteredData[0]['ret_products']);
        // Convertir el mes actual en nombre
        String monthName = DateFormat('MMMM').format(now); // Obtiene el nombre del mes

        // Actualizar datos del gráfico para el mes actual
        actualizarDatosGraficoCombinado(totalCompletados, totalRechazos, totalRetrabajos, monthName);
      } else {
        // Si no hay datos para el mes actual
        String monthName = DateFormat('MMMM').format(now); // Nombre del mes
        actualizarDatosGraficoCombinado(0, 0, 0, monthName);
      }
    } else {
      print('Error al obtener productos por mes: ${response3.message}');
    }
    var response4 = await productoProvider.getEfecProducts(); // Llamas a tu backend

    if (response4.success!) {
      // Filtra los datos solo para el año actual
      DateTime now = DateTime.now();
      String currentMonth = DateFormat('yyyy-MM').format(now); // Obtiene el mes actual

      var filteredData = response4.data.where((item) {
        String itemMonth = DateFormat('yyyy-MM').format(DateTime.parse(item['month']));
        return itemMonth == currentMonth;
      }).toList();

      // Reiniciar los valores acumulados
      totalProducts.value = 0;
      productsFueraDeTiempo.value = 0;
      productsEnTiempo.value = 0;

      // Sumar los productos del año actual
      filteredData.forEach((item) {
        int totalProductsItem = int.parse(item['completed_products'] ?? '0');
        int productsFueraDeTiempoItem = int.parse(item['products_fuera'] ?? '0');
        int productsEnTiempoItem = totalProductsItem - productsFueraDeTiempoItem;

        // Actualizar los valores acumulativos para todo el año
        totalProducts.value += totalProductsItem;
        productsFueraDeTiempo.value += productsFueraDeTiempoItem;
        productsEnTiempo.value += productsEnTiempoItem;
      });

      print('Total Productos fabricados: ${totalProducts.value}');
      print('Productos fabricados a tiempo: ${productsEnTiempo.value}');
      print('Productos fabricados fuera de tiempo: ${productsFueraDeTiempo.value}');

      // Actualizar la gráfica con los datos del año
      actualizarGrafica4();
    } else {
      print('Error al obtener productos por año: ${response4.message}');
    }
  }
  Future<void> obtenerDatosPorA() async {
    isYearFilterSelected.value = true; // Establecer que se seleccionó el año

    var response = await productoProvider.getlibProducts(); // Llamas a tu backend

    if (response.success!) {
      // Filtra los datos solo para el año actual
      DateTime now = DateTime.now();
      String currentYear = DateFormat('yyyy').format(now); // Obtiene el año actual

      var filteredData = response.data.where((item) {
        String itemYear = DateFormat('yyyy').format(DateTime.parse(item['month']));
        return itemYear == currentYear; // Compara solo el año
      }).toList();

      // Suma los productos del año actual
      int totalCompletados = 0;
      int totalRechazos = 0;
      int totalRetrabajos = 0;

      filteredData.forEach((item) {
        totalCompletados += int.parse(item['completed_products']);
        totalRechazos += int.parse(item['rech_products']);
        totalRetrabajos += int.parse(item['ret_products']);
      });

      if (totalCompletados > 0) {
        // Cálculo de porcentajes
        double porcentajeRechazo = (totalRechazos / totalCompletados) * 100;
        double porcentajeRetrabajo = (totalRetrabajos / totalCompletados) * 100;
        double porcentajeCorrectos = 100 - porcentajeRechazo - porcentajeRetrabajo;

        totalCompleted.value = totalCompletados.toDouble();
        totalRechazo.value = porcentajeRechazo;
        totalRetrabajo.value = porcentajeRetrabajo;

        actualizarGrafica(porcentajeCorrectos, porcentajeRechazo, porcentajeRetrabajo);
      } else {
        // Si no hay productos completados, asumimos que 100% son correctos
        actualizarGrafica(100, 0, 0);
      }
    } else {
      print('Error al obtener productos: ${response.message}');
    }
    var response2 = await productoProvider.getEntOT();

    if (response2.success!) {
      totalEntregadas.value = 0;
      entregadasEnTiempo.value = 0;
      entregadasFueraDeTiempo.value = 0;

      DateTime now = DateTime.now();
      String currentYear = DateFormat('yyyy').format(now); // Año actual

      response2.data.forEach((item) {
        String year = DateFormat('yyyy').format(DateTime.parse(item['month']));
        if (year == currentYear) {
          totalEntregadas.value += int.parse(item['total_entregadas']);
          entregadasEnTiempo.value += int.parse(item['entregadas_en_tiempo']);
          entregadasFueraDeTiempo.value += int.parse(item['entregadas_fuera_de_tiempo']);
        }
      });

      actualizarGrafica2(); // Actualizar grafic2() con los datos filtrados
    } else {
      print('Error al obtener OT entregadas por año: ${response2.message}');
    }
    var response3 = await productoProvider.getlibProducts(); // Llamas a tu backend

    if (response3.success!) {
      // Filtra los datos solo para el año actual
      DateTime now = DateTime.now();
      String currentYear = DateFormat('yyyy').format(now); // Obtiene el año actual

      // Reiniciar los datos del gráfico
      chartData3.value = [];

      response3.data.forEach((item) {
        String itemYear = DateFormat('yyyy').format(DateTime.parse(item['month']));
        if (itemYear == currentYear) {
          // Agregar datos para cada mes del año
          int totalCompletados = int.parse(item['completed_products']);
          int totalRechazos = int.parse(item['rech_products']);
          int totalRetrabajos = int.parse(item['ret_products']);

          // Convertir el mes en nombre
          String monthName = DateFormat('MMMM').format(DateTime.parse(item['month'])); // Obtener el nombre del mes

          // Agregar al gráfico combinado
          actualizarDatosGraficoCombinado(totalCompletados, totalRechazos, totalRetrabajos,monthName);
        }
      });
    } else {
      print('Error al obtener productos por año: ${response3.message}');
    }
    var response4 = await productoProvider.getEfecProducts(); // Llamas a tu backend

    if (response4.success!) {
      // Filtra los datos solo para el año actual
      DateTime now = DateTime.now();
      String currentYear = DateFormat('yyyy').format(now); // Obtiene el año actual

      var filteredData = response4.data.where((item) {
        String itemYear = DateFormat('yyyy').format(DateTime.parse(item['month']));
        return itemYear == currentYear; // Compara solo el año
      }).toList();

      // Reiniciar los valores acumulados
      totalProducts.value = 0;
      productsFueraDeTiempo.value = 0;
      productsEnTiempo.value = 0;

      // Sumar los productos del año actual
      filteredData.forEach((item) {
        int totalProductsItem = int.parse(item['completed_products'] ?? '0');
        int productsFueraDeTiempoItem = int.parse(item['products_fuera'] ?? '0');
        int productsEnTiempoItem = totalProductsItem - productsFueraDeTiempoItem;

        // Actualizar los valores acumulativos para todo el año
        totalProducts.value += totalProductsItem;
        productsFueraDeTiempo.value += productsFueraDeTiempoItem;
        productsEnTiempo.value += productsEnTiempoItem;
      });

      print('Total Productos fabricados: ${totalProducts.value}');
      print('Productos fabricados a tiempo: ${productsEnTiempo.value}');
      print('Productos fabricados fuera de tiempo: ${productsFueraDeTiempo.value}');

      // Actualizar la gráfica con los datos del año
      actualizarGrafica4();
    } else {
      print('Error al obtener productos por año: ${response4.message}');
    }
  }
  Future<void> obtenerTotalOTs() async {
    ResponseApi response = await productoProvider.getTotalOTs();
    if (response != null && (response.success ?? false)) {
      // Aquí sumas todas las total_ots de los diferentes meses
      int totalOTSum = response.data.fold<int>(
        0,
            (int sum, dynamic item) => sum + int.parse(item['total_ots'] ?? '0'), // Asegúrate de convertir a int
      );
      totalOTs.value = totalOTSum;
    } else {
      print('Error al obtener total OTs: ${response?.message}');
    }
  }

  Future<void> obtenerLibOTs() async {
    ResponseApi response = await productoProvider.getLibOTs();
    if (response != null && (response.success ?? false)) {
      // Aquí sumas todas las lib_ots de los diferentes meses
      int totalOTCerradasSum = response.data.fold<int>(
        0,
            (int sum, dynamic item) => sum + int.parse(item['lib_ots'] ?? '0'), // Asegúrate de convertir a int
      );
      otCerradas.value = totalOTCerradasSum;
    } else {
      //print('Error al obtener OTs liberadas: ${response?.message}');
    }
  }
  Future<void> obtenerTotalProducts() async {
    ResponseApi response = await productoProvider.getlibProducts();
    if (response != null && (response.success ?? false)) {
      // Aquí sumas todas las total_ots de los diferentes meses
      int totalproductSum = response.data.fold<int>(
        0,
            (int sum, dynamic item) => sum + int.parse(item['completed_products'] ?? '0'), // Asegúrate de convertir a int
      );
      productsFab.value = totalproductSum;
    } else {
      print('Error al obtener total productos: ${response?.message}');
    }
  }
  Future<void> obtenerProductsrr() async {
    ResponseApi response = await productoProvider.getlibProductsrr();
    if (response != null && (response.success ?? false)) {
      // Aquí sumas todas las total_ots de los diferentes meses
      int productrrSum = response.data.fold<int>(
        0,
            (int sum, dynamic item) => sum + int.parse(item['rr_products'] ?? '0'), // Asegúrate de convertir a int
      );
      productsrr.value = productrrSum;
      print('total productos: ${productsrr.value}');
    } else {
      print('Error al obtener total productos: ${response?.message}');
    }
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
  /*int calcularTiempoTrabajado(List<Tiempo> tiempos) {
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
      } else if (tiempo.estado == 'TERMINÓ') {
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
  }*/
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
  Future<Map<String, String>> calcularTiempoTotal(String productoId, String parte) async {
    try {
      List<Tiempo> tiempos = await tiempoProvider.getTiemposByProductId(productoId);
      if (tiempos.isEmpty) {
        return {'total': '','estimado' : '', 'actual': ''};
      }
      int tiempoTotalTrabajado = calcularTiempoTrabajado(tiempos);
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
        'estimado': tiempoEstimado
      };
    } catch (e) {
      print('Error al calcular tiempo: $e');
      return {'total': 'Error', 'actual': 'Error', 'estimado': ''};
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
  /*int calcularTiempoEfectivo(DateTime inicio, DateTime fin) {
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
  }*/

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
    sheetObject.appendRow(['COTIZACIÓN', 'O.T.', 'PEDIDO', 'CLIENTE', 'No. PARTE/PLANO', 'ARTICULO', 'CANTIDAD', 'ESTATUS', 'OPERADOR', 'TIEMPO ESTIMADO', 'FECHA DE ENTREGA', 'ENTREGA REAL']);

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
          await calcularTiempoTotal(producto.id!, producto.parte ?? '' ).then((value) => value['total'] ?? 'N/A'),
          producto.fecha ?? '',
          producto.entrega ?? '',
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
  void goToEntrega(Producto producto) {
    print('Producto seleccionado: $producto');
    Get.toNamed(
        '/produccion/tabla/entrega', arguments: {'producto': producto.toJson()});
  }
}