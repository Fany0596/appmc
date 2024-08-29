import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/models/product.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/oc_provider.dart';
import 'package:maquinados_correa/src/providers/product_provider.dart';
import 'package:maquinados_correa/src/providers/provedor_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:logger/logger.dart';

class ComprasDetallesController extends GetxController {
  Oc oc= Oc.fromJson(Get.arguments['oc']);

  final logger = Logger(
    printer: PrettyPrinter(),
    filter: ProductionFilter(), // Solo registra mensajes de nivel de advertencia o superior en producción
  );

  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  var totalt = 0.0.obs;

  OcProvider ocProvider = OcProvider();
  ProductProvider productProvider = ProductProvider();
  ProvedorProvider provedorProvider = ProvedorProvider();
  List<String> estatus = <String>['SOLICITADO', 'RECIBIDO', 'CANCELADO'].obs;

  ComprasDetallesController(){
    print('OC: ${oc.toJson()}');
    getTotal();
  }
  void reloadPage() async {
    // Llamar al método del provider para obtener la cotización por ID
    Oc? ocActualizada = await ocProvider.getOcById(oc.id!);

    if (ocActualizada != null) {
      // Actualizar la cotización con los nuevos datos
      oc = ocActualizada;

      // Actualizar los productos por cada estado
      for (String estado in estatus) {
        await cargarProductPorEstatus(estado);
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
  Future<List<Product>> getProduct(String estatus) async {
    return await productProvider.findByStatus(estatus);
  }
  RxList<Product> productPorEstatus = <Product>[].obs;

  // Método para cargar los productos de la cotización según el estatus seleccionado
  Future<void> cargarProductPorEstatus(String estatus) async {
    // Limpiar la lista de productos antes de cargar nuevos productos
    productPorEstatus.clear();

    // Obtener los productos de la cotización por el estatus seleccionado
    List<Product> productOc = oc.product!;
    productPorEstatus.addAll(productOc.where((product) => product.estatus == estatus));
    print('Productos por estado $estatus: $productPorEstatus');

  }
  void updateOc() async {

    ResponseApi responseApi = await ocProvider.updatecerrada(oc);
    Get.snackbar('Proceso terminado', responseApi.message ?? '');
    if (responseApi.success == true) {
    }
    else {
      Get.snackbar('Peticion denegada', 'verifique informacion');
    }
  }
  void goToProduct(Product product) {
    print('Producto seleccionado: $product');
    Get.toNamed(
        '/compras/orders/product', arguments: {'product': product.toJson()});
  }
  void goToProductUpdate(Product product) {
    print('Producto seleccionado: $product');
    Get.toNamed(
        '/compras/update/product', arguments: {'product': product.toJson()});
  }
  void updateCancelada() async {

    ResponseApi responseApi = await ocProvider.updatecancelada(oc);
    Get.snackbar('Proceso terminado', responseApi.message ?? '');
    if (responseApi.success == true) {
    }
    else {
      Get.snackbar('Peticion denegada', 'verifique informacion');
    }
  }
  void getTotal(){
    totalt.value = 0.0;
    oc.product!.forEach((product) {
      totalt.value = totalt.value + product.total!;
    });
  }
  void deleteProduct(Product product) async {
    ResponseApi responseApi = await productProvider.deleted(product.id!); // Llama al backend para eliminar el producto
    if (responseApi.success == true) {
      Get.snackbar('Éxito', responseApi.message ?? 'Producto eliminado correctamente', backgroundColor: Colors.green,
        colorText: Colors.white,);
    } else {
      Get.snackbar('Error', responseApi.message ?? 'Error al eliminar el producto', backgroundColor: Colors.red,
        colorText: Colors.white,);
    }
  }

  Future<void> generarOc() async {
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
        '${product.descr} Material: ${product.name}',
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
    final enviotFormatted = oc.envio != null && oc.envio!.isNotEmpty
        ? currencyFormat.format(oc.envio)
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
                              0: pw.FixedColumnWidth(50), // Ancho de la primera columna
                              1: pw.FixedColumnWidth(70), // Ancho de la segunda columna
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
                            ['${oc.provedor!.name},\n${oc.provedor!.nombre != null && oc.provedor!.nombre!.isNotEmpty
                        ? oc.provedor!.nombre
                            : ''}.\n${oc.provedor!.direc}'],
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
                            ['${oc.tipo}', '${oc.condiciones}', '${oc.moneda}', '${oc.comprador!.name}'],
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
              pw.Text('${oc.coment != null && oc.coment!.isNotEmpty
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
                  '${oc.comprador!.name}, Tel: ${oc.comprador!.number}, ${oc.comprador!.email}',
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
    // Guardar el archivo PDF en la memoria del dispositivo
    final directory = await getDownloadsDirectory();
    //final directory = await getExternalStorageDirectory();
    //final directory = await getDownloadsDirectory();
    final file = File('${directory!.path}/${oc.number}.pdf');
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
  List<pw.Widget> getProductDetails() {
    List<pw.Widget> details = [];
    // Filtrar productos en espera
    List<Product> productEspera = oc.product!
        .where((producto) => producto.estatus == 'EN ESPERA')
        .toList();
    // Construir la lista de detalles de productos en espera
    productEspera.forEach((product) {
      details.add(pw.Text(
          'Articulo: ${product.articulo}, Material: ${product.name}, Cantidad: ${product.cantidad}'));
    });
    return details;
  }
}

