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
import 'package:maquinados_correa/src/models/product.dart';
import 'package:maquinados_correa/src/providers/product_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:maquinados_correa/src/providers/vendedor_provider.dart';
import 'dart:io';

class GenericoDetallesController extends GetxController {
  Cotizacion cotizacion= Cotizacion.fromJson(Get.arguments['cotizacion']);
  var oc = Oc().obs;

  final logger = Logger(
    printer: PrettyPrinter(),
    filter: ProductionFilter(), // Solo registra mensajes de nivel de advertencia o superior en producción
  );

  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  var totalt = 0.0.obs;

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  OcProvider ocProvider = OcProvider();
  ProductoProvider productoProvider = ProductoProvider();
  ProductProvider productProvider = ProductProvider();
  VendedoresProvider vendedoresProvider = VendedoresProvider();
  List<String> estatus = <String>['POR ASIGNAR','EN ESPERA', 'EN PROCESO', 'SUSPENDIDO', 'TERMINADO', 'LIBERADO','ENTREGADO', 'CANCELADO'].obs;


  GenericoDetallesController(){
  print('Cotizacion: ${cotizacion.toJson()}');
  cargarOcRelacionada();
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
  Future<void> cargarOcRelacionada() async {
    try {
      Oc? ocRelacionada = await ocProvider.getOcByCotizacion(cotizacion.id!);
      print('Response from API: $ocRelacionada');
      if (ocRelacionada != null) {
        oc.value = ocRelacionada;
        getTotal(); // Calcula el total después de cargar la OC
      } else {
        Get.snackbar('Error', 'No se encontró una OC relacionada con esta cotización');
      }
    } catch (e) {
      print('Error al cargar OC: $e');
      Get.snackbar('Error', 'Ocurrió un error al cargar la OC');
    }
  }
  void getTotal(){
    totalt.value = 0.0;
    oc.value.product!.forEach((product) {
      totalt.value = totalt.value + product.total!;
    });
  }
  Future<void> generarOc() async {
    try {
      if (oc.value.id != null) {
        // Accede a la imagen desde los activos de tu aplicación
        ByteData imageData = await rootBundle.load('assets/img/logoC.png');
        // Convierte los datos de la imagen a un arreglo de bytes
        Uint8List bytess = imageData.buffer.asUint8List();
        // Obtener la lista de productos en espera
        List<Product> productEspera = oc.value.product!
            .where((product) => product.estatus != 'CANCELADO')
            .toList();
        // Crear una lista de listas para almacenar los datos de los productos
        List<List<String>> productData = [];
        final ivaValue = totalt.value * 0.16;
        final totValue = totalt.value + ivaValue;
        DateTime entDate = DateTime.parse(oc.value.ent!);
        DateTime soliDate = DateTime.parse(oc.value.soli!);

        final entregaValue = soliDate.difference(entDate).inDays * (-1);

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
            product.unid.toString(), // Puedes reemplazar con el dato real si lo tienes
            precioFormatted,
            totalFormatted
          ]);
        }

        //int totalCantidad = productEspera.fold(0, (sum, item) => sum + item.cantidad!);
        final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
        final totaltFormatted = currencyFormat.format(totalt.value);
        final enviotFormatted = oc.value.envio != null && oc.value.envio!.isNotEmpty
            ? currencyFormat.format(oc.value.envio)
            : '';
        final cotizacionTextStyle = pw.TextStyle(color: PdfColors.red, fontSize: 9, fontWeight: pw.FontWeight.bold,);

        // Crear el documento PDF
        final pdf = pw.Document();
        final pdfPageFormat = PdfPageFormat.letter;

        final pw.TextStyle headertTextStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.white);
        final pw.TextStyle headerTextStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11);
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
                        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
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
                                  0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                                  1: pw.FixedColumnWidth(70), // Ancho de la segunda columna
                                },
                                data: [
                                  ['No:', '${oc.value.number!}'],
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
                                  0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                                  1: pw.FixedColumnWidth(70), // Ancho de la segunda columna
                                },
                                data: [
                                  ['Fecha:', '${oc.value.soli}'],
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
                                0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                              },
                              data: [
                                ['VENDEDOR:'],
                              ],
                              //border: null,
                              cellAlignment: pw.Alignment.center,
                              headerAlignment: pw.Alignment.topLeft,
                              headerDecoration: pw.BoxDecoration(
                                color: PdfColors.blueAccent700, // Color de fondo del encabezado
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
                                0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                              },
                              data: [
                                ['ENVIE A:'],
                              ],
                              //border: null,
                              cellAlignment: pw.Alignment.center,
                              headerAlignment: pw.Alignment.topLeft,
                              headerDecoration: pw.BoxDecoration(
                                color: PdfColors.blueAccent700, // Color de fondo del encabezado
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
                                0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                              },
                              data: [
                                ['${oc.value.provedor!.name},\n${oc.value.provedor!.nombre != null && oc.value.provedor!.nombre!.isNotEmpty
                                    ? oc.value.provedor!.nombre
                                    : ''}.\n${oc.value.provedor!.direc}'],
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
                                0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                              },
                              data: [
                                ['MAQUINADOS CORREA\nCerrada Flor de Camelia, Mz.34 Lt.4\nSanta Rosa de Lima, Cuautitlan Izcalli,\nEdo. México, México, C.P. 54740.\nTel. (55) 58 68 34 58'],
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
                                0: pw.FixedColumnWidth(100), // Ancho de la primera columna
                                1: pw.FixedColumnWidth(110), // Ancho de la segunda columna
                                2: pw.FixedColumnWidth(80), // Ancho de la segunda columna
                                3: pw.FractionColumnWidth(0.4), // Ancho de la segunda columna
                              },
                              data: [
                                ['TIPO DE COMPRA', 'CONDICIONES DE PAGO', 'MONEDA', 'COMPRADOR'],
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
                                0: pw.FixedColumnWidth(100), // Ancho de la primera columna
                                1: pw.FixedColumnWidth(110), // Ancho de la segunda columna
                                2: pw.FixedColumnWidth(80), // Ancho de la segunda columna
                                3: pw.FractionColumnWidth(0.4), // Ancho de la segunda columna
                              },
                              data: [
                                ['${oc.value.tipo}', '${oc.value.condiciones}', '${oc.value.moneda}', '${oc.value.comprador!.name}'],
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
                                5: pw.FixedColumnWidth(60), // Ancho de la segunda columna
                              },
                              data: [
                                ['', 'DESCRIPCIÓN', 'CANT.','UNIDAD', 'P/U', 'TOTAL'],
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
                          final textStyle =  dataTextStyle;
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
                              1: pw.FixedColumnWidth(68.5), // Ancho de la segunda columna
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
                              1: pw.FixedColumnWidth(68.5), // Ancho de la segunda columna
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
                              1: pw.FixedColumnWidth(68.5), // Ancho de la segunda columna
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
                              1: pw.FixedColumnWidth(68.5), // Ancho de la segunda columna
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
                  pw.Text('TIEMPO DE ENTREGA: ${entregaValue} días.', style: timeTextStyle),
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
                                  0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                                },
                                data: [
                                  ['COMENTARIOS O INSTRUCCIONES ESPECIALES:'],
                                ],
                                //border: null,
                                cellAlignment: pw.Alignment.center,
                                headerAlignment: pw.Alignment.topLeft,
                                headerDecoration: pw.BoxDecoration(
                                  color: PdfColors.blueAccent700, // Color de fondo del encabezado
                                ),
                                headerStyle: headertTextStyle,
                              ),
                              pw.SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ]),
                  pw.Text('${oc.value.coment != null && oc.value.coment!.isNotEmpty
                      ? oc.value.coment : ''}', style: timeTextStyle),
                  pw.SizedBox(height: 40),
                  pw.Center(
                    child: pw.Text(
                      'Si usted tiene alguna pregunta sobre esta orden de compra, por favor, póngase en contacto con',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                  ),
                  pw.Center(
                    child: pw.Text(
                      '${oc.value.comprador!.name}, Tel: ${oc.value.comprador!.number}, ${oc.value.comprador!.email}',
                      style: dataTextStyle,
                    ),
                  ),
                ],
              );
            },
          ),
        );
        //////////////////////////////////////////////////////////////////

        // Guardar el archivo PDF en la memoria del dispositivo
        //final directory = await getExternalStorageDirectory();
        final directory = await getDownloadsDirectory();
        final file = File('${directory!.path}/${oc.value.number}.pdf');
        await file.writeAsBytes(await pdf.save());
        Get.snackbar('DOCUMENTO DESCARGADO EN:', '${file.path}');
        print('PDF guardado en: ${file.path}');
        final bytes = await pdf.save();

        try {
          await file.writeAsBytes(bytes);
          logger.i('Se pudo escribir el archivo correctamente');
        } catch (e) {
          logger.e('Error al escribir el archivo: $e');
        }
      } else {
        Get.snackbar('Error', 'No se encontró una OC relacionada con esta cotización');
      }
    } catch (e) {
      print('Error en generarOc: $e');
      Get.snackbar('Error', 'Ocurrió un error al generar la OC');
    }
  }
}

