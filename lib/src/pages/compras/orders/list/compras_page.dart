import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/product.dart';
import 'package:maquinados_correa/src/pages/compras/orders/list/compras_controller.dart';
import 'package:maquinados_correa/src/widgets/no_data_widget.dart';
import 'package:intl/intl.dart';

class ComprasDetallesPage extends StatelessWidget {
  ComprasDetallesController con = Get.put(ComprasDetallesController());
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
                  con.cargarProductPorEstatus(con.estatus[index]); // Cargar productos al cambiar de pestaña
                }, ),
            ),
          ),

          ///////////////////////
          body: TabBarView(
            children: con.estatus.map((String estado) {
              // Filtrar los productos por estado
              List<Product> productPorEstado = con.oc.product!
                  .where((Product product) => product.estatus == estado)
                  .toList();

              return productPorEstado.isNotEmpty
                  ? ListView(
                children: productPorEstado
                    .map((Product product) {
                  return _cardProduct(product);
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
                hintText: '${con.oc.number}',
                hintStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.white
                ),

              )
          ),
        )
    );
  }
  Widget _cardProduct(Product product) {
    print('material del producto: ${product.name}');
    return GestureDetector(
      onTap: () => con.goToProduct( product),
      child: Container(
        height: 180,
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
                    'Producto: ${product.descr}',
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
                      child: Text('Descripción: ${product.descr ?? ''}'),

                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text('Material: ${product.name ?? ''}'),

                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text('Cantidad: ${product.cantidad ?? ''}'),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text('Precio: ${formatCurrency(product.precio ?? 0.0)}'),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text('Total: ${formatCurrency(product.total ?? 0.0)}'),
                    ),
                  ],
                ),
              ),
            ],
          ),

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
              con.oc.status == 'ABIERTA'
                  ? Container(
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
                          onPressed: () => con.updateOc(),
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
                          onPressed: () => con.generarPDF(),
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
                    ],
                  )
              )
                  : Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 460),
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
                          onPressed: () => con.updateOc(),
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
                        margin: EdgeInsets.only(left: 65),
                        child: ElevatedButton(
                          onPressed: () => con.generarPDF(),
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
                    ],)
                ],
              )
            ],
          )
        ]);
  }
}
