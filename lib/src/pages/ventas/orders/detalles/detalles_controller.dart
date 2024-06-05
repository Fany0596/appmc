import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/user.dart';
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

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  ProductoProvider productoProvider = ProductoProvider();
  VendedoresProvider vendedoresProvider = VendedoresProvider();
  List<String> estatus = <String>['POR ASIGNAR','EN ESPERA', 'EN PROCESO', 'SUSPENDIDO', 'TERMINADO', 'LIBERADO','ENTREGADO', 'CANCELADO'].obs;

  var garantiasAgregadas = false.obs;
  var bancariosAgregadas = false.obs;

  // Método para cambiar el estado de garantías agregadas
  void toggleGarantiasAgregadas() {
    garantiasAgregadas.value = !garantiasAgregadas.value;
    print('valor Garantias: ${garantiasAgregadas.value}');
  }
  void toggleBancariosAgregadas() {
    bancariosAgregadas.value = !bancariosAgregadas.value;
    print('valor Bancarios: ${bancariosAgregadas.value}');
  }

VentasDetallesController(){
  print('Cotizacion: ${cotizacion.toJson()}');
  getTotal();
}
  Future<List<Producto>> getProducto(String estatus) async {
    return await productoProvider.findByStatus(estatus);
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
  void updateCotizacion() async {

      ResponseApi responseApi = await cotizacionProvider.updateconfirmada(
          cotizacion);
      Get.snackbar('Proceso terminado', responseApi.message ?? '');
      if (responseApi.success == true) {
        Get.offNamedUntil('/ventas/home', (route) => false);

    }
    else {
      Get.snackbar('Peticion denegada', 'verifique informacion');
    }
  }
  void updateCancelada() async {

    ResponseApi responseApi = await cotizacionProvider.updatecancelada(
        cotizacion);
    Get.snackbar('Proceso terminado', responseApi.message ?? '');
    if (responseApi.success == true) {
      Get.offNamedUntil('/ventas/home', (route) => false);

    }
    else {
      Get.snackbar('Peticion denegada', 'verifique informacion');
    }
  }
  void getTotal(){
    totalt.value = 0.0;
    cotizacion.producto!.forEach((producto) {
      totalt.value = totalt.value + producto.total!;
    });
  }
  List<pw.Widget> contenidoPDF = [];
  List<pw.Widget> garantiasWidget = [];
  List<pw.Widget> bancariosWidget = [];

  Future<void> generarPDF() async {
    // Accede a la imagen desde los activos de tu aplicación
    ByteData imageData = await rootBundle.load('assets/img/logoC.png');
    // Convierte los datos de la imagen a un arreglo de bytes
    Uint8List bytess = imageData.buffer.asUint8List();
    // Obtener la lista de productos en espera
    List<Producto> productosAsignar = cotizacion.producto!
        .where((producto) => producto.estatus == 'POR ASIGNAR')
        .toList();
    // Crear una lista de listas para almacenar los datos de los productos
    List<List<String>> productosData = [];

    // Agregar los encabezados a la lista de datos
    productosData.add(['CANT.', 'DESCRIPCIÓN', 'P. UNIT.', 'TOTAL']);

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


    final pw.TextStyle headerTextStyle = pw.TextStyle(
        fontWeight: pw.FontWeight.bold, fontSize: 10);
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
                    ['Cliente:', '${cotizacion.clientes!.name}'],
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
                    ['Contacto:', '${cotizacion.nombre}'],
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
                    ['Requerimiento:', ''],
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
              final textStyle = productosData.indexOf(row) == 0
                  ? headerTextStyle
                  : dataTextStyle;
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
                      0: pw.FixedColumnWidth(40),
                      // Ancho de la primera columna
                      1: pw.FixedColumnWidth(190),
                      // Ancho de la segunda columna
                    },
                    data: [
                      [
                        'Comentarios:',
                        '- La vigencia de esta cotización será de 15 dias a partir de esta fecha.\n- Los precios son en moneda nacional.\n- La entrega es hasta el almacén del cliente sin costo adicional, así como las visitas técnicas que se requieran.'
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
      pw.SizedBox(height: 20), // Espacio de 2 cm
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
                      '- ${cotizacion.condiciones ?? ''}\n- ${cotizacion
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
      pw.SizedBox(height: 5), // Espacio de 2 cm
      pw.Divider(color: PdfColors.red),
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
                      [
                        '                                                                                              VALORES AGREGADOS\n\n°Reportes dimensiónales con equipos digitales y certificados (envío vía mail previo a la entrega con evidencia fotográfica).\n°Reporte de rugosidad (en caso de ser necesario).\n°Certificados de calidad de tratamiento termico.\n°Certificado de calidad de materiales.\n'
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
      pw.SizedBox(height: 10), // Espacio de 2 cm
    ];
    if (bancariosAgregadas == true) {
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
    if (garantiasAgregadas == true) {
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
                    'MAQUINADOS CORREA',
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
                          ['Fecha:', '$currentDate'],
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
              if (bancariosAgregadas.value)
                ...bancariosWidget,
              if (garantiasAgregadas.value)
                ...garantiasWidget,


              pw.SizedBox(height: 20), // Espacio de 2 c
              pw.Container(
                margin: pw.EdgeInsets.only(left: 250), // Margen superior
                child: pw.Text(
                  'Atentamente',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 10,
                    font: pw.Font.timesBold(),
                  ),
                ),
              ),
              pw.Container(
                margin: pw.EdgeInsets.only(left: 238), // Margen superior
                child: pw.Text(
                  '${cotizacion.vendedores!.name}',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Container(
                margin: pw.EdgeInsets.only(left: 240), // Margen superior
                child: pw.Text(
                  'Cel:${cotizacion.vendedores!.number}',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Container(
                margin: pw.EdgeInsets.only(left: 193), // Margen superior
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
    //final directory = await getExternalStorageDirectory();
    final directory = await getDownloadsDirectory();
    final file = File('${directory!.path}/${cotizacion.number}.pdf');
    await file.writeAsBytes(await pdf.save());
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

