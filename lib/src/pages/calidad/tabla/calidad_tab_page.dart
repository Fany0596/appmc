import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/pages/calidad/tabla/calidad_tab_controller.dart';
import 'package:get/get.dart';

class CalidadTabPage extends StatelessWidget {
  CalidadTabController con = Get.put(CalidadTabController());
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
        Scaffold(
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
                            : AssetImage(
                            'assets/img/LOGO1.png') as ImageProvider,
                        radius: 70,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 0),
                      child: Text(
                        '${con.user.value.name ?? ''}  ${con.user.value
                            .lastname}',
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
                              )
                          ),
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
                              )
                          ),
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
        ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 1, left: 1),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
            return DataTable(
              columns: [
                DataColumn(label: Text('COTIZACIÓN', style: TextStyle(fontSize: 13),)),
                DataColumn(label: Text('O.T.', style: TextStyle(fontSize: 13),)),
                DataColumn(label: Text('PEDIDO', style: TextStyle(fontSize: 13),)),
                DataColumn(label: Text('CLIENTE', style: TextStyle(fontSize: 13),)),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('No. PARTE/', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5),),
                      Text('PLANO', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5)),
                    ],
                  ),
                ),
                DataColumn(label: Text('ARTICULO', style: TextStyle(fontSize: 13),)),
                DataColumn(label: Text('CANTIDAD', style: TextStyle(fontSize: 13),)),
                DataColumn(label: Text('ESTATUS', style: TextStyle(fontSize: 13),)),
                DataColumn(label: Text('OPERADOR', style: TextStyle(fontSize: 13),)),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('TIEMPO', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5)),
                      Text('ESTIMADO', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5)),
                    ],
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('FECHA', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                      Text('DE ENTREGA', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
              rows: cotizaciones.expand((cotizacion) {
                return cotizacion.producto!.where((producto) => producto.estatus != 'CANCELADO').map((producto) {
                  return DataRow(
                    cells: [
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(cotizacion.number ?? '',
                          style: TextStyle(fontSize: 11),),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.ot ?? '',
                          style: TextStyle(fontSize: 11),),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.pedido ?? '',
                          style: TextStyle(fontSize: 10),),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(cotizacion.clientes!.name.toString(),
                          style: TextStyle(fontSize: 11),),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.parte ?? '',
                          style: TextStyle(fontSize: 10),),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.articulo ?? '',
                          style: TextStyle(fontSize: 10),),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.cantidad.toString(),
                          style: TextStyle(fontSize: 11),),
                      )),
                      DataCell(
                        GestureDetector(
                          onTap: () => con.goToOt(producto),
                          child: Container(
                            color: _getColorForStatus(producto.estatus),
                            child: Text(producto.estatus ?? '',
                              style: TextStyle(fontSize: 11),),
                          ),
                        ),
                      ),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.operador ?? '',
                          style: TextStyle(fontSize: 11),),
                      )),
                      DataCell(
                        FutureBuilder<Map<String, String>>(
                          future: con.calcularTiempoEstimado(producto.id!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error', style: TextStyle(fontSize: 11));
                            } else {
                              return Text(snapshot.data?['total'] ?? 'N/A', style: TextStyle(fontSize: 11));
                            }
                          },
                        ),
                      ),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.fecha ?? '',
                          style: TextStyle(fontSize: 11),),
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
