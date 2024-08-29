import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/pages/produccion/orders/detalles_produccion/detalles_produccion_controller.dart';
import 'package:maquinados_correa/src/widgets/no_data_widget.dart';
import 'package:intl/intl.dart';

class ProduccionDetallesPage extends StatelessWidget {
  ProduccionDetallesController con = Get.put(ProduccionDetallesController());

  String formatCurrency(double amount) {
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return currencyFormat.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => DefaultTabController(
        length: con.estatus.length,
        child: Scaffold(
            bottomNavigationBar: Container(
              color: Color.fromRGBO(176, 160, 117, 1),
              height: 255,
              child: Column(
                children: [
                  _textFielPedido(context),
                  _entrega(context),
                  _textOT(),
                  _totalToPay(context)
                ],
              ),
            ),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(130), //ancho del appbar
              child: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _encabezado(context),
                    _buttonReload(),
                  ],
                ),
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
                    con.cargarProductosPorEstatus(con.estatus[
                        index]); // Cargar productos al cambiar de pestaña
                  },
                ),
              ),
            ),
            body: TabBarView(
              children: con.estatus.map((estado) {
                List<Producto> productosPorEstado = con.cotizacion.producto!
                    .where((Producto producto) => producto.estatus == estado)
                    .toList();
                return productosPorEstado.isNotEmpty
                    ? ListView(
                        children: productosPorEstado.map((producto) {
                          return _cardProducto(context, producto);
                        }).toList(),
                      )
                    : Center(
                        child: NoDataWidget(
                          text: 'No hay ningún producto en estado $estado',
                        ),
                      );
              }).toList(),
            ))));
  }

  Widget _encabezado(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 1, left: 1),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Image.asset(
          'assets/img/LOGO1.png',
          width: 55, //ancho de imagen
          height: 55, //alto de imagen
        ),
        Text(
          '  MAQUINADOS CORREA',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ]),
    );
  }

  Widget _textCot(BuildContext context) {
    return Container(
      // return SafeArea(
      //child: Container(
      width: MediaQuery.of(context).size.width * 0.45,
      margin: EdgeInsets.only(bottom: 40, top: 22),
      child: TextField(
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Cotización #${con.cotizacion.number}',
            enabled: false,
            hintStyle: TextStyle(fontSize: 20, color: Colors.white),
          )),
      //)
    );
  }

  Widget _cardProducto(BuildContext context, Producto producto) {
    return GestureDetector(
        onTap: () => con.goToOt(producto),
        child: Container(
          height: 180,
          margin: EdgeInsets.only(left: 15, right: 15, top: 10),
          child: Card(
            elevation: 3.0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                Container(
                  height: 30,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      )),
                  child: Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      'Producto: ${producto.articulo}',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                        child: Text(
                            'Precio: ${formatCurrency(producto.precio ?? 0.0)}'),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                            'Total: ${formatCurrency(producto.total ?? 0.0)}'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _textFielPedido(BuildContext context) {
    return Container(
      //margin: EdgeInsets.all(10),
      margin: EdgeInsets.only(left: 30, right: 30),
      child: TextField(
        controller: con.pedidoController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Pedido',
          prefixIcon: Icon(Icons.list_outlined),
        ),
      ),
    );
  }

  Widget _entrega(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30),
      //margin: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          _selectDat(context);
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: con.entregaController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              hintText: 'Selecciona una fecha de entrega',
              hintStyle: TextStyle(fontSize: 14),
              prefixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDat(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      con.entregaController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Widget _textOT() {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30),
      //margin: EdgeInsets.all(10),
      child: TextField(
        // enabled: false,
        controller: con.otController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: ('Ot '),
          prefixIcon: Icon(Icons.engineering),
        ),
      ),
    );
  }

  Widget _totalToPay(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1, color: Colors.white),
        Container(
          margin: EdgeInsets.only(left: 10, top: 10),
          child: Text(
            'TOTAL: ${formatCurrency(con.totalt.value)}',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 19),
          ),
        ),
        con.cotizacion.status == 'CONFIRMADA'
            ? Container(
                //margin: EdgeInsets.only(to),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    child: ElevatedButton(
                      onPressed: () => con.generar(),
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(25),
                          backgroundColor: Colors.green),
                      child: Text(
                        'GENERAR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ))
            : Container()
      ],
    );
  }

  Widget _buttonReload() {
    return SafeArea(
      // deja espacio de la barra del telefono
      child: Container(
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(right: 20),
        child: IconButton(
            onPressed: () => con.reloadPage(),
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: 30,
            )),
      ),
    );
  }
}
