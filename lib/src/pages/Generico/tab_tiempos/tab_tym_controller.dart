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
  }
*/
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

  Future<Map<String, String>> calcularTiempoTotal(String productoId, String parte) async {
    try {
      List<Tiempo> tiempos = await tiempoProvider.getTiemposByProductId(productoId);
      if (tiempos.isEmpty) {
        return {'total': '', 'actual': '', 'estimado': ''};
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

  Future<void> generarPDF(Producto producto) async {

    ByteData imageData = await rootBundle.load('assets/img/LOGO1.png');
    // Convierte los datos de la imagen a un arreglo de bytes
    Uint8List bytess = imageData.buffer.asUint8List();
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final pdfPageFormat = PdfPageFormat.letter;
    final pw.TextStyle headerTextStyle = pw.TextStyle(fontSize: 9);

    final pdf = pw.Document();
    final List<Tiempo> tiempos = await tiempoProvider.getTiemposByProductId(producto.id!);
    final int tiempoTotal = calcularTiempoTrabajado(tiempos);

    pdf.addPage(
      pw.Page(
        pageFormat: pdfPageFormat,
        margin: pw.EdgeInsets.fromLTRB(20, 25, 25, 15),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1), // Definir el borde
                ),
                //padding: pw.EdgeInsets.all(10),
                child: pw.Row(
                  children: [
                    // Logo en la esquina superior izquierda
                    pw.Container(
                      margin: pw.EdgeInsets.only(right: 5),
                      child: pw.Image(
                        pw.MemoryImage(
                            bytess
                        ),
                      ),
                      width: 60,
                      height: 60,
                    ),
                    // Título centrado
                    pw.Expanded(
                      child: pw.Center(
                        child: pw.Text(
                          'Reporte de tiempos y movimientos',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            font: pw.Font.timesBold(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Agregar la tabla vertical en la esquina superior derecha
                        pw.Table.fromTextArray(
                          context: context,
                          cellHeight: 5,
                          columnWidths: {
                            0: pw.FixedColumnWidth(40),
                            // Ancho de la primera columna
                            1: pw.FixedColumnWidth(70),
                            // Ancho de la segunda columna
                          },
                          data: [
                            ['Producto:', '${producto.articulo}'],
                          ],
                          cellAlignment: pw.Alignment.center,
                          cellStyle: pw.TextStyle(fontSize: 4),
                          headerStyle: headerTextStyle,
                        ),
                        // Añadir otro contenido aquí si es necesario
                        pw.SizedBox(height: 2),
                        // Espacio entre la tabla y otro contenido
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Agregar la tabla vertical en la esquina superior derecha
                      pw.Table.fromTextArray(
                        context: context,
                        columnWidths: {
                          0: pw.FixedColumnWidth(30),
                          // Ancho de la primera columna
                        },
                        data: [
                          ['  '],
                        ],
                        border: null,
                        cellAlignment: pw.Alignment.center,
                      ),
                      // Añadir otro contenido aquí si es necesario
                      pw.SizedBox(height: 2),
                      // Espacio entre la tabla y otro contenido
                    ],
                  ),

                  pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          // Agregar la tabla vertical en la esquina superior derecha
                          pw.Table.fromTextArray(
                            columnWidths: {
                              0: pw.FixedColumnWidth(40),
                              // Ancho de la primera columna
                              1: pw.FixedColumnWidth(50),
                              // Ancho de la segunda columna
                            },
                            context: context,
                            data: [
                              ['OT:', '${producto.ot}'],
                            ],
                            cellAlignment: pw.Alignment.center,
                            cellStyle: pw.TextStyle(fontSize: 4),
                            headerStyle: headerTextStyle,
                          ),
                          // Añadir otro contenido aquí si es necesario
                          pw.SizedBox(height: 2),
                          // Espacio entre la tabla y otro contenido
                        ],
                      )
                  )
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Agregar la tabla vertical en la esquina superior derecha
                        pw.Table.fromTextArray(
                          context: context,
                          columnWidths: {
                            0: pw.FixedColumnWidth(40),
                            // Ancho de la primera columna
                            1: pw.FixedColumnWidth(70),
                            // Ancho de la segunda columna
                          },
                          data: [
                            ['Parte/plano:', '${producto.parte ?? ''}'],
                          ],
                          cellAlignment: pw.Alignment.center,
                          cellStyle: pw.TextStyle(fontSize: 5),
                          headerStyle: headerTextStyle,
                        ),
                        // Añadir otro contenido aquí si es necesario
                        pw.SizedBox(height: 2),
                        // Espacio entre la tabla y otro contenido
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Agregar la tabla vertical en la esquina superior derecha
                      pw.Table.fromTextArray(
                        context: context,
                        columnWidths: {
                          0: pw.FixedColumnWidth(30),
                          // Ancho de la primera columna
                        },
                        data: [
                          ['  '],
                        ],
                        border: null,
                        cellAlignment: pw.Alignment.center,
                      ),
                      // Añadir otro contenido aquí si es necesario
                      pw.SizedBox(height: 2),
                      // Espacio entre la tabla y otro contenido
                    ],
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        // Agregar la tabla vertical en la esquina superior derecha
                        pw.Table.fromTextArray(
                          context: context,
                          columnWidths: {
                            0: pw.FixedColumnWidth(40),
                            // Ancho de la primera columna
                            1: pw.FixedColumnWidth(50),
                            // Ancho de la segunda columna
                          },
                          data: [
                            ['Cantidad: ', '${producto.cantidad}'],
                          ],
                          cellAlignment: pw.Alignment.center,
                          cellStyle: pw.TextStyle(fontSize: 5),
                          headerStyle: headerTextStyle,
                        ),
                        // Añadir otro contenido aquí si es necesario
                        pw.SizedBox(height: 2),
                        // Espacio entre la tabla y otro contenido
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Table.fromTextArray(
                headers: [
                  'Operador','Proceso','Estado', 'Fecha y Hora', 'Comentario'
                ],
                headerStyle: pw.TextStyle(color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
                data: tiempos.map((t) => [
                  t.operador!.name,t.proceso, t.estado, t.time ?? 'N/A', t.coment
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Tiempo Total: ${formatTiempo(tiempoTotal)}',
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

  Future<Directory?> getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    } else {
      return getApplicationDocumentsDirectory(); // Alternativa para otros sistemas
    }
  }
  // Guardar el archivo PDF en la memoria del dispositivo
  final directory = await getDownloadsDirectory();
  final file = File('${directory!.path}/${producto.articulo}_reporte.pdf');
  await file.writeAsBytes(await pdf.save());
    Get.snackbar('DOCUMENTO DESCARGADO EN:', '${file.path}', backgroundColor: Colors.green,
      colorText: Colors.white,);
  print('PDF guardado en: ${file.path}');
  final bytes = await pdf.save();

  try {
  await file.writeAsBytes(bytes);
  logger.i('Se pudo escribir el archivo correctamente');
  } catch (e) {
  logger.e('Error al escribir el archivo: $e');
  }

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

