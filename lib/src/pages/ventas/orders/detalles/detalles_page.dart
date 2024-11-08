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
    return Obx(() =>
        DefaultTabController(
          length: con.estatus.length,
          child: Scaffold(
            bottomNavigationBar: Container(
              color: Color.fromRGBO(176, 160, 117, 1),
              height: 150,
              child: Column(
                children: [
                  _totalToPay(context),
                ],
              ),
            ),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(130), // ancho del appbar
              child: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _encabezado(context),
                    _buttonReload(),
                  ],
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
              children: con.estatus.map((String estado) {
                // Filtrar los productos por estado
                List<Producto> productosPorEstado = con.cotizacion.producto!
                    .where((Producto producto) => producto.estatus == estado)
                    .toList();
                return productosPorEstado.isNotEmpty
                    ? ListView(
                  children: productosPorEstado.map((Producto producto) {
                    return _cardProducto(producto);
                  }).toList(),
                )
                    : Center(
                  child: NoDataWidget(
                    text: 'No hay ningún producto en estado $estado',
                  ),
                );
              }).toList(),
            ),
          ),
        ));
  }

  Widget _encabezado(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 1, left: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/img/LOGO1.png',
            width: 55, // ancho de imagen
            height: 55, // alto de imagen
          ),
          Text(
            '  Cotización #${con.cotizacion.number}',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardProducto(Producto producto) {
    return Container(
      height: 200,
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
                ),
              ),
              child: Container(
                margin: EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => con.goToProductUpdate(producto),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Producto: ${producto.articulo}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _showConfirmDeleteDialog(producto);
                      },
                    ),
                  ],
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
                    child: Text('Descripción: ${producto.descr ?? ''}'),
                  ),
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
                    child:
                    Text('Total: ${formatCurrency(producto.total ?? 0.0)}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDeleteDialog(Producto producto) {
    Get.defaultDialog(
      title: 'Confirmación',
      content:
      Text('¿Estás seguro de eliminar el producto ${producto.descr}?'),
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back(); // Cierra el diálogo de confirmación
          },
          child: Text('No'),
        ),
        ElevatedButton(
          onPressed: () {
            con.deleteProduct(
                producto); // Llama al método para eliminar el producto
            Get.back(); // Cierra el diálogo de confirmación
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text('Sí'),
        ),
      ],
    );
  }

  Widget _totalToPay(BuildContext context) {
    return Container(
      color: Color.fromRGBO(176, 160, 117, 1),
      child: Column(
        children: [
          Divider(height: 1, color: Colors.white),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Container(
                  alignment: Alignment.center ,
                  child: Text(
                    'TOTAL: ${formatCurrency(con.totalt.value)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 19,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                if (con.cotizacion.status == 'ABIERTA') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => con.updateCancelada(),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(15),
                          backgroundColor: Colors.red,
                        ),
                        child: Text('CANCELAR', style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () => con.updateCotizacion(),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(15),
                          backgroundColor: Colors.green,
                        ),
                        child: Text('CONFIRMAR', style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () => con.generarCot(),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(15),
                          backgroundColor: Colors.black,
                        ),
                        child: Text('PDF', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ] else if (con.cotizacion.status == 'GENERADA') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => con.updateCerrada(),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(15),
                          backgroundColor: Colors.green,
                        ),
                        child: Text('CERRAR', style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () => con.generarCot(),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(15),
                          backgroundColor: Colors.black,
                        ),
                        child: Text('PDF', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => con.generarCot(),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(15),
                          backgroundColor: Colors.black,
                        ),
                        child: Text('PDF', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
