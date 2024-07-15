import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/pages/ventas/orders/detalles/detalles_controller.dart';
import 'package:maquinados_correa/src/widgets/no_data_widget.dart';
import 'package:intl/intl.dart';

class VentasDetallesPage extends StatelessWidget {
  VentasDetallesController con = Get.put(VentasDetallesController());
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
            height: 150,
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

             ///////////////////////
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
            Text(
              '  MAQUINADOS CORREA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ]
      ),
    );
  }
  Widget _textCot (BuildContext context){
     return SafeArea(
      child: Container(
         width: MediaQuery.of(context).size.width * 0.95,
    //margin: EdgeInsets.only(left: 100),
    child: TextField(
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'Cotización #${con.cotizacion.number}',
          hintStyle: TextStyle(
              fontSize: 20,
              color: Colors.white
          ),

      )
      ),
      )
    );
  }
  Widget _cardProducto(Producto producto) {
    print('material del producto: ${producto.name}');
    return Container(
        height: 160,
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
            Container(
              margin: EdgeInsets.only(left: 10, top: 10),
              child: Text(
                'TOTAL: ${formatCurrency(con.totalt.value)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 19
                ),
              ),
            ),
            if (con.cotizacion.status == 'ABIERTA') Container(
              margin: EdgeInsets.only(left: 20, top:5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: ElevatedButton(
                          onPressed: () => con.updateCancelada(),
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(15),
                              backgroundColor: Colors.red
                          ),
                          child: Text(
                            'CANCELAR',
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                      Container(
                        margin: EdgeInsets.only(left: 45),
                        child: ElevatedButton(
                          onPressed: () => con.updateCotizacion(),
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(15),
                            backgroundColor: Colors.green
                          ),
                          child: Text(
                            'CONFIRMAR',
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                  Container(
                    margin: EdgeInsets.only(left: 45),
                    child: ElevatedButton(
                      onPressed: () => con.generarCot(),
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(15),
                          backgroundColor: Colors.black
                      ),
                      child: Text(
                        'PFD',
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      // Botón de verificación para agregar garantías
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                             Checkbox(
                                  value: con.garantiasAgregadas.value,
                                  onChanged: (value) {
                                    // Cambia el estado llamando al método en el controlador
                                    con.toggleGarantiasAgregadas();
                                  },
                                ),
                            Text(
                              'Agregar Garantías',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón de verificación para agregar bancarios
                      Container(
                        margin: EdgeInsets.only(left: 45),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: con.bancariosAgregadas.value,
                              onChanged: (value) {
                                // Cambia el estado llamando al método en el controlador
                                con.toggleBancariosAgregadas();
                              },
                            ),
                            Text(
                              'Agregar Datos Bancarios',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                Column(
                children: [
                // Botón de verificación para agregar garantías
                Container(
                child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                Checkbox(
                value: con.reportedimAgregadas.value,
                onChanged: (value) {
                // Cambia el estado llamando al método en el controlador
                con.toggleReportedimAgregadas();
                },
                ),
                Text(
                'Reporte dimensional',
                style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                ),
                ),
                ],
                ),
                ),
                Column(
                children: [
                // Botón de verificación para agregar garantías
                Container(
                child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                Checkbox(
                value: con.garantiasAgregadas.value,
                onChanged: (value) {
                // Cambia el estado llamando al método en el controlador
                con.toggleGarantiasAgregadas();
                },
                ),
                Text(
                'Agregar Garantías',
                style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                ),
                ),
                ],
                ),
                ),
                ]
                )
                ]
                )

                ],
              )
            ) else
            con.cotizacion.status == 'GENERADA'
                ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Text(
                                'VALORES AGREGADOS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Checkbox(
                                value: con.reportetratAgregadas.value,
                                onChanged: (value) {
                                  // Cambia el estado llamando al método en el controlador
                                  con.toggleReportetratAgregadas();
                                },
                              ),
                              Text(
                                'Certificado tratamiento',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 5),
                          child: Row(
                            children: [
                              Checkbox(
                                value: con.reportematAgregadas.value,
                                onChanged: (value) {
                                  // Cambia el estado llamando al método en el controlador
                                  con.toggleReportematAgregadas();
                                },
                              ),
                              Text(
                                'Certificado de material',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Checkbox(
                                value: con.reportedimAgregadas.value,
                                onChanged: (value) {
                                  // Cambia el estado llamando al método en el controlador
                                  con.toggleReportedimAgregadas();
                                },
                              ),
                              Text(
                                'Reporte dimensional',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 7),
                          child: Row(
                            children: [
                              Checkbox(
                                value: con.reporterugAgregadas.value,
                                onChanged: (value) {
                                  // Cambia el estado llamando al método en el controlador
                                  con.toggleReporterugAgregadas();
                                },
                              ),
                              Text(
                                'Reporte de rugosidad',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 95),
                      child: ElevatedButton(
                        onPressed: () => con.updateCerrada(),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(15),
                            backgroundColor: Colors.green
                        ),
                        child: Text(
                          'CERRAR',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 45, right: 95),
                    child: ElevatedButton(
                    onPressed: () => con.generarCot(),
                    style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15),
                    backgroundColor: Colors.black
                    ),
                    child: Text(
                    'PFD',
                    style: TextStyle(
                    color: Colors.white
                    ),
                    ),
                    ),
                    ),

                  Column(
                  children: [
                  // Botón de verificación para agregar garantías
                  Container(
                    margin: EdgeInsets.only(left: 45, right: 160),
                  child: Row(
                  children: [
                  Checkbox(
                  value: con.garantiasAgregadas.value,
                  onChanged: (value) {
                  // Cambia el estado llamando al método en el controlador
                  con.toggleGarantiasAgregadas();
                  },
                  ),
                  Text(
                  'Agregar Garantías',
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  ),
                  ),
                  ],
                  ),
                  ),

                  // Botón de verificación para agregar bancarios
                  Container(
                  margin: EdgeInsets.only(left: 45, right: 112),
                  child: Row(
                  children: [
                  Checkbox(
                  value: con.bancariosAgregadas.value,
                  onChanged: (value) {
                  // Cambia el estado llamando al método en el controlador
                  con.toggleBancariosAgregadas();
                  },
                  ),
                  Text(
                  'Agregar Datos Bancarios',
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  ),
                  ),
                  ],
                  ),
                  ),

                  ],
                ),
                  ],)
          ],
        )
                : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: ElevatedButton(
                        onPressed: () => con.generarCot(),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(15),
                            backgroundColor: Colors.black
                        ),
                        child: Text(
                          'PFD',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),

                    Column(
                      children: [
                        // Botón de verificación para agregar garantías
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: con.garantiasAgregadas.value,
                                onChanged: (value) {
                                  // Cambia el estado llamando al método en el controlador
                                  con.toggleGarantiasAgregadas();
                                },
                              ),
                              Text(
                                'Agregar Garantías',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botón de verificación para agregar bancarios
                        Container(
                          margin: EdgeInsets.only(left: 45),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: con.bancariosAgregadas.value,
                                onChanged: (value) {
                                  // Cambia el estado llamando al método en el controlador
                                  con.toggleBancariosAgregadas();
                                },
                              ),
                              Text(
                                'Agregar Datos Bancarios',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],)
              ],
            )
      ],
    )
      ]);
}
}
