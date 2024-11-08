import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/pages/ventas/tabla/ventas_tab_controller.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/utils/grafic_circle.dart';
import 'package:maquinados_correa/src/widgets/ScrollableTableWrapper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class VentasTabPage extends StatelessWidget {
  VentasTabController con = Get.put(VentasTabController());
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    con.loadData();
    return Obx(() => DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: _buildDrawer(),
        appBar: _buildAppBar(),
        body: TabBarView(
          children: [
          ScrollableTableWrapper(child: _table(context)),
          _indicadores(context),
      ]
      )
      ),
    ));
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
              _buildDrawerItem('Registro de nuevo vendedor', () => con.goToNewVendedorPage()),
              _buildDrawerItem('Registro de nuevo cliente', () => con.goToNewClientePage()),
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
      margin: EdgeInsets.only(top: 1, left: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/img/LOGO1.png',
            width: 55,
            height: 55,
          ),
        ],
      ),
    );
  }

  Widget _table(BuildContext context) {
    return FutureBuilder<List<Cotizacion>>(
      future: con.getCotizacion('GENERADA'),
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
            return DataTable(
              columns: [
                DataColumn(label: Text('COTIZACIÓN', style: TextStyle(fontSize: 14))),
                DataColumn(label: Text('VENDEDOR', style: TextStyle(fontSize: 14))),
                DataColumn(label: Text('PEDIDO', style: TextStyle(fontSize: 14))),
                DataColumn(label: Text('CLIENTE', style: TextStyle(fontSize: 14))),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('No. PARTE/', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5)),
                      Text('PLANO', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5)),
                    ],
                  ),
                ),
                DataColumn(label: Text('ARTICULO', style: TextStyle(fontSize: 14))),
                DataColumn(label: Text('CANTIDAD', style: TextStyle(fontSize: 14))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 14))),
                DataColumn(label: Text('MATERIAL', style: TextStyle(fontSize: 14))),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('PRECIO', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5)),
                      Text('MATERIAL', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5)),
                    ],
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('COSTO', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5)),
                      Text('M.O.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5)),
                    ],
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('PRECIO', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5)),
                      Text('VENTA', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5)),
                    ],
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('FECHA', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                      Text('DE ENTREGA', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
              rows: cotizaciones.expand((cotizacion) {
                return cotizacion.producto!.map((producto) {
                  Color? rowColor = _getRowColor(producto.fecha, producto.estatus);

                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return rowColor ?? Colors.transparent;
                      },
                    ),
                      cells: [
                  DataCell(Text(cotizacion.number ?? '', style: TextStyle(fontSize: 13))),
                  DataCell(Text(cotizacion.vendedores!.name.toString(), style: TextStyle(fontSize: 13))),
                  DataCell(Text(producto.pedido ?? '', style: TextStyle(fontSize: 12))),
                  DataCell(Text(cotizacion.clientes!.name.toString(), style: TextStyle(fontSize: 13))),
                  DataCell(Text(producto.parte ?? '', style: TextStyle(fontSize: 12))),
                  DataCell(Text(producto.articulo ?? '', style: TextStyle(fontSize: 12))),
                  DataCell(Text(producto.cantidad.toString(), style: TextStyle(fontSize: 13))),
                  DataCell(
                  Container(
                          color: _getColorForStatus(producto.estatus),
                          child: Text(producto.estatus ?? '', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                      DataCell(Text(producto.name ?? '', style: TextStyle(fontSize: 13))),
                      DataCell(GestureDetector(
                          onTap: () => con.goToPrice(producto),child: Text('\$${producto.pmaterial ?? '----'}',
                          style: TextStyle(fontSize: 13)))),
                        DataCell(
                          FutureBuilder<Map<String, String>>(
                            future: con.calcularTiempoTotal(producto.id!, producto.parte ?? ''),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error', style: TextStyle(fontSize: 16));
                              } else {
                                String costoTotal = snapshot.data?['costo'] ?? '';
                                return Text(costoTotal, style: TextStyle(fontSize: 16));
                              }
                            },
                          ),
                        ),
                      DataCell(Text('\$${producto.total!.toStringAsFixed(2)}', style: TextStyle(fontSize: 13))),
                      DataCell(Text(producto.fecha ?? '', style: TextStyle(fontSize: 13))),
                    ],
                  );
                }).toList();
              }).toList(),
            );
          }
        }
      },
    );
  }
  // Función para obtener el color según el estatus
  Color _getColorForStatus(String? estatus) {
    switch (estatus) {
      case 'RETRABAJO':
        return Colors.yellow;
      case 'RECHAZADO':
        return Colors.red;
      case 'LIBERADO':
        return Colors.blue;
      default:
        return Colors.transparent; // Color por defecto
    }
  }
  Color? _getRowColor(String? fechaEntrega, String? estatus) {
    if (estatus == 'ENTREGADO') {
      return Colors.green[200]; // Verde claro para productos entregados
    }
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
                              color: Colors.blue,
                              child: Obx(() => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildText('TOTAL COTIZACIONES', context),
                                    Text(
                                      '${con.totalCots.value}',
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
                              color: Colors.lime,
                              child: Obx(() => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildText(
                                        'COTIZACIONES CERRADAS', context),
                                    Text(
                                      '${con.cotCerradas.value}',
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
                              color: Colors.amber,
                              child: Obx(() => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildText(
                                        'COTIZACIONES ABIERTAS', context),
                                    Text(
                                      '${con.cotOpen.value}',
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
                                        'TOTAL INGRESOS', context
                                    ),
                                    _buildText2(
                                      '${NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2).format(con.cotIng.value)}',
                                      context
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
                      children: [
                        Expanded(flex: 1, child: _grafic(context)),
                        Expanded(flex: 2, child: _grafic2(context)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(flex: 2, child: _grafic4(context)),
                        Expanded(flex: 1, child: _grafic3(context)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _grafic(BuildContext context){
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(() {
      if (con.chartData.value.isEmpty) {
        // Si los datos son nulos o están vacíos, muestra un indicador de carga o un mensaje
        return Center(child: Text('No hay datos disponibles'));
      }
      return SizedBox(
        height: 335,
        child: SfCircularChart(
          margin: EdgeInsets.only(left: 1),
          title: ChartTitle(
            text: 'Ingresos por Vendedor',
            textStyle: TextStyle(fontSize: screenWidth * 0.011, fontWeight: FontWeight.bold),
          ),
          legend: Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.left,
            textStyle: TextStyle(
              fontSize: screenWidth * 0.01,
            ),
          ),
          series: <CircularSeries>[
            DoughnutSeries<GDPData, String>(
              dataSource: con.chartData.value,
              xValueMapper: (GDPData data, _) => data.continent ?? 'Desconocido', // Comprobar nulos
              yValueMapper: (GDPData data, _) => data.gdp ?? 0, // Comprobar nulos
              pointColorMapper: (GDPData data, _) => data.color ?? Colors.grey,
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
              ),
              dataLabelMapper: (GDPData data, _) {
                return NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2)
                    .format(data.gdp ?? 0); // Comprobar nulos
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _grafic2(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final NumberFormat currencyFormat = NumberFormat.currency(
        locale: 'es_MX',
        symbol: '\$',
        decimalDigits: 2
    );
    return Obx(() => SizedBox( // Envolver con SizedBox o Container con restricciones
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        title: ChartTitle(text: 'Ingresos por Cliente',textStyle: TextStyle(fontSize: screenWidth * 0.011, fontWeight: FontWeight.bold)),
        legend: Legend(isVisible: false,
          textStyle: TextStyle(
            fontSize: screenWidth * 0.01, // Ajusta el tamaño del texto de la leyenda
          ),),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ChartSeries>[
          ColumnSeries<GDPData, String>(
            dataSource: con.chartDataClientes.value,  // Datos de ingresos por cliente
            xValueMapper: (GDPData data, _) => data.continent,  // Nombre del cliente
            yValueMapper: (GDPData data, _) => data.gdp,  // Ingresos
            pointColorMapper: (GDPData data, index) =>
            index! % 2 == 0 ? Colors.amber : Colors.orange,
            dataLabelSettings: DataLabelSettings(isVisible: true,
                builder: (dynamic data, dynamic point, dynamic series,
                    int pointIndex, int seriesIndex) {
                  return Text(
                    currencyFormat.format(point.y),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.01,
                    ),
                  );
                },
            ),  // Muestra las etiquetas de datos en las barras
          )
        ],
      ),
    ));
  }

  Widget _grafic3(BuildContext context){
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(() {
      if (con.chartData2.value.isEmpty) {
        // Si los datos son nulos o están vacíos, muestra un indicador de carga o un mensaje
        return Center(child: Text('No hay datos disponibles'));
      }
      return SizedBox(
        height: 335,
        child: SfCircularChart(
          margin: EdgeInsets.only(left: 1),
          title: ChartTitle(
            text: 'Tasa de éxito',
            textStyle: TextStyle(fontSize: screenWidth * 0.011, fontWeight: FontWeight.bold),
          ),
          legend: Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.left,
            textStyle: TextStyle(
              fontSize: screenWidth * 0.01,
            ),
          ),
          series: <CircularSeries>[
            DoughnutSeries<GDPData, String>(
              dataSource: con.chartData2.value,
              xValueMapper: (GDPData data, _) => data.continent ?? 'Desconocido', // Comprobar nulos
              yValueMapper: (GDPData data, _) => data.gdp ?? 0, // Comprobar nulos
              pointColorMapper: (GDPData data, _) => data.color ?? Colors.grey,
              dataLabelSettings: DataLabelSettings(
                isVisible: true),
              dataLabelMapper: (GDPData data, _) {
                return '${data.gdp.toStringAsFixed(1)}%'; // Mostrar el porcentaje con el símbolo '%'
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _grafic4(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(() => SizedBox( // Envolver con SizedBox o Container con restricciones
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        title: ChartTitle(text: 'Cotizaciones por Cliente', textStyle: TextStyle(fontSize: screenWidth * 0.011, fontWeight: FontWeight.bold)),
        legend: Legend(isVisible: true, position: LegendPosition.left,
          textStyle: TextStyle(
            fontSize: screenWidth * 0.01, // Ajusta el tamaño del texto de la leyenda
          ),),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ChartSeries>[
          ColumnSeries<CotData, String>(
            dataSource: con.chartDataClientes2.value,  // Datos de ingresos por cliente
            xValueMapper: (CotData data, _) => data.cliente,  // Nombre del cliente
            yValueMapper: (CotData data, _) => data.solicitada,  // Ingresos
            name: 'Cotizaciones\nsolicitadas',
            pointColorMapper: (CotData data, index) =>
            index! % 2 == 0 ? Colors.amber : Colors.orange,
            dataLabelSettings: DataLabelSettings(isVisible: true,
            ),  // Muestra las etiquetas de datos en las barras
          ),
          // Serie de línea para Piezas con Rechazo
          LineSeries<CotData, String>(
            dataSource: con.chartDataClientes2.value, // Usamos los mismos datos para la línea
            xValueMapper: (CotData data, _) => data.cliente, // El mes en el eje X
            yValueMapper: (CotData data, _) => data.aceptada, // Piezas rechazadas en el eje Y
            name: 'Cotizaciones\naceptadas',
            color: Colors.green, // Color para la línea
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
  Widget _buildText2(String text, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Text(
      text,
      style: TextStyle(
        fontSize: screenWidth * 0.0270, // Ajusta el tamaño de la letra según el ancho de la pantalla
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
      textAlign: TextAlign.center,
    );
  }
}
