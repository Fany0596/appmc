import 'package:flutter/material.dart';
import 'package:maquinados_correa/src/models/product.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/providers/oc_provider.dart';
import 'package:maquinados_correa/src/providers/product_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:maquinados_correa/src/providers/vendedor_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;


class GenericoDetallesController extends GetxController {
  Cotizacion cotizacion = Cotizacion.fromJson(Get.arguments['cotizacion']);
  var ocList = <Oc>[].obs;

  final logger = Logger(
    printer: PrettyPrinter(),
    filter: ProductionFilter(), // Solo registra mensajes de nivel de advertencia o superior en producción
  );

  var user = User
      .fromJson(GetStorage().read('user') ?? {})
      .obs;
  var totalt = 0.0.obs;

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  OcProvider ocProvider = OcProvider();
  ProductoProvider productoProvider = ProductoProvider();
  ProductProvider productProvider = ProductProvider();
  VendedoresProvider vendedoresProvider = VendedoresProvider();
  List<String> estatus = <String>[
    'POR ASIGNAR',
    'EN ESPERA',
    'EN PROCESO',
    'SUSPENDIDO',
    'SIG. PROCESO',
    'RECHAZADO',
    'RETRABAJO',
    'LIBERADO',
    'ENTREGADO',
    'CANCELADO'
  ].obs;


  GenericoDetallesController() {
    print('Cotizacion: ${cotizacion.toJson()}');
    cargarOcRelacionada();
  }

  RxList<Producto> productosPorEstatus = <Producto>[].obs;

  // Método para cargar los productos de la cotización según el estatus seleccionado
  Future<void> cargarProductosPorEstatus(String estatus) async {
    // Limpiar la lista de productos antes de cargar nuevos productos
    productosPorEstatus.clear();

    // Obtener los productos de la cotización por el estatus seleccionado
    List<Producto> productosCotizacion = cotizacion.producto!;
    productosPorEstatus.addAll(
        productosCotizacion.where((producto) => producto.estatus == estatus));
    print('Productos por estado $estatus: $productosPorEstatus');
  }

  Future<void> cargarOcRelacionada() async {
    try {
      List<Oc> ocRelacionadas = await ocProvider.getOcByCotizacion(cotizacion.id!);
      print('Response from API: $ocRelacionadas');
      if (ocRelacionadas != null && ocRelacionadas.isNotEmpty) {
        ocList.value = ocRelacionadas;
      } else {
        Get.snackbar(
            'Error', 'No se encontraron OCs relacionadas con esta cotización');
      }
    } catch (e) {
      print('Error al cargar OCs: $e');
      Get.snackbar('Error', 'Ocurrió un error al cargar las OCs');
    }
  }
  Future<void> descargarPDF(String url) async {
    if (url.isEmpty) {
      Get.snackbar('Error', 'No hay URL de PDF para este producto');
      return;
    }

    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        Future<Directory?> getDownloadsDirectory() async {
          if (Platform.isAndroid) {
            return Directory('/storage/emulated/0/Download');
          } else {
            return getApplicationDocumentsDirectory(); // Alternativa para otros sistemas
          }
        }
        final directory = await getApplicationDocumentsDirectory();

        // Extrae el nombre del archivo de la URL y elimina los parámetros de consulta
        String fileName = path.basename(uri.path).split('?').first;

        // Reemplaza caracteres no válidos en el nombre del archivo
        fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
        fileName = fileName.replaceAll('%20', ' '); // Reemplaza %20 con espacios

        final filePath = path.join(directory.path, fileName);

        // Escribe el archivo
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        Get.snackbar('DOCUMENTO DESCARGADO EN:', '${file.path}', backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al descargar el PDF: $e');
      Get.snackbar('Error', 'No se pudo descargar el PDF');
    }
  }
  Future<void> generarOc() async {
    try {
      for (Oc oc in ocList) {
        totalt.value = 0.0;
        oc.product!.forEach((product) {
          totalt.value = totalt.value + product.total!;
        });
        // Accede a la imagen desde los activos de tu aplicación
        ByteData imageData = await rootBundle.load('assets/img/logoC.png');
        // Convierte los datos de la imagen a un arreglo de bytes
        Uint8List bytess = imageData.buffer.asUint8List();
        // Obtener la lista de productos en espera
        List<Product> productEspera = oc.product!
            .where((product) => product.estatus != 'CANCELADO')
            .toList();
        // Crear una lista de listas para almacenar los datos de los productos
        List<List<String>> productData = [];
        final ivaValue = totalt.value * 0.16;
        final totValue = totalt.value + ivaValue;
        DateTime entDate = DateTime.parse(oc.ent!);
        DateTime soliDate = DateTime.parse(oc.soli!);

        final entregaValue = soliDate
            .difference(entDate)
            .inDays * (-1);

        // Agregar los encabezados a la lista de datos
        //productData.add(['', 'DESCRIPCIÓN', 'CANT.','UNIDAD', 'P/U', 'TOTAL']);

        // Agregar los datos de cada producto a la lista de datos
        for (int i = 0; i < productEspera.length; i++) {
          Product product = productEspera[i];
          final cantidadFormatted = product.cantidad!.toStringAsFixed(0);
          final precioFormatted = NumberFormat.currency(
              locale: 'es_MX', symbol: '\$').format(product.precio);
          final totalFormatted = NumberFormat.currency(
              locale: 'es_MX', symbol: '\$').format(product.total);
          productData.add([
            (i + 1).toString(),
            product.descr.toString(),
            cantidadFormatted,
            product.unid.toString(),
            // Puedes reemplazar con el dato real si lo tienes
            precioFormatted,
            totalFormatted
          ]);
        }

        //int totalCantidad = productEspera.fold(0, (sum, item) => sum + item.cantidad!);
        final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final currencyFormat = NumberFormat.currency(
            locale: 'es_MX', symbol: '\$');
        final totaltFormatted = currencyFormat.format(totalt.value);
        final enviotFormatted = oc.envio != null && oc.envio!.isNotEmpty
            ? currencyFormat.format(oc.envio)
            : '';
        final cotizacionTextStyle = pw.TextStyle(
          color: PdfColors.red, fontSize: 9, fontWeight: pw.FontWeight.bold,);

        // Crear el documento PDF
        final pdf = pw.Document();
        final pdfPageFormat = PdfPageFormat.letter;

        final pw.TextStyle headertTextStyle = pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 11,
            color: PdfColors.white);
        final pw.TextStyle headerTextStyle = pw.TextStyle(
            fontWeight: pw.FontWeight.bold, fontSize: 11);
        final pw.TextStyle timeTextStyle = pw.TextStyle(fontSize: 10);
        final pw.TextStyle dataTextStyle = pw.TextStyle(fontSize: 9);
        final pw.TextStyle datatTextStyle = pw.TextStyle(fontSize: 8);

        // Agregar contenido al PDF
        pdf.addPage(
          pw.Page(
            pageFormat: pdfPageFormat,
            margin: pw.EdgeInsets.fromLTRB(20, 25, 25, 15),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo en la esquina superior izquierda
                      pw.Container(
                        width: 70,
                        height: 70,
                        child: pw.Image(pw.MemoryImage(bytess)),
                      ),
                      pw.Text(
                        'ORDEN DE COMPRA',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Column(
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // Agregar la tabla vertical en la esquina superior derecha
                              pw.Table.fromTextArray(
                                //context: context,
                                columnWidths: {
                                  0: pw.FixedColumnWidth(50),
                                  // Ancho de la primera columna
                                  1: pw.FixedColumnWidth(70),
                                  // Ancho de la segunda columna
                                },
                                data: [
                                  ['No:', '${oc.number!}'],
                                ],
                                cellAlignment: pw.Alignment.topLeft,
                                headerAlignment: pw.Alignment.topLeft,
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
                                  0: pw.FixedColumnWidth(50),
                                  // Ancho de la primera columna
                                  1: pw.FixedColumnWidth(70),
                                  // Ancho de la segunda columna
                                },
                                data: [
                                  ['Fecha:', '${oc.soli}'],
                                ],
                                cellAlignment: pw.Alignment.topLeft,
                                headerAlignment: pw.Alignment.topLeft,
                                headerStyle: dataTextStyle,
                              ),
                            ],
                          ),
                        ],),
                    ],
                  ),
                  pw.SizedBox(height: 10),
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
                                ['VENDEDOR:'],
                              ],
                              //border: null,
                              cellAlignment: pw.Alignment.center,
                              headerAlignment: pw.Alignment.topLeft,
                              headerDecoration: pw.BoxDecoration(
                                color: PdfColors
                                    .blueAccent700, // Color de fondo del encabezado
                              ),
                              headerStyle: headertTextStyle,
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
                              },
                              data: [
                                [' '],
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
                                ['ENVIE A:'],
                              ],
                              //border: null,
                              cellAlignment: pw.Alignment.center,
                              headerAlignment: pw.Alignment.topLeft,
                              headerDecoration: pw.BoxDecoration(
                                color: PdfColors
                                    .blueAccent700, // Color de fondo del encabezado
                              ),
                              headerStyle: headertTextStyle,
                            ),
                            pw.SizedBox(height: 10),
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
                                0: pw.FixedColumnWidth(40),
                                // Ancho de la primera columna
                              },
                              data: [
                                [
                                  '${oc.provedor!.name},\n${oc.provedor!
                                      .nombre != null &&
                                      oc.provedor!.nombre!.isNotEmpty
                                      ? oc.provedor!.nombre
                                      : ''}.\n${oc.provedor!.direc}'
                                ],
                              ],
                              border: null,
                              cellAlignment: pw.Alignment.center,
                              headerAlignment: pw.Alignment.topLeft,
                              headerStyle: dataTextStyle,
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
                              },
                              data: [
                                [' '],
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
                                  'MAQUINADOS CORREA\nCerrada Flor de Camelia, Mz.34 Lt.4\nSanta Rosa de Lima, Cuautitlan Izcalli,\nEdo. México, México, C.P. 54740.\nTel. (55) 58 68 34 58'
                                ],
                              ],
                              border: null,
                              cellAlignment: pw.Alignment.center,
                              headerAlignment: pw.Alignment.topLeft,
                              headerStyle: dataTextStyle,
                            ),
                            pw.SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
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
                                0: pw.FixedColumnWidth(100),
                                // Ancho de la primera columna
                                1: pw.FixedColumnWidth(110),
                                // Ancho de la segunda columna
                                2: pw.FixedColumnWidth(80),
                                // Ancho de la segunda columna
                                3: pw.FractionColumnWidth(0.4),
                                // Ancho de la segunda columna
                              },
                              data: [
                                [
                                  'TIPO DE COMPRA',
                                  'CONDICIONES DE PAGO',
                                  'MONEDA',
                                  'COMPRADOR'
                                ],
                              ],
                              //border: null,
                              cellAlignment: pw.Alignment.center,
                              headerAlignment: pw.Alignment.center,
                              headerDecoration: pw.BoxDecoration(
                                color: PdfColors
                                    .blueAccent700, // Color de fondo del encabezado
                              ),
                              headerStyle: headertTextStyle,
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
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            // Agregar la tabla vertical en la esquina superior derecha
                            pw.Table.fromTextArray(
                              //context: context,
                              columnWidths: {
                                0: pw.FixedColumnWidth(100),
                                // Ancho de la primera columna
                                1: pw.FixedColumnWidth(110),
                                // Ancho de la segunda columna
                                2: pw.FixedColumnWidth(80),
                                // Ancho de la segunda columna
                                3: pw.FractionColumnWidth(0.4),
                                // Ancho de la segunda columna
                              },
                              data: [
                                [
                                  '${oc.tipo}',
                                  '${oc.condiciones}',
                                  '${oc.moneda}',
                                  '${oc.comprador!.name}'
                                ],
                              ],
                              //border: null,
                              cellAlignment: pw.Alignment.center,
                              headerAlignment: pw.Alignment.center,
                              headerStyle: dataTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
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
                                0: pw.FixedColumnWidth(40),
                                1: pw.FractionColumnWidth(0.4),
                                2: pw.FixedColumnWidth(60),
                                3: pw.FixedColumnWidth(60),
                                4: pw.FixedColumnWidth(50),
                                5: pw.FixedColumnWidth(60),
                                // Ancho de la segunda columna
                              },
                              data: [
                                [
                                  '',
                                  'DESCRIPCIÓN',
                                  'CANT.',
                                  'UNIDAD',
                                  'P/U',
                                  'TOTAL'
                                ],
                              ],
                              //border: null,
                              cellAlignment: pw.Alignment.center,
                              headerAlignment: pw.Alignment.center,
                              headerDecoration: pw.BoxDecoration(
                                color: PdfColors
                                    .blueAccent700, // Color de fondo del encabezado
                              ),
                              headerStyle: headertTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: pw.FixedColumnWidth(40),
                      1: pw.FractionColumnWidth(0.4),
                      2: pw.FixedColumnWidth(60),
                      3: pw.FixedColumnWidth(60),
                      4: pw.FixedColumnWidth(50),
                      5: pw.FixedColumnWidth(60),
                    },

                    children: productData.map((row) {
                      return pw.TableRow(
                        children: row.map((cell) {
                          final textStyle = dataTextStyle;
                          //final textStyle = productData.indexOf(row) == 0 ? headerTextStyle : dataTextStyle;
                          return pw.Container(
                            alignment: pw.Alignment.center,
                            child: pw.Text(cell, style: textStyle),
                            padding: const pw.EdgeInsets.all(8),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // Agregar la tabla vertical en la esquina superior derecha
                          pw.Table.fromTextArray(
                            //context: context,
                            columnWidths: {
                              0: pw.FixedColumnWidth(57),
                              1: pw.FixedColumnWidth(68.5),
                              // Ancho de la segunda columna
                            },
                            data: [
                              ['SUBTOT:', totaltFormatted],
                            ],
                            //border: null,
                            cellAlignment: pw.Alignment.center,
                            headerAlignment: pw.Alignment.center,
                            headerStyle: datatTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // Agregar la tabla vertical en la esquina superior derecha
                          pw.Table.fromTextArray(
                            //context: context,
                            columnWidths: {
                              0: pw.FixedColumnWidth(57),
                              1: pw.FixedColumnWidth(68.5),
                              // Ancho de la segunda columna
                            },
                            data: [
                              ['IMPUESTO:', currencyFormat.format(ivaValue)],
                            ],
                            //border: null,
                            cellAlignment: pw.Alignment.center,
                            headerAlignment: pw.Alignment.center,
                            headerStyle: datatTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // Agregar la tabla vertical en la esquina superior derecha
                          pw.Table.fromTextArray(
                            //context: context,
                            columnWidths: {
                              0: pw.FixedColumnWidth(57),
                              1: pw.FixedColumnWidth(68.5),
                              // Ancho de la segunda columna
                            },
                            data: [
                              ['ENVÍO:', enviotFormatted],
                            ],
                            cellAlignment: pw.Alignment.center,
                            headerAlignment: pw.Alignment.center,
                            headerStyle: datatTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // Agregar la tabla vertical en la esquina superior derecha
                          pw.Table.fromTextArray(
                            //context: context,
                            columnWidths: {
                              0: pw.FixedColumnWidth(57),
                              1: pw.FixedColumnWidth(68.5),
                              // Ancho de la segunda columna
                            },
                            data: [
                              ['TOTAL:', currencyFormat.format(totValue)],
                            ],
                            //border: null,
                            cellAlignment: pw.Alignment.center,
                            headerAlignment: pw.Alignment.center,
                            headerStyle: headerTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Favor de enviar certificado de material al correo de calidad@maquinadoscorrea.mx',
                    style: pw.TextStyle(color: PdfColors.blue, fontSize: 12),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('TIEMPO DE ENTREGA: ${entregaValue} días.',
                      style: timeTextStyle),
                  pw.SizedBox(height: 10),
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
                                  ['COMENTARIOS O INSTRUCCIONES ESPECIALES:'],
                                ],
                                //border: null,
                                cellAlignment: pw.Alignment.center,
                                headerAlignment: pw.Alignment.topLeft,
                                headerDecoration: pw.BoxDecoration(
                                  color: PdfColors
                                      .blueAccent700, // Color de fondo del encabezado
                                ),
                                headerStyle: headertTextStyle,
                              ),
                              pw.SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ]),
                  pw.Text(
                      '${oc.coment != null && oc.coment!.isNotEmpty
                          ? oc.coment : ''}', style: timeTextStyle),
                  pw.SizedBox(height: 40),
                  pw.Center(
                    child: pw.Text(
                      'Si usted tiene alguna pregunta sobre esta orden de compra, por favor, póngase en contacto con',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                  ),
                  pw.Center(
                    child: pw.Text(
                      '${oc.comprador!.name}, Tel: ${oc.comprador!
                          .number}, ${oc.comprador!.email}',
                      style: dataTextStyle,
                    ),
                  ),
                ],
              );
            },
          ),
        );
        //////////////////////////////////////////////////////////////////
        Future<Directory?> getDownloadsDirectory() async {
          if (Platform.isAndroid) {
            return Directory('/storage/emulated/0/Download');
          } else {
            return getApplicationDocumentsDirectory(); // Alternativa para otros sistemas
          }
        }
        final directory = await getDownloadsDirectory();
        final file = File('${directory!.path}/${oc.number}.pdf');
        await file.writeAsBytes(await pdf.save());
        final bytes = await pdf.save();
        Get.snackbar('DOCUMENTO DESCARGADO EN:', '${file.path}',
          backgroundColor: Colors.green,
          colorText: Colors.white,);
        print('PDF guardado en: ${file.path}');


        await file.writeAsBytes(bytes);
        logger.i('Se pudo escribir el archivo correctamente');
      }} catch (e) {
        logger.e('Error al escribir el archivo: $e');
      }
  }
  Future<void> generarPDFs(producto) async {
    ByteData imageData = await rootBundle.load('assets/img/LOGO1.png');
    // Convierte los datos de la imagen a un arreglo de bytes
    Uint8List bytess = imageData.buffer.asUint8List();

    ByteData imageData2 = await rootBundle.load('assets/img/HOJAV.png');
    // Convierte los datos de la imagen a un arreglo de bytes
    Uint8List byteess = imageData2.buffer.asUint8List();

        final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        List<List<String>> datad = [
          ['Código'],
          ['P-CL-002  '],
          ['N° Revisión'],
          ['1'],
        ];

        final pdf = pw.Document();
        final pdfPageFormat = PdfPageFormat.letter;
        final pw.TextStyle headerTextStyle = pw.TextStyle(fontSize: 6);
        //final pw.TextStyle headerTextStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12);
        final pw.TextStyle dataTextStyle = pw.TextStyle(fontSize: 5);
        //Agregar contenido al PDF
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
                              //File('assets/img/LOGO1.png').readAsBytesSync(),
                            ),
                          ),
                          width: 50,
                          height: 50,
                        ),
                        // Título centrado
                        pw.Expanded(
                          child: pw.Center(
                            child: pw.Text(
                              'Check List (Hoja De Inspección)',
                              style: pw.TextStyle(
                                fontSize: 15,
                                fontWeight: pw.FontWeight.bold,
                                font: pw.Font.timesBold(),
                              ),
                            ),
                          ),
                        ),
                        // Contenedor para la tabla vertical
                        pw.Container(
                          width: 50, // Ancho fijo para la tabla
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              // Agregar la tabla vertical en la esquina superior derecha
                              pw.Table.fromTextArray(
                                context: context,
                                data: datad,
                                cellStyle: pw.TextStyle(fontSize: 5),
                                headerStyle: headerTextStyle,
                                //border: const pw.TableBorder(left: BorderSide(), right: BorderSide(), top: BorderSide(), bottom: BorderSide(), horizontalInside: BorderSide(), verticalInside: BorderSide()),
                                cellAlignment: pw.Alignment.center,
                              ),
                              // Añadir otro contenido aquí si es necesario
                              //pw.SizedBox(height: 10), // Espacio entre la tabla y otro contenido
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Separador
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
                                ['Cliente:', '${cotizacion.clientes!.name}'],
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
                                ['Fecha:', '$currentDate'],
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
                                ['Material: ', '${producto.name}'],
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
                                ['Fecha entrega:', '${producto.fecha}'],
                              ],
                              cellAlignment: pw.Alignment.topLeft,
                              // Alinear el texto de la primera columna a la izquierda
                              cellAlignments: {
                                1: pw.Alignment.center,
                                // Alinear el texto de la segunda columna al centro
                              },
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
                                ['No. Parte/ OC:', '${producto.parte}'],
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
                                ['Cantidad:', '${producto.cantidad}'],
                              ],
                              cellAlignment: pw.Alignment.topLeft,
                              // Alinear el texto de la primera columna a la izquierda
                              cellAlignments: {
                                1: pw.Alignment.center,
                                // Alinear el texto de la segunda columna al centro
                              },
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
                                ['Descripción:', '${producto.articulo}'],
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

                  // Contenido de la cotización
                  pw.SizedBox(height: 5),
                  pw.Container(
                    //margin: pw.EdgeInsets.only(right: 5),
                    child: pw.Image(
                      pw.MemoryImage(
                          byteess
                        //File('assets/img/HOJAV.png').readAsBytesSync(),
                      ),
                    ),
                    width: 660, // Ancho disponible menos el margen derecho
                    height: 1640,
                  ),

                  pw.SizedBox(height: 15),
                  pw.Row(
                    children: [ // Espacio de 8 cm
                      pw.Container(
                        height: 1, // Altura de la línea
                        width: 140, // Ancho de la línea
                        color: PdfColors.black, // Color de la línea
                      ),
                      pw.Container(
                        margin: pw.EdgeInsets.only(top: 10, left: 60),
                        height: 1, // Altura de la línea
                        width: 140, // Ancho de la línea
                        color: PdfColors.black, // Color de la línea
                      ),
                      pw.Container(
                        margin: pw.EdgeInsets.only(top: 10, left: 60),
                        height: 1, // Altura de la línea
                        width: 140, // Ancho de la línea
                        color: PdfColors.black, // Color de la línea
                      ),
                    ],
                  ),
                  // Texto "PRODUCCIÓN"
                  pw.Row(
                    children: [
                      pw.Container(
                        margin: pw.EdgeInsets.only(left: 40), // Margen superior
                        child: pw.Text(
                          'PRODUCCIÓN',
                          style: pw.TextStyle(fontSize: 8,
                            font: pw.Font.timesBold(),
                          ),
                        ),
                      ),
                      pw.Container(
                        margin: pw.EdgeInsets.only(left: 160),
                        // Margen superior
                        child: pw.Text(
                          'CALIDAD',
                          style: pw.TextStyle(fontSize: 8,
                            font: pw.Font.timesBold(),
                          ),
                        ),
                      ),
                      pw.Container(
                        margin: pw.EdgeInsets.only(left: 135),
                        // Margen superior
                        child: pw.Text(
                          'LIBERACIÓN Y CIERRE',
                          style: pw.TextStyle(fontSize: 8,
                            font: pw.Font.timesBold(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Row(
                    children: [
                      pw.Container(
                        margin: pw.EdgeInsets.only(left: 25), // Margen superior
                        child: pw.Text(
                          'Alejandro Correa Ochoa',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        margin: pw.EdgeInsets.only(left: 115),
                        // Margen superior
                        child: pw.Text(
                          'Oscar Correa/ Erik Sánchez',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        margin: pw.EdgeInsets.only(left: 120),
                        // Margen superior
                        child: pw.Text(
                          'Paola Gonzalez',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 2),
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
                          },
                          data: [
                            [
                              'Nota: Colocar la siguiente nomenclatura que corresponde a los diferentes equipos de medición: CBD-Calibrador digital, B3D-Bowers 3 punto, GNG-Go-NoGo, MCD-Micrometro digital, CA-Calibrador de alturas, CR-Calibrador de ranuras, CD-Compas digital, CRI- Calibrador de ranuras interiores'
                            ],
                          ],
                          cellAlignment: pw.Alignment.center,
                          cellStyle: pw.TextStyle(fontSize: 3),
                          headerStyle: headerTextStyle,
                        ),
                        // Añadir otro contenido aquí si es necesario
                        pw.SizedBox(height: 2),
                        // Espacio entre la tabla y otro contenido
                      ],
                    ),
                  ),

                ],
              );
            },
          ),
        );
// Guardar el archivo PDF en la memoria del dispositivo
        Future<Directory?> getDownloadsDirectory() async {
          if (Platform.isAndroid) {
            return Directory('/storage/emulated/0/Download');
          } else {
            return getApplicationDocumentsDirectory(); // Alternativa para otros sistemas
          }
        }
        final directory = await getDownloadsDirectory();
        final file = File('${directory!.path}/HI-${producto.articulo}.pdf');
        await file.writeAsBytes(await pdf.save());
        final bytes = await pdf.save();
        Get.snackbar('DOCUMENTO DESCARGADO EN:', '${file.path}', backgroundColor: Colors.green,
          colorText: Colors.white,);
        print('PDF guardado en: ${file.path}');
        try {
          await file.writeAsBytes(bytes);
          logger.i('Se pudo escribir el archivo correctamente');
        } catch (e) {
          logger.e('Error al escribir el archivo: $e');
        }
    }
  }


