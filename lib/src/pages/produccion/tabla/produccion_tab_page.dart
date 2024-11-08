import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/pages/produccion/tabla/produccion_tab_controller.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/utils/grafic_circle.dart';
import 'package:maquinados_correa/src/widgets/ScrollableTableWrapper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProduccionTabPage extends StatelessWidget {
  ProduccionTabController con = Get.put(ProduccionTabController());

  @override
  Widget build(BuildContext context) {
    con.loadData();
    return Obx(() =>DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: _buildDrawer(),
          appBar:  _buildAppBar(),
          body: TabBarView(
              children: [
                ScrollableTableWrapper(child: _table(context)),
                _indicadores(context),
              ]
    )
    ))
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(95),
      child: AppBar(
        title: _encabezado(Get.context!),
        bottom: TabBar(
          tabs: [
            Tab(text: 'Monitor'),
            Tab(text: 'General'),
          ],
          labelStyle: TextStyle( // Estilo para la pestaña seleccionada
          fontSize: 18, // Tamaño del texto
          fontWeight: FontWeight.bold, // Opcional: hacer el texto en negritas
          ),
          unselectedLabelStyle: TextStyle( // Estilo para las pestañas no seleccionadas
          fontSize: 18,
            fontWeight: FontWeight.bold,// Tamaño del texto de las pestañas no seleccionadas
        ),
          indicator: BoxDecoration( // Cubre toda la zona clickeable del Tab
            color: Colors.black26, // Color del fondo del Tab seleccionado
          ),
          indicatorSize: TabBarIndicatorSize.tab, // indicador cubre todo el Tab
        ),
      ),
    );
  }
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white60,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDrawerHeader(),
              _buildDrawerItem('Perfil', () => con.goToPerfilPage()),
              _buildDrawerItem('Registro de nuevo usuario', () => con.goToRegisterPage()),
              _buildDrawerItem('Exportar a Excel', () => con.exportToExcel()),
              _buildDrawerFooter(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDrawerHeader() {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(top: 57),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: con.user.value.image != null
                ? NetworkImage(con.user.value.image!)
                : AssetImage('assets/img/LOGO1.png') as ImageProvider,
            radius: 70,
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: 10),
          Text(
            '${con.user.value.name ?? ''}  ${con.user.value.lastname}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDrawerFooter() {
    return Row(
      children: [
        _buildIconButton(Icons.supervised_user_circle, () => con.goToRoles()),
        Spacer(),
        _buildIconButton(Icons.power_settings_new, () => con.signOut()),
      ],
    );
  }
  Widget _buildDrawerItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 1),
        padding: EdgeInsets.all(20),
        width: double.infinity,
        color: Colors.white,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
  Widget _encabezado(BuildContext context) {
    return Container(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Image.asset(
            'assets/img/LOGO1.png',
            width: 55, //ancho de imagen
            height: 55, //alto de imagen
          ),
          ]
      ),
    );
  }

  Widget _table(BuildContext context) {
    return FutureBuilder<List<Cotizacion>>(
      future: con.getCotizacion('GENERADA'), // Cambiar a 'GENERADA'
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Cotizacion>? cotizaciones = snapshot.data;
          if (cotizaciones == null || cotizaciones.isEmpty) {
            return Center(child: Text('No hay cotizaciones generadas'));
          } else {
            // Crear una lista plana de todos los productos
            List<Map<String, dynamic>> productosOrdenados = [];

            // Recopilar todos los productos con su información de cotización
            for (var cotizacion in cotizaciones) {
              for (var producto in cotizacion.producto ?? []) {
                if (producto.estatus != 'CANCELADO') {
                  productosOrdenados.add({
                    'cotizacion': cotizacion,
                    'producto': producto,
                  });
                }
              }
            }

            // Ordenar la lista por número de OT
            productosOrdenados.sort((a, b) {
              String otA = a['producto'].ot ?? '';
              String otB = b['producto'].ot ?? '';

              // Convertir OT a números para comparación numérica si es posible
              try {
                int numA = int.parse(otA.replaceAll(RegExp(r'[^0-9]'), ''));
                int numB = int.parse(otB.replaceAll(RegExp(r'[^0-9]'), ''));
                return numA.compareTo(numB);
              } catch (e) {
                // Si no se puede convertir a número, usar comparación de strings
                return otA.compareTo(otB);
              }
            });
            return DataTable(
              columns: [
                DataColumn(label: Text('COTIZACIÓN', style: TextStyle(fontSize: 17),)),
                DataColumn(label: Text('O.T.', style: TextStyle(fontSize: 17),)),
                DataColumn(label: Text('PEDIDO', style: TextStyle(fontSize: 17),)),
                DataColumn(label: Text('CLIENTE', style: TextStyle(fontSize: 17),)),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('No. PARTE/', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.5),),
                      Text('PLANO', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.5)),
                    ],
                  ),
                ),
                DataColumn(label: Text('ARTICULO', style: TextStyle(fontSize: 17),)),
                DataColumn(label: Text('CANTIDAD', style: TextStyle(fontSize: 17),)),
                DataColumn(label: Text('ESTATUS', style: TextStyle(fontSize: 17),)),
                DataColumn(label: Text('OPERADOR', style: TextStyle(fontSize: 17),)),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('TIEMPO', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.5)),
                      Text('TOTAL', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.5)),
                    ],
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('FECHA', textAlign: TextAlign.center, style: TextStyle(fontSize: 17)),
                      Text('DE ENTREGA', textAlign: TextAlign.center, style: TextStyle(fontSize: 17)),
                    ],
                  ),
                ),
                DataColumn(label: Text('ENTREGADO', style: TextStyle(fontSize: 17),)),
              ],
              rows: productosOrdenados.map((item) {
                var cotizacion = item['cotizacion'];
                var producto = item['producto'];
                Color? rowColor = _getRowColor(producto.fecha, producto.estatus);

                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      return rowColor ?? Colors.transparent;
                    },
                  ),
                    cells: [
                      DataCell(Text(cotizacion.number ?? '',
                        style: TextStyle(fontSize: 15),)),
                      DataCell(Text(producto.ot ?? '',
                        style: TextStyle(fontSize: 15),)),
                      DataCell(Text(producto.pedido ?? '',
                        style: TextStyle(fontSize: 14),)),
                      DataCell(Text(cotizacion.clientes!.name.toString(),
                        style: TextStyle(fontSize: 15),)),
                      DataCell(Text(producto.parte ?? '',
                        style: TextStyle(fontSize: 14),)),
                      DataCell(GestureDetector(
                          onTap: () => con.goToEntrega(producto),
                        child: Text(producto.articulo ?? '',
                          style: TextStyle(fontSize: 14),),
                      )),
                      DataCell(Text(producto.cantidad.toString(),
                        style: TextStyle(fontSize: 15),)),
                      DataCell(
                        Container(
                          color: _getColorForStatus(producto.estatus),
                          child: Text(producto.estatus ?? '',
                            style: TextStyle(fontSize: 15),),
                        ),
                      ),
                      DataCell(Text(producto.operador ?? '',
                        style: TextStyle(fontSize: 15),)),
                      DataCell(
                        FutureBuilder<Map<String, String>>(
                          future: con.calcularTiempoTotal(producto.id!, producto.parte ?? ''),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error', style: TextStyle(fontSize: 16));
                            } else {
                              String tiempoTotal = snapshot.data?['total'] ?? '';
                              String tiempoEstimado = snapshot.data?['estimado'] ?? '';
                              Color textColor = Colors.black;
                              String displayText = tiempoTotal;

                              if (tiempoTotal != 'N/A' && tiempoEstimado.isNotEmpty) {
                                List<String> totalParts = tiempoTotal.split(':');
                                List<String> estimadoParts = tiempoEstimado.split(':');
                                int totalMinutos = int.parse(totalParts[0]) * 60 + int.parse(totalParts[1]);
                                int estimadoMinutos = int.parse(estimadoParts[0]) * 60 + int.parse(estimadoParts[1]);

                                if (totalMinutos > estimadoMinutos) {
                                  textColor = Colors.red;
                                }

                                displayText = ' $tiempoEstimado/$tiempoTotal';
                              }

                              return Text(
                                  displayText,
                                  style: TextStyle(fontSize: 16, color: textColor,fontWeight: FontWeight.bold)
                              );
                            }
                          },
                        ),
                      ),
                      DataCell(Text(producto.fecha ?? '',
                        style: TextStyle(fontSize: 15),)),
                      DataCell(Text(producto.entrega ?? '',
                        style: TextStyle(fontSize: 15),)),
                    ],
                );
              }).toList(),
            );
          }
        }
      },
    );
  }
  // Función para obtener el color según el estatus
  Color? _getColorForStatus(String? estatus) {
    switch (estatus) {
      case 'RETRABAJO':
        return Colors.yellow;
      case 'RECHAZADO':
        return Colors.red;
      case 'LIBERADO':
        return Colors.blue;
      case 'ENTREGADO':
        return Colors.green[200];
      default:
        return Colors.transparent; // Color por defecto
    }
  }
// Nueva función para determinar el color de la fila
  Color? _getRowColor(String? fechaEntrega, String? estatus) {
    if (estatus == 'ENTREGADO') {
      return Colors.green[200]; // Verde claro para productos entregados
    }

    if (fechaEntrega == null) return null;

    try {
      DateTime fechaEntregaDate = DateTime.parse(fechaEntrega);
      DateTime ahora = DateTime.now();
      int diferenciaDias = fechaEntregaDate.difference(ahora).inDays;

      if (diferenciaDias <= 0) {
        return Colors.red.withOpacity(0.5); // Rojo claro para fechas vencidas
      } else if (diferenciaDias <= 5) {
        return Colors.orange.withOpacity(0.5); // Naranja claro para 5 días o menos
      } else if (diferenciaDias <= 10) {
        return Colors.yellow.withOpacity(0.5); // Amarillo claro para 10 días o menos
      }
    } catch (e) {
      print('Error al parsear la fecha: $e');
      return null;
    }

    return null; // Sin color para el resto de los casos
  }
  Widget _indicadores(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 120,
                            margin: EdgeInsets.only(left: 5, right: 5),
                            child: Material(
                              elevation: 20,
                              borderRadius: BorderRadius.circular(25),
                              shadowColor: Colors.black,
                              color: Colors.amber,
                              child: Obx(() => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildText('TOTAL O.T.', context),
                                    Text(
                                      '${con.totalOTs.value}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 53,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 120,
                            margin: EdgeInsets.only(left: 5, right: 5),
                            child: Material(
                              elevation: 20,
                              borderRadius: BorderRadius.circular(25),
                              shadowColor: Colors.black,
                              color: Colors.green,
                              child: Obx(() => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildText(
                                      'O.T. CERRADAS', context),
                                    Text(
                                      '${con.otCerradas.value}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 53,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ),
                          ),
                        ),
              Expanded(
                child: Container(
                  height: 120,
                  margin: EdgeInsets.only(left: 5, right: 5),
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(25),
                    shadowColor: Colors.black,
                    color: Colors.orange,
                    child: Obx(() => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildText(
                            'PIEZAS FABRICADAS', context),
                          Text(
                            '${con.productsFab.value}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 53,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 120,
                  margin: EdgeInsets.only(left: 5, right: 5),
                  child: Material(
                    elevation: 20,
                    borderRadius: BorderRadius.circular(25),
                    shadowColor: Colors.black,
                    color: Colors.red,
                    child: Obx(() => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildText(
                            'RECHAZOS/RETRABAJOS', context
                          ),
                          Text(
                            '${con.productsrr.value}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 53,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                ),
              ),
                      ],
                    ),
                    // Asegura que los gráficos tienen restricciones de tamaño.
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () => con.obtenerDatosPorMes(),
                          child: Text('Mes'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => con.obtenerDatosPorA(),
                          child: Text('Año'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _grafic(context)),
                        Expanded(child: _grafic2(context)),
                        Expanded(child: _grafic4(context)),
                      ],
                    ),
                    _grafic3(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
Widget _grafic (BuildContext context){
  double screenWidth = MediaQuery.of(context).size.width;
    return Obx(() => SizedBox( // Envolver con SizedBox o Container con restricciones
      height: 335, // Fija un tamaño máximo adecuado para el gráfico
      child: SfCircularChart(
        margin: EdgeInsets.only(left:1),
        title: ChartTitle(text: 'EFICACÍA', textStyle: TextStyle(fontSize: screenWidth * 0.011, fontWeight: FontWeight.bold)),
        legend: Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.left,
          textStyle: TextStyle(
            fontSize: screenWidth * 0.01, // Ajusta el tamaño del texto de la leyenda
          ),
          ),
        series: <CircularSeries>[
          DoughnutSeries<GDPData, String>(
            dataSource: con.chartData.value,
            xValueMapper: (GDPData data, _) => data.continent,
            yValueMapper: (GDPData data, _) => data.gdp,
            pointColorMapper: (GDPData data, _) => data.color ?? Colors.grey,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              //labelPosition: ChartDataLabelPosition.outside, // Colocar etiquetas afuera
            ),
            dataLabelMapper: (GDPData data, _) {
              return '${data.gdp.toStringAsFixed(1)}%'; // Muestra el porcentaje con un decimal y el símbolo '%'
            },
          ),
        ],
      ),
    ));
}

  Widget _grafic2 (BuildContext context){
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(() => SizedBox( // Envolver con SizedBox o Container con restricciones
      height: 335, // Fija un tamaño máximo adecuado para el gráfico
      child: SfCircularChart(
        margin: EdgeInsets.only(left: 1),
        title: ChartTitle(text: 'EFECTIVIDAD DE ENTREGAS', textStyle: TextStyle(fontSize: screenWidth * 0.011, fontWeight: FontWeight.bold)),
        legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap, position: LegendPosition.left,
          textStyle: TextStyle(
            fontSize: screenWidth * 0.01, // Ajusta el tamaño del texto de la leyenda
          ),
        ),
        series: <CircularSeries>[
          DoughnutSeries<GDPData, String>(
            dataSource: con.chartData2.value, // Asegúrate de que chartData2 se esté usando
            xValueMapper: (GDPData data, _) => data.continent,
            yValueMapper: (GDPData data, _) => data.gdp,
            pointColorMapper: (GDPData data, _) => data.color ?? Colors.grey, // Muestra los colores correctos
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              //labelPosition: ChartDataLabelPosition.outside, // Colocar etiquetas afuera
            ),
            dataLabelMapper: (GDPData data, _) {
              return '${data.gdp.toStringAsFixed(0)}'; // Mostrar valores absolutos
            },
          ),
        ],
      ),
    ));
  }
  Widget _grafic3(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(() => SizedBox( // Envolver con SizedBox o Container con restricciones
      height: 300, // Fija un tamaño máximo adecuado para el gráfico
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        title: ChartTitle(text: 'Piezas Completadas, Rechazadas y con Retrabajo', textStyle: TextStyle(fontSize: screenWidth * 0.011, fontWeight: FontWeight.bold)),
        legend: Legend(isVisible: true,
          textStyle: TextStyle(
            fontSize: screenWidth * 0.01, // Ajusta el tamaño del texto de la leyenda
          ),),
        tooltipBehavior: TooltipBehavior(enable: true),

        series: <ChartSeries>[
          // Serie de barras para Piezas Completadas
          ColumnSeries<SalesData, String>(
            dataSource: con.chartData3.value, // Usamos chartData3 para las barras
            xValueMapper: (SalesData data, _) => data.month, // El mes en el eje X
            yValueMapper: (SalesData data, _) => data.completed, // Piezas completadas en el eje Y
            name: 'Piezas Completadas',
            color: Colors.blueGrey, // Color para las barras
          ),

          // Serie de línea para Piezas con Rechazo
          LineSeries<SalesData, String>(
            dataSource: con.chartData3.value, // Usamos los mismos datos para la línea
            xValueMapper: (SalesData data, _) => data.month, // El mes en el eje X
            yValueMapper: (SalesData data, _) => data.rejected, // Piezas rechazadas en el eje Y
            name: 'Piezas con Rechazo',
            color: Colors.red, // Color para la línea
            width: 3,
            markerSettings: MarkerSettings(isVisible: true), // Mostrar puntos en la línea
          ),

          // Serie de línea para Piezas con Retrabajo
          LineSeries<SalesData, String>(
            dataSource: con.chartData3.value, // Usamos los mismos datos para la línea
            xValueMapper: (SalesData data, _) => data.month, // El mes en el eje X
            yValueMapper: (SalesData data, _) => data.rework, // Piezas con retrabajo en el eje Y
            name: 'Piezas con Retrabajo',
            color: Colors.orange, // Color para la línea
            width: 3,
            markerSettings: MarkerSettings(isVisible: true), // Mostrar puntos en la línea
          ),
        ],
      ),
    ));
  }
  Widget _buildText(String text, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Text(
      text,
      style: TextStyle(
        fontSize: screenWidth * 0.0162, // Ajusta el tamaño de la letra según el ancho de la pantalla
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _grafic4 (BuildContext context){
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(() => SizedBox( // Envolver con SizedBox o Container con restricciones
      height: 335, // Fija un tamaño máximo adecuado para el gráfico
      child: SfCircularChart(
        margin: EdgeInsets.only(left:1),
        title: ChartTitle(text: 'EFICIENCIA', textStyle: TextStyle(fontSize: screenWidth * 0.011, fontWeight: FontWeight.bold)),
        legend: Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap,
          position: LegendPosition.left,
          textStyle: TextStyle(
            fontSize: screenWidth * 0.01, // Ajusta el tamaño del texto de la leyenda
          ),
        ),
        series: <CircularSeries>[
          DoughnutSeries<GDPData, String>(
            dataSource: con.chartData4.value,
            xValueMapper: (GDPData data, _) => data.continent,
            yValueMapper: (GDPData data, _) => data.gdp,
            pointColorMapper: (GDPData data, _) => data.color ?? Colors.grey,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              //labelPosition: ChartDataLabelPosition.outside, // Colocar etiquetas afuera
            ),
            dataLabelMapper: (GDPData data, _) {
              return '${data.gdp.toStringAsFixed(0)}'; // Mostrar valores absolutos
            },
          ),
        ],
      ),
    ));
  }
}

