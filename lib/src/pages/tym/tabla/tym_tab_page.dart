import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/pages/tym/tabla/tym_tab_controller.dart';
import 'package:maquinados_correa/src/widgets/ScrollableTableWrapper.dart';

class TymTabPage extends StatelessWidget {
  final TymTabController con = Get.put(TymTabController());
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
                      onTap: () => con.goToRegisterPage(), // funcion de boton
                      child: Container(
                        margin: EdgeInsets.only(top: 10, left: 1),
                        padding: EdgeInsets.all(20),
                        width: double.infinity,
                        color: Colors.white,
                        child: Text(
                          'Registro de nuevo operador',
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
                                color: Colors.black,
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
          body: ScrollableTableWrapper(child: _table(context))
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
          ]
      ),
    );
  }

  Widget _table(BuildContext context) {
    return FutureBuilder<List<Cotizacion>>(
      future: con.cotizaciones.value,
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
            // Listas de estatus en el orden deseado
            List<String> statusOrder = [
              'EN PROCESO',
              'SIG. PROCESO',
              'SUSPENDIDO',
              'RETRABAJO',
              'RECHAZADO',
              'EN ESPERA'
            ];

            // Obtener y ordenar los productos
            var productosOrdenados = cotizaciones.expand((cotizacion) {
              return cotizacion.producto!.where((producto) =>
              producto.estatus != 'CANCELADO' &&
                  producto.estatus != 'POR ASIGNAR' &&
                  producto.estatus != 'ENTREGADO'
              ).toList();
            }).toList();

            // Ordenar los productos por estatus y luego por O.T.
            productosOrdenados.sort((a, b) {
              int statusComparison = statusOrder.indexOf(a.estatus ?? '').compareTo(statusOrder.indexOf(b.estatus ?? ''));
              if (statusComparison != 0) {
                return statusComparison;
              }
              return (a.ot ?? '').compareTo(b.ot ?? '');
            });
            return DataTable(
              dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                return Colors.transparent; // Color base transparente para permitir colores personalizados
              }),
              columns: [
                DataColumn(label: Text('O.T.', style: TextStyle(fontSize: 17),)),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('No. PARTE/', textAlign: TextAlign.center, style: TextStyle(fontSize: 17.5),),
                      Text('PLANO', textAlign: TextAlign.center, style: TextStyle(fontSize: 17.5)),
                    ],
                  ),
                ),
                DataColumn(label: Text('ARTICULO', style: TextStyle(fontSize: 18),)),
                DataColumn(label: Text('CANTIDAD', style: TextStyle(fontSize: 18),)),
                DataColumn(label: Text('ESTATUS', style: TextStyle(fontSize: 18),)),
                DataColumn(label: Text('OPERACIÓN', style: TextStyle(fontSize: 18),)),
                DataColumn(label: Text('OPERADOR', style: TextStyle(fontSize: 18),)),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('TIEMPO EN', textAlign: TextAlign.center, style: TextStyle(fontSize: 17.5)),
                      Text('PROCESO', textAlign: TextAlign.center, style: TextStyle(fontSize: 17.5)),
                    ],
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('TIEMPO', textAlign: TextAlign.center, style: TextStyle(fontSize: 17.5)),
                      Text('TOTAL', textAlign: TextAlign.center, style: TextStyle(fontSize: 17.5)),
                    ],
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('FECHA', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                      Text('DE ENTREGA', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                DataColumn(label: Text('REPORTE', style: TextStyle(fontSize: 17),)),
              ],
              rows: productosOrdenados.map((producto) {
                Color rowColor = _getColorForDeliveryDateRow(producto.fecha);
                  return DataRow(
                    color: MaterialStateProperty.all(rowColor),
                    cells: [
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.ot ?? '',
                          style: TextStyle(fontSize: 16),),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.parte ?? '',
                          style: TextStyle(fontSize: 15),),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.articulo ?? '',
                          style: TextStyle(fontSize: 15),),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.cantidad.toString(),
                          style: TextStyle(fontSize: 16),),
                      )),
                      DataCell(
                        GestureDetector(
                          onTap: () => con.goToOt(producto),
                          child: Container(
                            color: _getColorForStatus(producto.estatus),
                            child: Text(producto.estatus ?? '',
                              style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.operacion ?? '',
                          style: TextStyle(fontSize: 16),),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.operador ?? '',
                            style: TextStyle(fontSize: 16)),
                      )),
                      DataCell(
                        FutureBuilder<Map<String, String>>(
                          future: con.calcularTiempoTotal(producto.id!, producto.parte ?? ''),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error', style: TextStyle(fontSize: 16));
                            } else {
                              return Text(snapshot.data?['actual'] ?? '', style: TextStyle(fontSize: 16));
                            }
                          },
                        ),
                      ),
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
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Text(producto.fecha ?? '',
                            style: TextStyle(fontSize: 16)),
                      )),
                      DataCell(GestureDetector(
                        onTap: () => con.goToOt(producto),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.picture_as_pdf, size: 23, color: Colors.red),
                              onPressed: () async {
                                await con.generarPDF(producto);
                              },
                            ),
                          ],
                        ),
                      )),
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
  Color _getColorForStatus(String? estatus) {
    switch (estatus) {
      case 'RETRABAJO':
        return Color.fromARGB(250, 250, 110, 0);
      case 'RECHAZADO':
        return Colors.red;
      case 'LIBERADO':
        return Colors.blue;
      default:
        return Colors.transparent; // Color por defecto
    }
  }

  Color _getColorForDeliveryDateRow(String? fechaEntrega) {
    if (fechaEntrega == null) return Colors.transparent;

    try {
      DateTime fechaEntregaDate = DateTime.parse(fechaEntrega);
      DateTime ahora = DateTime.now();
      int diferenciaDias = fechaEntregaDate.difference(ahora).inDays;

      if (diferenciaDias <= 0) {
        return Colors.red.withOpacity(0.5); // Fecha vencida o es hoy
      } else if (diferenciaDias <= 5) {
        return Colors.orange.withOpacity(0.5); // 5 días o menos
      } else if (diferenciaDias <= 10) {
        return Colors.yellow.withOpacity(0.5); // 10 días o menos
      } else {
        return Colors.transparent; // Más de 10 días
      }
    } catch (e) {
      return Colors.transparent; // En caso de error en el parsing de la fecha
    }
  }
}
