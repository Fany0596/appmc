import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/pages/ventas/orders/list/ventas_oc_list_controller.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:maquinados_correa/src/providers/vendedor_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

class VentasDetallesController extends GetxController {
  Cotizacion cotizacion= Cotizacion.fromJson(Get.arguments['cotizacion']);

  final logger = Logger(
    printer: PrettyPrinter(),
    filter: ProductionFilter(), // Solo registra mensajes de nivel de advertencia o superior en producción
  );

  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  var totalt = 0.0.obs;
  var isTotalToPayExpanded = false.obs;

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  ProductoProvider productoProvider = ProductoProvider();
  VendedoresProvider vendedoresProvider = VendedoresProvider();
  List<String> estatus = <String>['POR ASIGNAR','EN ESPERA', 'EN PROCESO', 'SUSPENDIDO', 'SIG. PROCESO','RETRABAJO','RECHAZADO', 'LIBERADO','ENTREGADO', 'CANCELADO'].obs;

VentasDetallesController(){
  print('Cotizacion: ${cotizacion.toJson()}');
  getTotal();
}

  RxList<Producto> productosPorEstatus = <Producto>[].obs;

  // Método para cargar los productos de la cotización según el estatus seleccionado
  Future<void> cargarProductosPorEstatus(String estatus) async {
    // Limpiar la lista de productos antes de cargar nuevos productos
    productosPorEstatus.clear();

    // Obtener los productos de la cotización por el estatus seleccionado
    List<Producto> productosCotizacion = cotizacion.producto!;
    productosPorEstatus.addAll(productosCotizacion.where((producto) => producto.estatus == estatus));
    print('Productos por estado $estatus: $productosPorEstatus');

  }
  void deleteProduct(Producto producto) async {
    ResponseApi responseApi = await productoProvider.deleted(
        producto.id!); // Llama al backend para eliminar el producto
    if (responseApi.success == true) {
      Get.snackbar(
        'Éxito', responseApi.message ?? 'Producto eliminado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,);
      if (responseApi.success!) { // Si la respuesta es exitosa, navegar a la página de roles
        reloadPage();
      }
    } else {
      Get.snackbar(
        'Error', responseApi.message ?? 'Error al eliminar el producto',
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    }
  }

  void goToProductUpdate(Producto producto) {
    print('Producto seleccionado: $producto');
    Get.toNamed(
        '/ventas/update/update', arguments: {'producto': producto.toJson()});
  }
  void updateCotizacion() async {

      ResponseApi responseApi = await cotizacionProvider.updateconfirmada(
          cotizacion);
      if (responseApi.success == true) {
        Get.snackbar('Proceso terminado', responseApi.message ?? '',
          backgroundColor: Colors.green,colorText: Colors.white,);
      }
    else {
      Get.snackbar('Peticion denegada', 'verifique informacion', backgroundColor: Colors.red,
        colorText: Colors.white,);
    }
  }
  void updateCancelada() async {

    ResponseApi responseApi = await cotizacionProvider.updatecancelada(
        cotizacion);

    if (responseApi.success == true) {
      Get.snackbar('Proceso terminado', responseApi.message ?? '', backgroundColor: Colors.green,
        colorText: Colors.white,);
    }
    else {
      Get.snackbar('Peticion denegada', 'verifique informacion', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
    }
  }
  void updateCerrada() async {

    ResponseApi responseApi = await cotizacionProvider.updatecerrada(cotizacion);

    if (responseApi.success == true) {
      Get.snackbar('Proceso terminado', responseApi.message ?? '', backgroundColor: Colors.green,
        colorText: Colors.white,);
    }
    else {
      Get.snackbar('Peticion denegada', 'verifique informacion', backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
    }
  }
  void getTotal() {
    totalt.value = 0.0;
    cotizacion.producto!.forEach((producto) {
      if (producto.estatus != 'CANCELADO') {
        totalt.value += producto.total!;
      }
    });
  }
  void reloadPage() async {
    // Llamar al método del provider para obtener la cotización por ID
    Cotizacion? cotizacionActualizada = await cotizacionProvider.getCotizacionById(cotizacion.id!);

    if (cotizacionActualizada != null) {
      // Actualizar la cotización con los nuevos datos
      cotizacion = cotizacionActualizada;

      // Actualizar los productos por cada estado
      for (String estado in estatus) {
        await cargarProductosPorEstatus(estado);
      }

      // Recalcular el total
      getTotal();

      // Notificar a los widgets que los datos han cambiado
      update();
    } else {
      // Manejo de errores o estado nulo
      Get.snackbar('Error', 'No se pudo cargar la cotización');
    }
  }

  List<pw.Widget> contenidoPDF = [];
  List<pw.Widget> garantiasWidget = [];
  List<pw.Widget> reportedimWidget = [];
  List<pw.Widget> reportetratWidget = [];
  List<pw.Widget> reportematWidget = [];
  List<pw.Widget> reporterugWidget = [];
  List<pw.Widget> coment1Widget = [];
  List<pw.Widget> coment2Widget = [];
  List<pw.Widget> coment3Widget = [];
  List<pw.Widget> bancariosWidget = [];
  List<pw.Widget> valWidget = [];
  List<pw.Widget> comentWidget = [];

  Future<void> generarCot() async {
    // Accede a la imagen desde los activos de tu aplicación
    ByteData imageData = await rootBundle.load('assets/img/logoC.png');
    // Convierte los datos de la imagen a un arreglo de bytes
    Uint8List bytess = imageData.buffer.asUint8List();
    // Obtener la lista de productos en espera
    List<Producto> productosAsignar = cotizacion.producto!
        .where((producto) => producto.estatus != 'CANCELADO')
        .toList();
    // Crear una lista de listas para almacenar los datos de los productos
    List<List<String>> productosData = [];

    // Agregar los datos de cada producto a la lista de datos
    for (int i = 0; i < productosAsignar.length; i++) {
      Producto producto = productosAsignar[i];
      // Formatear el precio y el total como moneda
      final precioFormatted = NumberFormat.currency(
          locale: 'es_MX', symbol: '\$').format(producto.precio);
      final totalFormatted = NumberFormat.currency(
          locale: 'es_MX', symbol: '\$').format(producto.total);

      // Formatear la cantidad como un número entero
      final cantidadFormatted = producto.cantidad!.toStringAsFixed(0);

      productosData.add([
        cantidadFormatted,
        producto.descr.toString(),
        precioFormatted,
        totalFormatted
      ]);
    }

    final ivaValue = totalt.value * 0.16;
    final totValue = totalt.value + ivaValue;
    // Crear un objeto NumberFormat para el formato de moneda
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final totaltFormatted = currencyFormat.format(totalt.value);

    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Crear el documento PDF
    final pdf = pw.Document();
    final pdfPageFormat = PdfPageFormat.letter;


    final pw.TextStyle headerTextStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10);
    final pw.TextStyle headertTextStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.white);
    final pw.TextStyle dataTextStyle = pw.TextStyle(fontSize: 9);
    final cotizacionTextStyle = pw.TextStyle(color: PdfColors.red, fontSize: 9, fontWeight: pw.FontWeight.bold,);
    final creditTextStyle = pw.TextStyle(color: PdfColors.red, fontSize: 9);
    final pw.TextStyle blueTextStyle = pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColors.blueAccent700);
    final pw.TextStyle blue2TextStyle = pw.TextStyle(
        fontSize: 9, color: PdfColors.blueAccent700);
    final pw.TextStyle finTextStyle = pw.TextStyle(
        fontSize: 7, color: PdfColors.grey);

    contenidoPDF = [
      pw.SizedBox(height: 20), // Espacio de 3 cm
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Agregar la tabla vertical en la esquina superior derecha
                pw.Table.fromTextArray(
                  //context: context,
                  columnWidths: {
                    0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                    1: pw.FixedColumnWidth(70), // Ancho de la segunda columna
                  },
                  data: [
                    ['Cliente:', '${cotizacion.clientes!.name != null ? cotizacion.clientes!.name!.split('-').last.trim() : ''}'],
                  ],
                  border: null,
                  cellAlignment: pw.Alignment.center,
                  headerAlignment: pw.Alignment.topLeft,
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                // Agregar la tabla vertical en la esquina superior derecha
                pw.Table.fromTextArray(
                  //context: context,
                  columnWidths: {
                    0: pw.FixedColumnWidth(40),
                    // Ancho de la primera columna
                    1: pw.FixedColumnWidth(50),
                    // Ancho de la segunda columna
                  },
                  data: [
                    [' ', ''],
                  ],
                  border: null,
                  cellAlignment: pw.Alignment.center,
                  cellStyle: pw.TextStyle(fontSize: 5),
                  headerStyle: headerTextStyle,
                ),
                pw.SizedBox(height: 10),
                // Espacio entre la tabla y otro contenido
              ],
            ),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                // Agregar la tabla vertical en la esquina superior derecha
                pw.Table.fromTextArray(
                  columnWidths: {
                    0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                    1: pw.FixedColumnWidth(70), // Ancho de la segunda columna
                  },
                  //context: context,
                  data: [
                    ['Contacto:', '${cotizacion.nombre ?? ''}'],
                  ],
                  border: null,
                  cellAlignment: pw.Alignment.center,
                  headerAlignment: pw.Alignment.topLeft,
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                // Agregar la tabla vertical en la esquina superior derecha
                pw.Table.fromTextArray(
                  //context: context,
                  columnWidths: {
                    0: pw.FixedColumnWidth(40),
                    // Ancho de la primera columna
                    1: pw.FixedColumnWidth(50),
                    // Ancho de la segunda columna
                  },
                  data: [
                    [' ', ''],
                  ],
                  border: null,
                  cellAlignment: pw.Alignment.center,
                  cellStyle: pw.TextStyle(fontSize: 5),
                  headerStyle: headerTextStyle,

                ),
                // Añadir otro contenido aquí si es necesario
                pw.SizedBox(height: 10),
                // Espacio entre la tabla y otro contenido
              ],
            ),
          ),
          pw.SizedBox(height: 10),
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
                  //context: context,
                  columnWidths: {
                    0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                    1: pw.FixedColumnWidth(70), // Ancho de la segunda columna
                  },
                  data: [
                    ['Requerimiento:', '${cotizacion.req ?? ''}'],
                  ],
                  border: null,
                  cellAlignment: pw.Alignment.center,
                  headerAlignment: pw.Alignment.topLeft,
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                // Agregar la tabla vertical en la esquina superior derecha
                pw.Table.fromTextArray(
                  //context: context,
                  columnWidths: {
                    0: pw.FixedColumnWidth(40),
                    // Ancho de la primera columna
                    1: pw.FixedColumnWidth(50),
                    // Ancho de la segunda columna
                  },
                  data: [
                    [' ', ''],
                  ],
                  border: null,
                  cellAlignment: pw.Alignment.center,
                  cellStyle: pw.TextStyle(fontSize: 5),
                  headerStyle: headerTextStyle,
                ),
                // Añadir otro contenido aquí si es necesario
                pw.SizedBox(height: 10),
                // Espacio entre la tabla y otro contenido
              ],
            ),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Agregar la tabla vertical en la esquina superior derecha
          pw.Table.fromTextArray(
            //context: context,
            columnWidths: {
              0: pw.FixedColumnWidth(40),
              // Ancho de la primera columna
            },
            data: [
              [
                'A continuación, pongo a su consideración la siguiente cotización:'
              ],
            ],
            border: null,
            cellAlignment: pw.Alignment.topLeft,
            cellStyle: pw.TextStyle(fontSize: 3),
            headerStyle: headerTextStyle,
            headerAlignment: pw.Alignment.topLeft,
          ),
          // Añadir otro contenido aquí si es necesario
          pw.SizedBox(height: 2),
          // Espacio entre la tabla y otro contenido
        ],
      ),
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Agregar la tabla vertical en la esquina superior derecha
                pw.Table.fromTextArray(
                  //context: context,
                  columnWidths: {
                    0: pw.FixedColumnWidth(30),
                    // Ancho de la primera columna
                    1: pw.FixedColumnWidth(190),
                    // Ancho de la segunda columna
                    2: pw.FixedColumnWidth(40),
                    // Ancho de la tercera columna
                    3: pw.FractionColumnWidth(.09),
                    // Ancho de la cuarta columna (fracción del ancho disponible) // Ancho de la segunda columna
                  },
                  data: [
                    ['CANT.', 'DESCRIPCIÓN', 'P/U', 'TOTAL'],
                  ],
                  //border: null,
                  cellAlignment: pw.Alignment.center,
                  headerAlignment: pw.Alignment.center,
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.blueAccent700, // Color de fondo del encabezado
                  ),
                  headerStyle: headertTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
      // tabla con los datos de los productos
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: pw.FixedColumnWidth(30),
          // Ancho de la primera columna
          1: pw.FixedColumnWidth(190),
          // Ancho de la segunda columna
          2: pw.FixedColumnWidth(40),
          // Ancho de la tercera columna
          3: pw.FractionColumnWidth(.09),
          // Ancho de la cuarta columna (fracción del ancho disponible)
        },
        children: productosData.map((row) {
          return pw.TableRow(
            children: row.map((cell) {
              final textStyle = dataTextStyle;
              return pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  cell,
                  style: textStyle,
                ),
                padding: const pw.EdgeInsets.all(8),
              );
            }).toList(),
          );
        }).toList(),
      ),
      pw.Row(
          children: [
            pw.Spacer(),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Agregar la tabla vertical en la esquina superior derecha
                pw.Table.fromTextArray(
                  //context: context,
                  columnWidths: {
                    0: pw.FixedColumnWidth(73), // Ancho de la primera columna
                    1: pw.FixedColumnWidth(93), // Ancho de la segunda columna
                  },
                  data: [
                    ['Sub. Tot.', totaltFormatted],
                  ],
                  cellAlignment: pw.Alignment.topRight,
                  headerStyle: dataTextStyle,
                ),
              ],
            ),
          ]
      ),
      pw.Row(
          children: [
            pw.Spacer(),
            pw.Column(
              //mainAxisAlignment: pw.MainAxisAlignment.end,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Agregar la tabla vertical en la esquina superior derecha
                pw.Table.fromTextArray(
                  //context: context,
                  columnWidths: {
                    0: pw.FixedColumnWidth(73), // Ancho de la primera columna
                    1: pw.FixedColumnWidth(93), // Ancho de la segunda columna
                  },
                  data: [
                    ['IVA', currencyFormat.format(ivaValue)],
                  ],
                  cellAlignment: pw.Alignment.topRight,
                  headerStyle: dataTextStyle,
                ),
              ],
            ),
          ]
      ),
      pw.Row(
          children: [
            pw.Spacer(),
            pw.Column(
              //mainAxisAlignment: pw.MainAxisAlignment.end,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Agregar la tabla vertical en la esquina superior derecha
                pw.Table.fromTextArray(
                  //context: context,
                  columnWidths: {
                    0: pw.FixedColumnWidth(73), // Ancho de la primera columna
                    1: pw.FixedColumnWidth(93), // Ancho de la segunda columna
                  },
                  data: [
                    ['TOTAL', currencyFormat.format(totValue)],
                  ],
                  cellAlignment: pw.Alignment.topRight,
                  headerStyle: dataTextStyle,
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          ]
      ),
      pw.SizedBox(height: 10), // Espacio de 3 cm
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Agregar la tabla vertical en la esquina superior derecha
                pw.Table.fromTextArray(
                  //context: context,
                  columnWidths: {
                    0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                    1: pw.FixedColumnWidth(190), // Ancho de la segunda columna
                  },
                  data: [
                    ['Tiempo de entrega:', '${cotizacion.ent}'],
                  ],
                  border: null,
                  cellAlignment: pw.Alignment.center,
                  headerAlignment: pw.Alignment.topLeft,
                  headerStyle: dataTextStyle,
                ),
              ],
            ),
          ),
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
                  //context: context,
                  columnWidths: {
                    0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                    1: pw.FixedColumnWidth(190), // Ancho de la segunda columna
                  },
                  data: [
                    [
                      'Condiciones de pago:',
                      '${cotizacion.condiciones ?? ''}\n${cotizacion
                          .descuento ?? ''}'
                    ],
                  ],
                  border: null,
                  cellAlignment: pw.Alignment.center,
                  headerAlignment: pw.Alignment.topLeft,
                  headerStyle: dataTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    ];
    if (cotizacion.coment1 == 'si' || cotizacion.coment2 == 'si' ||
        cotizacion.coment3 == 'si') {
      comentWidget = [
        pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Agregar la tabla vertical en la esquina superior derecha
                    pw.Table.fromTextArray(
                      //context: context,
                      columnWidths: {
                        0: pw.FixedColumnWidth(40),
                        // Ancho de la primera columna
                      },
                      data: [
                        [
                          'Comentarios:',
                        ],
                      ],
                      border: null,
                      cellAlignment: pw.Alignment.center,
                      headerAlignment: pw.Alignment.topLeft,
                      headerStyle: dataTextStyle,
                    ),
                  ],
                ),
              ),
            ]
        ),
      ];
    }
    if (cotizacion.agreg1 == 'si' || cotizacion.agreg2 == 'si' ||
        cotizacion.agreg3 == 'si' || cotizacion.agreg4 == 'si') {
      valWidget = [
        pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Aquí verificamos si al menos uno de los agregados es 'si'
                    if (cotizacion.agreg1 == 'si' || cotizacion.agreg2 == 'si' ||
                        cotizacion.agreg3 == 'si' || cotizacion.agreg4 == 'si')
                      pw.Table.fromTextArray(
                        //context: context,
                        columnWidths: {
                          0: pw.FixedColumnWidth(30), // Ancho de la primera columna
                        },
                        data: [
                          [
                            '                                                                                          VALORES AGREGADOS'
                          ],
                        ],
                        border: null,
                        cellAlignment: pw.Alignment.center,
                        headerAlignment: pw.Alignment.topLeft,
                        headerStyle: blue2TextStyle,
                      ),

                  ],
                ),
              ),
            ]
        ),
      ];
    }
    if (cotizacion.banc == 'si') {
    bancariosWidget = [
      pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Agregar la tabla vertical en la esquina superior derecha
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(30), // Ancho de la primera columna
                    },
                    data: [
                      ['DATOS BANCARIOS'],
                    ],
                    cellAlignment: pw.Alignment.center,
                    headerDecoration: pw.BoxDecoration(
                      color: PdfColors.blueAccent700, // Color de fondo del encabezado
                    ),
                  ),
                ],
              ),
            ),
          ]
      ),
      pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Agregar la tabla vertical en la esquina superior derecha
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                      1: pw.FixedColumnWidth(50), // Ancho de la segunda columna
                    },
                    data: [
                      ['Cuenta:', 'Maquinados Correa S de RL de CV'],
                    ],
                    cellAlignment: pw.Alignment.center,
                    headerStyle: cotizacionTextStyle,
                    headerDecoration: pw.BoxDecoration(
                      color: PdfColors.grey, // Color de fondo del encabezado
                    ),
                  ),
                ],
              ),
            ),
          ]
      ),
      pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Agregar la tabla vertical en la esquina superior derecha
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                      1: pw.FixedColumnWidth(50), // Ancho de la segunda columna
                    },
                    data: [
                      ['Clabe interbancaria:', '012180001072061434'],
                    ],
                    cellAlignment: pw.Alignment.center,
                    headerStyle: dataTextStyle,
                  ),
                ],
              ),
            ),
          ]
      ),
      pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Agregar la tabla vertical en la esquina superior derecha
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                      1: pw.FixedColumnWidth(50), // Ancho de la segunda columna
                    },
                    data: [
                      ['No. Cuenta:', '107206143'],
                    ],
                    cellAlignment: pw.Alignment.center,
                    headerStyle: dataTextStyle,
                  ),
                ],
              ),
            ),
          ]
      ),
      pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Agregar la tabla vertical en la esquina superior derecha
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                      1: pw.FixedColumnWidth(50), // Ancho de la segunda columna
                    },
                    data: [
                      ['Sucursal:', '3512'],
                    ],
                    cellAlignment: pw.Alignment.center,
                    headerStyle: dataTextStyle,
                  ),
                ],
              ),
            ),
          ]
      ),
      pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Agregar la tabla vertical en la esquina superior derecha
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                      1: pw.FixedColumnWidth(50), // Ancho de la segunda columna
                    },
                    data: [
                      ['Banco:', 'BBVA'],
                    ],
                    cellAlignment: pw.Alignment.center,
                    headerStyle: dataTextStyle,
                  ),
                ],
              ),
            ),
          ]
      ),
      pw.SizedBox(height: 10), // Espacio de 3 cm
      pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Agregar la tabla vertical en la esquina superior derecha
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                      1: pw.FixedColumnWidth(50), // Ancho de la segunda columna
                    },
                    data: [
                      ['Cuenta:', 'Amado Correa Aguilar'],
                    ],
                    cellAlignment: pw.Alignment.center,
                    headerStyle: cotizacionTextStyle,
                    headerDecoration: pw.BoxDecoration(
                      color: PdfColors.grey, // Color de fondo del encabezado
                    ),
                  ),
                ],
              ),
            ),
          ]
      ),
      pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Agregar la tabla vertical en la esquina superior derecha
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                      1: pw.FixedColumnWidth(50), // Ancho de la segunda columna
                    },
                    data: [
                      ['Clabe interbancaria:', '002180050561798033'],
                    ],
                    cellAlignment: pw.Alignment.center,
                    headerStyle: dataTextStyle,
                  ),
                ],
              ),
            ),
          ]
      ),
      pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Agregar la tabla vertical en la esquina superior derecha
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                      1: pw.FixedColumnWidth(50), // Ancho de la segunda columna
                    },
                    data: [
                      ['No. Cuenta:', '6179803'],
                    ],
                    cellAlignment: pw.Alignment.center,
                    headerStyle: dataTextStyle,
                  ),
                ],
              ),
            ),
          ]
      ),
      pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Agregar la tabla vertical en la esquina superior derecha
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                      1: pw.FixedColumnWidth(50), // Ancho de la segunda columna
                    },
                    data: [
                      ['Sucursal:', '505'],
                    ],
                    cellAlignment: pw.Alignment.center,
                    headerStyle: dataTextStyle,
                  ),
                ],
              ),
            ),
          ]
      ),
      pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Agregar la tabla vertical en la esquina superior derecha
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                      1: pw.FixedColumnWidth(50), // Ancho de la segunda columna
                    },
                    data: [
                      ['Banco:', 'Banamex'],
                    ],
                    cellAlignment: pw.Alignment.center,
                    headerStyle: dataTextStyle,
                  ),
                ],
              ),
            ),
          ]
      ),
      pw.SizedBox(height: 10), // Espacio de 3 cm
    ];
  }
    if (cotizacion.agreg1 == 'si') {
      reportedimWidget = [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(30), // Ancho de la primera columna
                    },
                    data: [
                      [
                        '°Reportes dimensiónales con equipos digitales y certificados (envío vía mail previo a la entrega con evidencia fotográfica).'
                      ],
                    ],
                    border: null,
                    cellAlignment: pw.Alignment.center,
                    headerAlignment: pw.Alignment.topLeft,
                    headerStyle: blue2TextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ];
    }
    if (cotizacion.agreg2 == 'si') {
      reporterugWidget = [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(30), // Ancho de la primera columna
                    },
                    data: [
                      [
                        '°Reporte de rugosidad (en caso de ser necesario).'
                      ],
                    ],
                    border: null,
                    cellAlignment: pw.Alignment.center,
                    headerAlignment: pw.Alignment.topLeft,
                    headerStyle: blue2TextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ];
    }
    if (cotizacion.agreg3 == 'si') {
      reportetratWidget = [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(30), // Ancho de la primera columna
                    },
                    data: [
                      [
                        '°Certificados de calidad de tratamiento termico.'
                      ],
                    ],
                    border: null,
                    cellAlignment: pw.Alignment.center,
                    headerAlignment: pw.Alignment.topLeft,
                    headerStyle: blue2TextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ];
    }
    if (cotizacion.agreg4 == 'si') {
      reportematWidget = [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(30), // Ancho de la primera columna
                    },
                    data: [
                      [
                        '°Certificados de calidad de material.'
                      ],
                    ],
                    border: null,
                    cellAlignment: pw.Alignment.center,
                    headerAlignment: pw.Alignment.topLeft,
                    headerStyle: blue2TextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ];
    }
    if (cotizacion.coment1 == 'si') {
      coment1Widget = [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(30), // Ancho de la primera columna
                    },
                    data: [
                      [
                        'La vigencia de esta cotización será de 15 dias a partir de esta fecha.'
                      ],
                    ],
                    border: null,
                    cellAlignment: pw.Alignment.center,
                    headerAlignment: pw.Alignment.topLeft,
                    headerStyle: dataTextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ];
    }
    if (cotizacion.coment2 == 'si') {
      coment2Widget = [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(30), // Ancho de la primera columna
                    },
                    data: [
                      [
                        'Los precios son en moneda nacional.'
                      ],
                    ],
                    border: null,
                    cellAlignment: pw.Alignment.center,
                    headerAlignment: pw.Alignment.topLeft,
                    headerStyle: dataTextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ];
    }
    if (cotizacion.coment3 == 'si') {
      coment3Widget = [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(30), // Ancho de la primera columna
                    },
                    data: [
                      [
                        'La entrega es hasta el almacén del cliente sin costo adicional, así como las visitas técnicas que se requieran.'
                      ],
                    ],
                    border: null,
                    cellAlignment: pw.Alignment.center,
                    headerAlignment: pw.Alignment.topLeft,
                    headerStyle: dataTextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ];
    }
    if (cotizacion.garant == 'si') {
      garantiasWidget = [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Table.fromTextArray(
                    //context: context,
                    columnWidths: {
                      0: pw.FixedColumnWidth(30), // Ancho de la primera columna
                    },
                    data: [
                      [
                        '                                                                                                GARANTÍAS\n\n- Materiales: Garantizamos que los productos que fabricamos en Maquinados Correa solo se utilizan materiales nuevos y respaldados con los certificados y facturas de compra correspondientes.\n\n- La garantía no cubre el uso de un material inadecuado por elección del cliente ya sea en algún tratamiento térmico, recubrimiento o en el trabajo y esfuerzo al que sea sometido el producto terminado.\n\n- Tratamientos adicionales: Garantizamos que los tratamientos que se agregan a los productos fabricados por Maquinados Correa se hacen bajo los mejores estándares de calidad y servicio y respaldados por los certificados de calidad.\n\n- La garantía no cubre el uso y las condiciones inapropiadas a las que se someta el producto terminado.\n\n- Medidas: Garantizamos que los productos que se fabrican en Maquinados Correa son liberados por nuestro departamento de calidad y se acompañan por sus respectivos reportes dimensionales.\n\n- La garantía no cubre indicaciones verbales o ajustes de último momento, los productos se fabrican a partir de planos y si el cliente nos proporciona muestra física es necesario que proporcionen las indicaciones y/o medidas necesarias para fabricación en el momento de la recolección de la muestra.\n\n- En todos los servicios de reparación no habrá ninguna garantía que cubra el correcto funcionamiento de la pieza reparada y será bajo la entera responsabilidad del cliente que lo solicite.\n\n- Cualquier garantía se anulará en caso de haber vicios ocultos, malas condiciones de operación, así como la omisión de información que pudiera afectar el correcto funcionamiento de las piezas fabricadas por Maquinados Correa.\n\n- Al enviar orden de compra el cliente da por aceptados los precios, tiempos y condiciones mencionadas en nuestra cotización y por ningún motivo podrá ser cancelada.\n\n* El tiempo de fabricación es estimado y podrá variar dependiendo de la existencia de materiales, así como los programas de producción.\n\n** La fecha de entrega es estimada y podría variar.\n\n*** La recolección y entrega está libre de costo siempre y cuando pueda realizarse con nuestras unidades de transporte en caso de requerir algún otro equipo de transporte, así como de maniobra se cotizara de forma individual.'
                      ],
                    ],
                    border: null,
                    cellAlignment: pw.Alignment.center,
                    headerAlignment: pw.Alignment.topLeft,
                    headerStyle: dataTextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ];
    }

    // Define el encabezado que se agregará a todas las páginas
    final pw.Widget header =  pw.Container(
      margin: pw.EdgeInsets.only(bottom: 20),
        child: pw.Row(
            children: [
              // Logo en la esquina superior izquierda
              pw.Container(
                margin: pw.EdgeInsets.only(left: 10),
                child: pw.Image(
                  pw.MemoryImage(
                      bytess
                  ),
                ),
                width: 70,
                height: 70,
              ),
              // Título centrado
              pw.Expanded(
                child: pw.Center(
                  child: pw.Text(
                    '',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      font: pw.Font.timesBold(),
                    ),
                  ),
                ),
              ),
              // Contenedor para la tabla vertical
              pw.Column(
                children: [ pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Agregar la tabla vertical en la esquina superior derecha
                    pw.Table.fromTextArray(
                      columnWidths: {
                        0: pw.FixedColumnWidth(120), // Ancho de la primera columna
                      },
                      //context: context,
                      data: [
                        ['COTIZACIÓN'],
                      ],
                      cellAlignment: pw.Alignment.center,
                      headerDecoration: pw.BoxDecoration(
                        color: PdfColors.blueAccent700, // Color de fondo
                      ),
                    ),
                  ],
                ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Agregar la tabla vertical en la esquina superior derecha
                      pw.Table.fromTextArray(
                        //context: context,
                        columnWidths: {
                          0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                          1: pw.FixedColumnWidth(70), // Ancho de la segunda columna
                        },
                        data: [
                          ['No:', '${cotizacion.number}'],
                        ],
                        cellAlignment: pw.Alignment.center,
                        headerStyle: cotizacionTextStyle,
                      ),
                      // Añadir otro contenido aquí si es necesario
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Agregar la tabla vertical en la esquina superior derecha
                      pw.Table.fromTextArray(
                        //context: context,
                        columnWidths: {
                          0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                          1: pw.FixedColumnWidth(70), // Ancho de la segunda columna
                        },
                        data: [
                          ['Fecha:', '${cotizacion.fecha}'],
                        ],
                        cellAlignment: pw.Alignment.center,
                        headerStyle: dataTextStyle,
                      ),
                    ],
                  ),
                ],),
            ]
      ),
    );
    // Define el pie de página que se agregará a todas las páginas
    final pw.Widget footer = pw.Row(
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Agregar la tabla vertical en la esquina superior derecha
              pw.Table.fromTextArray(
                columnWidths: {
                  0: pw.FixedColumnWidth(25), // Ancho de la primera columna
                },
                data: [
                  [
                    'MAQUINADOS CORREA S DE RL DE CV      RFC. MCO16070589A\nCerrada Flor de Camelia No. 4, Col. Santa Rosa de Lima, Cuautitlán Izcalli, Edo. de México, CP 54740. \nTel: 55-65-85-37-47      www.maquinadoscorrea.mx'
                  ],
                ],
                border: null,
                cellAlignment: pw.Alignment.center,
                headerStyle: finTextStyle,
              ),
            ],
          ),
        ),
      ],
    );

    //Agregar contenido al PDF
    pdf.addPage(pw.MultiPage(
        header: (pw.Context context) => header, // Utiliza el encabezado definido
        footer: (pw.Context context) => footer, // Utiliza el pie de página definido
        pageFormat: pdfPageFormat,
        margin: pw.EdgeInsets.fromLTRB(20, 25, 25, 15),
        build: (pw.Context context) {
          return[ pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              ...contenidoPDF,
              if (cotizacion.coment1 == 'si' || cotizacion.coment2 == 'si' ||
                  cotizacion.coment3 == 'si')
                ...comentWidget,
              if (cotizacion.coment1 == 'si')
                ...coment1Widget,
              if (cotizacion.coment2 == 'si')
                ...coment2Widget,
              if (cotizacion.coment3 == 'si')
                ...coment3Widget,
              if (cotizacion.agreg1 == 'si' || cotizacion.agreg2 == 'si' ||
                  cotizacion.agreg3 == 'si' || cotizacion.agreg4 == 'si' || cotizacion.coment1 == 'si' || cotizacion.coment2 == 'si' ||
              cotizacion.coment3 == 'si' || cotizacion.garant == 'si' || cotizacion.banc == 'si')
              pw.Divider(color: PdfColors.red),
              if (cotizacion.agreg1 == 'si' || cotizacion.agreg2 == 'si' ||
                  cotizacion.agreg3 == 'si' || cotizacion.agreg4 == 'si')
                ...valWidget,
              if (cotizacion.agreg1 == 'si')
                ...reportedimWidget,
              if (cotizacion.agreg2 == 'si')
                ...reporterugWidget,
              if (cotizacion.agreg3 == 'si')
                ...reportetratWidget,
              if (cotizacion.agreg4 == 'si')
                ...reportematWidget,
              if (cotizacion.banc == 'si')
                ...bancariosWidget,
              if (cotizacion.garant == 'si')
                ...garantiasWidget,


              pw.SizedBox(height: 10), // Espacio de 2 c
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Atentamente',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 10,
                    font: pw.Font.timesBold(),
                  ),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '${cotizacion.vendedores!.name}',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Cel:${cotizacion.vendedores!.number}',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '${cotizacion.vendedores!.email}',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          )];
        },
      ),
    );
    //////////////////////////////////////////////////////////////////

    // Guardar el archivo PDF en la memoria del dispositivo
    Future<Directory?> getDownloadsDirectory() async {
      if (Platform.isAndroid) {
        return Directory('/storage/emulated/0/Download');
      } else {
        return getApplicationDocumentsDirectory(); // Alternativa para otros sistemas
      }
    }
    //final directory = await getExternalStorageDirectory();
    final directory = await getDownloadsDirectory();
    final file = File('${directory!.path}/${cotizacion.number}.pdf');
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
    // // Guardar el archivo PDF en la memoria del dispositivo
    // final dir = (await getApplicationDocumentsDirectory()).path;
    // final file = File('$dir/ejemplo.pdf');
    // await file.writeAsBytes(bytes);
  }
  List<pw.Widget> getProductDetails() {
    List<pw.Widget> details = [];
    // Filtrar productos en espera
    List<Producto> productosEspera = cotizacion.producto!
        .where((producto) => producto.estatus == 'EN ESPERA')
        .toList();
    // Construir la lista de detalles de productos en espera
    productosEspera.forEach((producto) {
      details.add(pw.Text(
          'Articulo: ${producto.articulo}, Material: ${producto.name}, Cantidad: ${producto.cantidad}'));
    });
    return details;
  }
}

