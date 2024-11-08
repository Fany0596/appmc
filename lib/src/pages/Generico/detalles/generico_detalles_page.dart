import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/pages/Generico/detalles/generico_detalles_controller.dart';
import 'package:maquinados_correa/src/pages/tym/tabla/tym_tab_controller.dart';
import 'package:maquinados_correa/src/widgets/no_data_widget.dart';
import 'package:intl/intl.dart';
import 'package:maquinados_correa/src/pages/produccion/orders/detalles_produccion/detalles_produccion_controller.dart';
import 'package:maquinados_correa/src/pages/ventas/orders/detalles/detalles_controller.dart';

class GenericoDetallesPage extends StatelessWidget {
  final ProduccionDetallesController produccionDetallesController = Get.put(ProduccionDetallesController());
  final VentasDetallesController ventasDetallesController = Get.put(VentasDetallesController());
  final TymTabController tymTabController = Get.put(TymTabController());

  GenericoDetallesController con = Get.put(GenericoDetallesController());
  String formatCurrency(double amount) {
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return currencyFormat.format(amount);
  }
  @override
    Widget build(BuildContext context) {
      return Obx(() => DefaultTabController(
        length: con.estatus.length,
        child:  Scaffold(
          bottomNavigationBar: Container(
            color: Color.fromRGBO(176, 160 , 117, 1),
            height: 110,
            child: Column(
              children: [
                    _totalToPay(context)
              ],
            ),
          ),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(130),//ancho del appbar
              child: AppBar(
                title: _encabezado(context),
                flexibleSpace: Container(
                  margin: EdgeInsets.only(top: 30, bottom: 10),
                  alignment: Alignment.center,
                  child: Wrap(
                    direction: Axis.horizontal,
                    children: [
                      //_textFieldSearch(context)
                      _textCot(context)
                    ],
                  ),
                ),
                bottom: TabBar(
                    isScrollable: true,
                    indicatorColor: Colors.grey,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    tabs: List<Widget>.generate(con.estatus.length, (index) {
                      return Tab(
                        child: Text(con.estatus[index]),
                      );
                    }),
                  onTap: (index) {
                    con.cargarProductosPorEstatus(con.estatus[index]); // Cargar productos al cambiar de pestaña
                  }, ),
              ),
            ),

            body: TabBarView(
              children: con.estatus.map((String estado) {
                // Filtrar los productos por estado
                List<Producto> productosPorEstado = con.cotizacion.producto!
                    .where((Producto producto) => producto.estatus == estado)
                    .toList();

                return productosPorEstado.isNotEmpty
                      ? ListView(
                    children: productosPorEstado
                        .map((Producto producto) {
                      return _cardProducto(producto);
                    })
                        .toList(),
                  )
                      : Center(
                    child: NoDataWidget(
                      text: 'No hay ningún producto en estado $estado',
                    ),
                );
              }).toList(),
            )
//////

        ),
      )
    );
    }
  Widget _encabezado(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 1,left: 1),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //alignment: Alignment.topLeft,
          children: [Image.asset(
            'assets/img/LOGO1.png',
            width: 55, //ancho de imagen
            height: 55, //alto de imagen
          ),
          ]
      ),
    );
  }
  Widget _textCot (BuildContext context){
     return SafeArea(
      child: Container(
         width: MediaQuery.of(context).size.width * 0.95,
        child: TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Cotización #${con.cotizacion.number}',
              hintStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.white
              ),
           enabled: false,
          )
          ),
          )
        );
      }
  Widget _cardProducto(Producto producto) {
    return Container(
        height: 190,
        margin: EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child:Stack(
            children: [
              Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    )
                ),
                child: Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text(
                    'Producto: ${producto.articulo}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text('Material: ${producto.name ?? ''}'),

                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text('Cantidad: ${producto.cantidad ?? ''}'),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text('Precio: ${formatCurrency(producto.precio ?? 0.0)}'),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text('Total: ${formatCurrency(producto.total ?? 0.0)}'),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: ElevatedButton(
                              onPressed: () => con.generarPDFs(producto),
                              child: Text('Hoja de Insp.'),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: ElevatedButton(
                              onPressed: () => con.descargarPDF(producto.pdfFile ?? ''),
                              child: Text('Reporte Dim.'),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: ElevatedButton(
                              onPressed: () => con.descargarPDF(producto.planopdf ?? ''),
                              child: Text('Plano'),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: ElevatedButton(
                              onPressed: () {
                              tymTabController.generarPDF(producto);
                              },
                              child: Text('Reporte Tiemp.'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        ),

    );
  }
Widget _totalToPay(BuildContext context){
  //bool garantiasAgregadas = false; // Estado para controlar si se han agregado garantías

  return Column(
      children: [
        Divider(height: 1, color: Colors.white),
        Column(
          children: [
            if (con.cotizacion.status == 'ABIERTA') Container(
              margin: EdgeInsets.only(left: 20, top:5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 45, top: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        ventasDetallesController.generarCot();
                      },
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(15),
                          backgroundColor: Colors.black
                      ),
                      child: Text(
                        'COTIZACIÓN',
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ) else
            con.cotizacion.status == 'CANCELADA'
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only( top: 20),
                      child: ElevatedButton(
                        onPressed: () {
                        ventasDetallesController.generarCot();
                      },
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(15),
                            backgroundColor: Colors.black
                        ),
                        child: Text(
                          'COTIZACIÓN',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ],)
          ],
        )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                      onPressed: () {
                        ventasDetallesController.generarCot();
                      },
                      style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(15),
                      backgroundColor: Colors.black
                      ),
                      child: Text(
                      'COTIZACIÓN',
                      style: TextStyle(
                      color: Colors.white
                      ),
                      ),
                      ),
                      ),
                    Container(
                      margin: EdgeInsets.only(left: 45, top: 20),
                      child: ElevatedButton(
                        onPressed: () => con.generarOc(),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(15),
                            backgroundColor: Colors.black
                        ),
                        child: Text(
                          'OC',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 45, top: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          produccionDetallesController.generarPDF();
                        },
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(15),
                            backgroundColor: Colors.black
                        ),
                        child: Text(
                          'OT',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ],
    )
      ]);
}
}
