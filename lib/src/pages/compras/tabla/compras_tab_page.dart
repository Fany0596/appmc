import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/pages/compras/tabla/compras_tab_controller.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/widgets/ScrollableTableWrapper.dart';

class ComprasTabPage extends StatelessWidget {
  ComprasTabController con = Get.put(ComprasTabController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        drawer: Drawer(
          child: Container(
            color: Colors.white60,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.only(top: 57),
                    child: CircleAvatar(
                      backgroundImage: con.user.value.image != null
                          ? NetworkImage(con.user.value.image!)
                          : AssetImage('assets/img/LOGO1.png') as ImageProvider,
                      radius: 70,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 0),
                    child: Text(
                      '${con.user.value.name ?? ''}  ${con.user.value.lastname}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => con.goToPerfilPage(), // funcion de boton
                    child: Container(
                      margin: EdgeInsets.only(top: 40, left: 1),
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      color: Colors.white,
                      child: Text(
                        'Perfil',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => con.goToNewProveedorPage(),
                    // funcion de boton
                    child: Container(
                      margin: EdgeInsets.only(top: 10, left: 1),
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      color: Colors.white,
                      child: Text(
                        'Registro de nuevo proveedor',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => con.exportToExcel(),
                    // funcion de boton
                    child: Container(
                      margin: EdgeInsets.only(top: 10, left: 1),
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      color: Colors.white,
                      child: Text(
                        'Exportar a Excel',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20, left: 20),
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => con.goToRoles(),
                            icon: Icon(
                              Icons.supervised_user_circle,
                              color: Colors.black,
                              size: 30,
                            )),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20, left: 160),
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => con.signOut(),
                            icon: Icon(
                              Icons.power_settings_new,
                              color: Colors.black,
                              size: 30,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        appBar: AppBar(
          title: _encabezado(context),
        ),
        body: ScrollableTableWrapper(child: _table(context))
      ),
    );
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
      ]),
    );
  }

  Widget _table(BuildContext context) {
    return FutureBuilder<List<Oc>>(
      future: con.getOc('ABIERTA'), // Cambiar a 'GENERADA'
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Oc>? oc = snapshot.data;
          if (oc == null || oc.isEmpty) {
            return Center(child: Text('No hay ordenes generadas'));
          } else {
            // Ordenar la lista por número de OC
            oc.sort((a, b) => a.number!.compareTo(b.number!));
            return DataTable(
              columns: [
                DataColumn(
                    label: Text(
                  'OC',
                  style: TextStyle(fontSize: 15),
                )),
                DataColumn(
                    label: Text(
                  'COT.',
                  style: TextStyle(fontSize: 15),
                )),
                DataColumn(
                    label: Text(
                  'PROVEEDOR',
                  style: TextStyle(fontSize: 15),
                )),
                DataColumn(
                    label: Text(
                  'ARTICULO',
                  style: TextStyle(fontSize: 15),
                )),
                DataColumn(
                    label: Text(
                  'MATERIAL',
                  style: TextStyle(fontSize: 15),
                )),
                DataColumn(
                    label: Text(
                  'CANTIDAD',
                  style: TextStyle(fontSize: 15),
                )),
                DataColumn(
                    label: Text(
                  'PRECIO',
                  style: TextStyle(fontSize: 15),
                )),
                DataColumn(
                    label: Text(
                  'TOTAL',
                  style: TextStyle(fontSize: 15),
                )),
                DataColumn(
                    label: Text(
                  'ESTATUS',
                  style: TextStyle(fontSize: 15),
                )),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('CANTIDAD',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15)),
                      Text('RECIBIDA',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('FECHA',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15)),
                      Text('DE SOLICITUD',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('FECHA',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15)),
                      Text('DE ENTREGA',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('FECHA',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15)),
                      Text('DE RECEPCIÓN',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ],
              rows: oc.expand((oc) {
                return oc.product!.map((product) {
                  Color? rowColor = _getRowColor(product.fecha, product.estatus, product.pedido, product.cantidad.toString().split('.')[0]);

                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return rowColor ?? Colors.transparent;
                      },
                    ),
                    cells: [
                      DataCell(GestureDetector(
                        onTap: () => con.goToProduct(product),
                        child: Text(
                          oc.number ?? '',
                          style: TextStyle(fontSize: 13),
                        ),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToProduct(product),
                        child: Text(
                          oc.cotizacion!.number ?? '',
                          style: TextStyle(fontSize: 13),
                        ),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToProduct(product),
                        child: Text(
                          oc.provedor!.name ?? '',
                          style: TextStyle(fontSize: 12),
                        ),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToProduct(product),
                        child: Text(
                          product!.descr ?? '',
                          style: TextStyle(fontSize: 12),
                        ),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToProduct(product),
                        child: Text(
                          product.name ?? '',
                          style: TextStyle(fontSize: 12),
                        ),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToProduct(product),
                        child: Text(
                          product.cantidad.toString(),
                          style: TextStyle(fontSize: 13),
                        ),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToProduct(product),
                        child: Text(
                          '\$${product.precio!.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 13),
                        ),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToProduct(product),
                        child: Text(
                          '\$${product.total!.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 13),
                        ),
                      )),
                      DataCell(
                        GestureDetector(
                          onTap: () => con.goToProduct(product),
                          child: Text(
                            product.estatus ?? '',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      DataCell(
                        GestureDetector(
                          onTap: () => con.goToProduct(product),
                          child: Text(
                            product.pedido != null &&
                                    product.pedido!.isNotEmpty
                                ? product.pedido!
                                : '',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      DataCell(GestureDetector(
                        onTap: () => con.goToProduct(product),
                        child: Text(
                          oc.soli ?? '',
                          style: TextStyle(fontSize: 13),
                        ),
                      )),
                      DataCell(
                        GestureDetector(
                          onTap: () => con.goToProduct(product),
                          child: Text(
                            oc.ent ?? '',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      DataCell(GestureDetector(
                        onTap: () => con.goToProduct(product),
                        child: Text(
                          product.recep ?? '',
                          style: TextStyle(fontSize: 13),
                        ),
                      )),
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
// Nueva función para determinar el color de la fila
  Color? _getRowColor(String? fechaEntrega, String? estatus, String? pedido, String? cantidad) {
    if (estatus == 'RECIBIDO' && pedido == cantidad) {
      return Colors.green[200];
    }
    if (estatus == 'RECIBIDO' && pedido != cantidad) {
      return Colors.orange[200];
    }

    return null; // Sin color para el resto de los casos
  }
}
