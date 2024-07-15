import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';


class ProduccionDetallesController extends GetxController {
   Cotizacion cotizacion = Cotizacion.fromJson(Get.arguments['cotizacion']);

  final logger = Logger(
    printer: PrettyPrinter(),
    filter: ProductionFilter(), // Solo registra mensajes de nivel de advertencia o superior en producción
  );

  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  var totalt = 0.0.obs;
  double totalCantidad = 0.0;

  CotizacionProvider cotizacionProvider = CotizacionProvider();
  ProductoProvider productoProvider = ProductoProvider();
  List<String> estatus = <String>['POR ASIGNAR', 'EN ESPERA', 'CANCELADO'].obs;

  //'EN PROCESO', 'SUSPENDIDO', 'TERMINADO', 'LIBERADO','ENTREGADO', 'CANCELADO'].obs;

  TextEditingController pedidoController = TextEditingController();
  TextEditingController entregaController = TextEditingController();
  TextEditingController otController = TextEditingController();

  ProduccionDetallesController() {
    print('Cotizacion: ${cotizacion.toJson()}');
    getTotal();
    if (cotizacion.status == 'GENERADA') {
      cotizacion.producto?.forEach((producto) {
        // Establecer los valores de pedido, fecha de entrega y OT con los datos de los productos
        pedidoController.text = producto.pedido ?? '';
        entregaController.text = producto.fecha ?? '';
        otController.text = producto.ot ?? '';
        print('Datos recibidos del backend:');
        print('Pedido: ${producto.pedido}');
        print('Articulo: ${producto.articulo}');
        print('Fecha de entrega: ${producto.fecha}');
        print('OT: ${producto.ot}');
      });
    }
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

  void updateCotizacion() async {
    ResponseApi responseApi = await cotizacionProvider.updateconfirmada(
        cotizacion);
    Get.snackbar('Proceso terminado', responseApi.message ?? '');
    if (responseApi.success == true) {
      Get.offNamedUntil('/produccion/home', (route) => false);
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
      Get.offNamedUntil('/produccion/home', (route) => false);
    }
    else {
      Get.snackbar('Peticion denegada', 'verifique informacion');
    }
  }

  void getTotal() {
    totalt.value = 0.0;
    cotizacion.producto!.forEach((producto) {
      if (producto.estatus == 'EN ESPERA') {
        totalt.value = totalt.value + producto.total!;
      }
    });
  }

  void goToOt(Producto producto) {
    print('Producto seleccionado: $producto');
    Get.toNamed(
        '/produccion/orders/ot', arguments: {'producto': producto.toJson()});
  }

  void generar() async {
    // Recorrer todos los productos de la cotización y actualizar los campos
    cotizacion.producto?.forEach((producto) {
      producto.pedido = pedidoController.text;
      producto.fecha = entregaController.text;
      producto.ot = otController.text;
    });
    await generarPDF();
    await generarPDFs();

    if (isValidForm(pedidoController, entregaController,
        otController)) { //valida que no esten vacios los campos
      cotizacion.producto?.forEach((producto) async {
        Producto miproducto = Producto(
          id: producto.id,
          pedido: pedidoController.text,
          fecha: entregaController.text,
          ot: otController.text,
        );


        Stream stream = (await productoProvider.generar(miproducto)) as Stream;
        stream.listen((res) {
          //progressDialog.close();
          ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
          Get.snackbar('Éxito', 'Producto actualizado correctamente');
          print('Response Api Update: ${responseApi.data}');
          //progressDialog.close();

        });
      });
    }
    ResponseApi responseApi = await cotizacionProvider.updategenerada(
        cotizacion);
    Get.snackbar('Proceso terminado', responseApi.message ?? '');
    if (responseApi.success == true) {
      Get.offNamedUntil('/produccion/home', (route) => false);
    }
    else {
      Get.snackbar('Peticion denegada', 'verifique informacion');
    }
  }

  bool isValidForm(TextEditingController pedidoController,
      TextEditingController entregaController,
      TextEditingController otController) {
    // Verificar si el campo de pedido está vacío
    if (pedidoController.text.isEmpty) {
      Get.snackbar('Formulario no válido', 'Ingresa número de cotización');
      return false;
    }

    return true;
  }

  Future<void> generarPDF() async {
    // Accede a la imagen desde los activos de tu aplicación
    ByteData imageData = await rootBundle.load('assets/img/LOGO1.png');
    // Convierte los datos de la imagen a un arreglo de bytes
    Uint8List bytess = imageData.buffer.asUint8List();
    // Obtener la lista de productos en espera
    List<Producto> productosEspera = cotizacion.producto!
        .where((producto) => producto.estatus == 'EN ESPERA')
        .toList();
    // Crear una lista de listas para almacenar los datos de los productos
    List<List<String>> productosData = [];

    // Agregar los encabezados a la lista de datos
    productosData.add(['ITEM', 'CANTIDAD', 'No. PARTE', 'DESCRIPCIÓN']);

    // Agregar los datos de cada producto a la lista de datos
    for (int i = 0; i < productosEspera.length; i++) {
      Producto producto = productosEspera[i];
      productosData.add([(i + 1).toString(), producto.cantidad.toString(), producto.parte.toString(), producto.articulo.toString()]);
    }

    cotizacion.producto!.forEach((producto) {
      if (producto.estatus != 'CANCELADO') {
        totalCantidad = totalCantidad + producto.cantidad!;
      }
    });
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<List<String>> data = [
      ['Código'],
      ['P-OT-002'],
      ['N° Revisión'],
      ['1'],
    ];
    List<List<String>> datad = [
      ['Código'],
      ['P-CL-002  '],
      ['N° Revisión'],
      ['1'],
    ];
    // Crear el documento PDF
    final pdf = pw.Document();
    final pdfPageFormat = PdfPageFormat.letter;

    final pw.TextStyle headerTextStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12);
    final pw.TextStyle dataTextStyle = pw.TextStyle(fontSize: 10);
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
                      pw.Container(
                        //width: 150, // Ancho fijo para la tabla
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            // Agregar la tabla vertical en la esquina superior derecha
                            pw.Table.fromTextArray(
                              context: context,
                              data: data,
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
                            columnWidths: {
                              0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                              1: pw.FixedColumnWidth(70), // Ancho de la segunda columna
                            },
                            data: [
                              ['Cliente:', '${cotizacion.clientes!.name}'],
                            ],
                            cellAlignment: pw.Alignment.center,
                          ),
                          // Añadir otro contenido aquí si es necesario
                          pw.SizedBox(height: 10), // Espacio entre la tabla y otro contenido
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
                            0: pw.FixedColumnWidth(30), // Ancho de la primera columna
                          },
                          data: [
                            ['  '],
                          ],
                          border: null,
                          cellAlignment: pw.Alignment.center,
                        ),
                        // Añadir otro contenido aquí si es necesario
                        pw.SizedBox(height: 10), // Espacio entre la tabla y otro contenido
                      ],
                    ),

                    pw.Expanded(
                      child:pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          // Agregar la tabla vertical en la esquina superior derecha
                          pw.Table.fromTextArray(
                            columnWidths: {
                              0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                              1: pw.FixedColumnWidth(50), // Ancho de la segunda columna
                            },
                            context: context,
                            data: [
                              ['OT:', '${otController.text}'],
                            ],
                            cellAlignment: pw.Alignment.center,
                          ),
                          // Añadir otro contenido aquí si es necesario
                          pw.SizedBox(height: 10), // Espacio entre la tabla y otro contenido
                        ],
                      ),
                    )
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child:pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Agregar la tabla vertical en la esquina superior derecha
                          pw.Table.fromTextArray(
                            context: context,
                            columnWidths: {
                              0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                              1: pw.FixedColumnWidth(70), // Ancho de la segunda columna
                            },
                            data: [
                              ['Pedido:', '${pedidoController.text}'],
                            ],
                            cellAlignment: pw.Alignment.center,
                          ),
                          // Añadir otro contenido aquí si es necesario
                          pw.SizedBox(height: 10), // Espacio entre la tabla y otro contenido
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
                            0: pw.FixedColumnWidth(30), // Ancho de la primera columna
                          },
                          data: [
                            ['  '],
                          ],
                          border: null,
                          cellAlignment: pw.Alignment.center,
                        ),
                        // Añadir otro contenido aquí si es necesario
                        pw.SizedBox(height: 10), // Espacio entre la tabla y otro contenido
                      ],
                    ),
                    pw.Expanded(
                      child:pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          // Agregar la tabla vertical en la esquina superior derecha
                          pw.Table.fromTextArray(
                            context: context,
                            columnWidths: {
                              0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                              1: pw.FixedColumnWidth(50), // Ancho de la segunda columna
                            },
                            data: [
                              ['Fecha:   ', '$currentDate'],
                            ],
                            cellAlignment: pw.Alignment.center,
                          ),
                          // Añadir otro contenido aquí si es necesario
                          pw.SizedBox(height: 10), // Espacio entre la tabla y otro contenido
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child:pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Agregar la tabla vertical en la esquina superior derecha
                          pw.Table.fromTextArray(
                            context: context,
                            columnWidths: {
                              0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                              1: pw.FixedColumnWidth(70), // Ancho de la segunda columna
                            },
                            data: [
                              ['Cantidad:', '$totalCantidad'],
                            ],
                            cellAlignment: pw.Alignment.topLeft, // Alinear el texto de la primera columna a la izquierda
                            cellAlignments: {
                              1: pw.Alignment.center, // Alinear el texto de la segunda columna al centro
                            },
                          ),
                          // Añadir otro contenido aquí si es necesario
                          pw.SizedBox(height: 10), // Espacio entre la tabla y otro contenido
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
                            0: pw.FixedColumnWidth(30), // Ancho de la primera columna
                          },
                          data: [
                            ['  '],
                          ],
                          border: null,
                          cellAlignment: pw.Alignment.center,
                        ),
                        // Añadir otro contenido aquí si es necesario
                        pw.SizedBox(height: 10), // Espacio entre la tabla y otro contenido
                      ],
                    ),
                    pw.Expanded(
                      child:pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          // Agregar la tabla vertical en la esquina superior derecha
                          pw.Table.fromTextArray(
                            context: context,
                            columnWidths: {
                              0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                              1: pw.FixedColumnWidth(50), // Ancho de la segunda columna
                            },
                            data: [
                              ['Fecha entrega:', '${entregaController.text}'],
                            ],
                            cellAlignment: pw.Alignment.center,
                          ),
                          // Añadir otro contenido aquí si es necesario
                          pw.SizedBox(height: 10), // Espacio entre la tabla y otro contenido
                        ],
                      ),
                    ),
                  ],
                ),
                // Contenido de la cotización
                pw.SizedBox(height: 20),

                // tabla con los datos de los productos
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FixedColumnWidth(40), // Ancho de la primera columna
                    1: pw.FixedColumnWidth(60), // Ancho de la segunda columna
                    2: pw.FixedColumnWidth(80), // Ancho de la tercera columna
                    3: pw.FractionColumnWidth(0.4), // Ancho de la cuarta columna (fracción del ancho disponible)
                  },
                  children: productosData.map((row) {
                    return pw.TableRow(
                      children: row.map((cell) {
                        final textStyle = productosData.indexOf(row) == 0 ? headerTextStyle : dataTextStyle;
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
                pw.SizedBox(height: 80), // Espacio de 8 cm
                pw.Container(
                  height: 1, // Altura de la línea
                  width: 240, // Ancho de la línea
                  color: PdfColors.black, // Color de la línea
                ),
                // Texto "PRODUCCIÓN"
                pw.Container(
                  margin: pw.EdgeInsets.only(top: 10, left: 70), // Margen superior
                  child: pw.Text(
                    'PRODUCCIÓN',
                    style: pw.TextStyle(fontSize: 12,
                      font: pw.Font.timesBold(),
                    ),
                  ),
                ),
                pw.Container(
                  margin: pw.EdgeInsets.only(top: 10, left: 45), // Margen superior
                  child: pw.Text(
                    'Alejandro Correa Ochoa',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ),


              ],
            );
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
    final otNumber = otController.text;
    final file = File('${directory!.path}/OT-$otNumber.pdf');
    await file.writeAsBytes(await pdf.save());
    print('PDF guardado en: ${file.path}');
    Get.snackbar('DOCUMENTO DESCARGADO EN:', '${file.path}', backgroundColor: Colors.green,
      colorText: Colors.white,);
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

  void cargarImagen() async {
    // Accede a la imagen desde los activos de tu aplicación
    ByteData imageData = await rootBundle.load('assets/img/LOGO1.png');
    // Convierte los datos de la imagen a un arreglo de bytes
    Uint8List bytes = imageData.buffer.asUint8List();
  }

    Future<void> generarPDFs() async {
      ByteData imageData = await rootBundle.load('assets/img/LOGO1.png');
      // Convierte los datos de la imagen a un arreglo de bytes
      Uint8List bytess = imageData.buffer.asUint8List();

      ByteData imageData2 = await rootBundle.load('assets/img/HOJAV.png');
      // Convierte los datos de la imagen a un arreglo de bytes
      Uint8List byteess = imageData2.buffer.asUint8List();

    List<Producto> productosEspera = cotizacion.producto!
        .where((producto) => producto.estatus == 'EN ESPERA')
        .toList();
    productosEspera.forEach((producto) async {
      if (producto.estatus == "EN ESPERA") {
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
                                  ['OT:', '${otController.text}'],
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
                                ['Fecha entrega:', '${entregaController.text}'],
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
        //final directory = await getExternalStorageDirectory();
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
    });
    }
}
