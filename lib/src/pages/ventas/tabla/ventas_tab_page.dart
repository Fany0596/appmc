import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/pages/ventas/tabla/ventas_tab_controller.dart';
import 'package:get/get.dart';

class VentasTabPage extends StatelessWidget {
  VentasTabController con = Get.put(VentasTabController());
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
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
                  onTap: () => con.goToPerfilPage(),
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
                  onTap: () => con.goToNewVendedorPage(),
                  child: Container(
                    margin: EdgeInsets.only(top: 10, left: 1),
                    padding: EdgeInsets.all(20),
                    width: double.infinity,
                    color: Colors.white,
                    child: Text(
                      'Registro de nuevo vendedor',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => con.goToNewClientePage(),
                  child: Container(
                    margin: EdgeInsets.only(top: 10, left: 1),
                    padding: EdgeInsets.all(20),
                    width: double.infinity,
                    color: Colors.white,
                    child: Text(
                      'Registro de nuevo cliente',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => con.exportToExcel(), // Llamada a la función
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
                            color: Colors.white,
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
                            color: Colors.white,
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
      body: Focus(
        autofocus: true,
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _scrollController.animateTo(
                _scrollController.offset + 50,
                duration: Duration(milliseconds: 100),
                curve: Curves.easeInOut,
              );
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _scrollController.animateTo(
                _scrollController.offset - 50,
                duration: Duration(milliseconds: 100),
                curve: Curves.easeInOut,
              );
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: _table(context),
          ),
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
            width: 55,
            height: 55,
          ),
          Text(
            '  MAQUINADOS CORREA',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
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
                DataColumn(label: Text('COTIZACIÓN', style: TextStyle(fontSize: 11))),
                DataColumn(label: Text('VENDEDOR', style: TextStyle(fontSize: 11))),
                DataColumn(label: Text('PEDIDO', style: TextStyle(fontSize: 11))),
                DataColumn(label: Text('CLIENTE', style: TextStyle(fontSize: 11))),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('No. PARTE/', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5)),
                      Text('PLANO', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5)),
                    ],
                  ),
                ),
                DataColumn(label: Text('ARTICULO', style: TextStyle(fontSize: 11))),
                DataColumn(label: Text('CANTIDAD', style: TextStyle(fontSize: 11))),
                DataColumn(label: Text('ESTATUS', style: TextStyle(fontSize: 11))),
                DataColumn(label: Text('MATERIAL', style: TextStyle(fontSize: 11))),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('PRECIO', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5)),
                      Text('MATERIAL', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5)),
                    ],
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('PRECIO', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5)),
                      Text('UNITARIO', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5)),
                    ],
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('FECHA', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                      Text('DE ENTREGA', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ],
              rows: cotizaciones.expand((cotizacion) {
                return cotizacion.producto!.map((producto) {
                  return DataRow(
                      cells: [
                  DataCell(Text(cotizacion.number ?? '', style: TextStyle(fontSize: 10))),
                  DataCell(Text(cotizacion.vendedores!.name.toString(), style: TextStyle(fontSize: 10))),
                  DataCell(Text(producto.pedido ?? '', style: TextStyle(fontSize: 9))),
                  DataCell(Text(cotizacion.clientes!.name.toString(), style: TextStyle(fontSize: 10))),
                  DataCell(Text(producto.parte ?? '', style: TextStyle(fontSize: 9))),
                  DataCell(Text(producto.articulo ?? '', style: TextStyle(fontSize: 9))),
                  DataCell(Text(producto.cantidad.toString(), style: TextStyle(fontSize: 10))),
                  DataCell(
                  Container(
                          color: _getColorForStatus(producto.estatus),
                          child: Text(producto.estatus ?? '', style: TextStyle(fontSize: 10)),
                        ),
                      ),
                      DataCell(Text(producto.name ?? '', style: TextStyle(fontSize: 10))),
                      DataCell(GestureDetector(
                          onTap: () => con.goToPrice(producto),child: Text('\$${producto.pmaterial ?? '----'}',
                          style: TextStyle(fontSize: 10)))),
                      DataCell(Text('\$${producto.precio!.toStringAsFixed(2)}', style: TextStyle(fontSize: 10))),
                      DataCell(Text(producto.fecha ?? '', style: TextStyle(fontSize: 10))),
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
      case 'EN ESPERA':
        return Colors.grey;
      case 'RETRABAJO':
        return Colors.yellow;
      case 'SUSPENDIDO':
        return Colors.orange;
      case 'RECHAZADO':
        return Colors.red;
      case 'EN PROCESO':
        return Colors.lightGreenAccent;
      case 'LIBERADO':
        return Colors.green;
      case 'SIG. PROCESO':
        return Colors.blue;
      default:
        return Colors.white; // Color por defecto
    }
  }
}
