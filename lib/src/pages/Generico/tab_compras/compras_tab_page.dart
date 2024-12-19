import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/pages/Generico/tab_compras/compras_tab_controller.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/widgets/ScrollableTableWrapper.dart';

class ComprasTabPage2 extends StatelessWidget {
  ComprasTabController2 con = Get.put(ComprasTabController2());
  final RxBool isHoveredPerfil =
      false.obs; // Estado para el hover del botón "Perfil"
  final RxBool isHoveredRoles = false.obs;
  final RxBool isHoveredSalir = false.obs;

  @override
  Widget build(BuildContext context) {
    // Determinar el ancho del drawer basado en el ancho de la pantalla
    double drawerWidth = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width *
        0.45 // Celulares (ancho menor a 600)
        : MediaQuery.of(context).size.width * 0.14; // Pantallas más grandes

    return Obx(() => ZoomDrawer(
      controller: con.zoomDrawerController,
      menuScreen: _buildMenuScreen(context),
      mainScreen: _buildMainScreen(context),
      mainScreenScale: 0.0,
      slideWidth: drawerWidth,
      // Usar el ancho calculado
      menuScreenWidth: drawerWidth,
      // Mismo ancho para el menú
      borderRadius: 0,
      showShadow: false,
      angle: 0.0,
      menuBackgroundColor: Colors.grey,
      mainScreenTapClose: true,
    ));
  }

  Widget _buildMenuScreen(BuildContext context) {
    // Obtener el tamaño de la pantalla
    final screenWidth = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.75
        : MediaQuery.of(context).size.width * 0.25;
    final screenHeight = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.75
        : MediaQuery.of(context).size.width * 0.25;
    final containerHeight = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.48
        : MediaQuery.of(context).size.width * 0.145;
    final textHeight = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.48
        : MediaQuery.of(context).size.width * 0.11;

    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
        width: double.infinity,
        height:
        MediaQuery.of(context).size.height, // Altura total de la pantalla
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
                    child: Column(
                        children: [
                          Container(
                            height: containerHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/img/fondo2.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.topCenter,
                                  margin: EdgeInsets.only(top: screenHeight * 0.02),
                                  child: CircleAvatar(
                                    backgroundImage: con.user.value.image != null
                                        ? NetworkImage(con.user.value.image!)
                                        : AssetImage('assets/img/LOGO1.png')
                                    as ImageProvider,
                                    radius: screenWidth * 0.2,
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 0),
                                  child: Text(
                                    '${con.user.value.name ?? ''}  ${con.user.value.lastname}',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 1, bottom: 0),
                                  child: Text(
                                    '${con.user.value.email ?? ''}',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          MouseRegion(
                            onEnter: (_) => isHoveredPerfil.value = true,
                            onExit: (_) => isHoveredPerfil.value = false,
                            child: GestureDetector(
                              onTap: () => con.goToPerfilPage(),
                              child: Obx(() => Container(
                                margin:
                                EdgeInsets.only(top: screenHeight * 0.05, left: 1),
                                padding: EdgeInsets.all(screenWidth * 0.009),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isHoveredPerfil.value
                                      ? Colors.blueGrey
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 15),
                                        Icon(
                                          Icons.person,
                                          size: textHeight * 0.15,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 20),
                                        Text(
                                          'Perfil',
                                          style: TextStyle(
                                            fontSize: textHeight * 0.09,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                            ),
                          ),
                        ]
                    )
                )
            ),

            // Botones en la parte inferior
            Container(
              decoration: BoxDecoration(
                  border: BorderDirectional(
                      top: BorderSide(
                        width: 2,
                        color: Color.fromARGB(070, 080, 080, 600),
                      ))),
              padding: EdgeInsets.symmetric(vertical: 10),
              // Espaciado alrededor de los botones
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MouseRegion(
                    onEnter: (_) => isHoveredRoles.value = true,
                    onExit: (_) => isHoveredRoles.value = false,
                    child: GestureDetector(
                      onTap: () => con.goToRoles(),
                      child: Obx(
                            () => Container(
                          padding: EdgeInsets.all(screenWidth * 0.009),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isHoveredRoles.value
                                ? Colors.blueGrey
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 15),
                                  Icon(
                                    Icons.supervised_user_circle,
                                    //size: textHeight * 0.15,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    'Roles',
                                    style: TextStyle(
                                      fontSize: textHeight * 0.09,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) => isHoveredSalir.value = true,
                    onExit: (_) => isHoveredSalir.value = false,
                    child: GestureDetector(
                      onTap: () => con.signOut(),
                      child: Obx(
                            () => Container(
                          padding: EdgeInsets.all(screenWidth * 0.009),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isHoveredSalir.value
                                ? Colors.blueGrey
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 15),
                                  Icon(
                                    Icons.output,
                                    //size: textHeight * 0.15,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    'Salir',
                                    style: TextStyle(
                                      fontSize: textHeight * 0.09,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => con.zoomDrawerController.toggle?.call(),
        ),
        title: _encabezado(context),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints:
          BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: _table(context),
        ),
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
                      DataCell(Text(
                        oc.number ?? '',
                        style: TextStyle(fontSize: 13),
                      )),
                      DataCell(Text(
                        oc.cotizacion!.number ?? '',
                        style: TextStyle(fontSize: 13),
                      )),
                      DataCell(Text(
                        oc.provedor!.name ?? '',
                        style: TextStyle(fontSize: 12),
                      )),
                      DataCell(Text(
                        product!.descr ?? '',
                        style: TextStyle(fontSize: 12),
                      )),
                      DataCell(Text(
                        product.name ?? '',
                        style: TextStyle(fontSize: 12),
                      )),
                      DataCell(Text(
                        product.cantidad.toString(),
                        style: TextStyle(fontSize: 13),
                      )),
                      DataCell(Text(
                        '\$${product.precio!.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 13),
                      )),
                      DataCell(Text(
                        '\$${product.total!.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 13),
                      )),
                      DataCell(
                        Text(
                          product.estatus ?? '',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      DataCell(
                        Text(
                          product.pedido != null &&
                                  product.pedido!.isNotEmpty
                              ? product.pedido!
                              : '',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      DataCell(Text(
                        oc.soli ?? '',
                        style: TextStyle(fontSize: 13),
                      )),
                      DataCell(
                        Text(
                          oc.ent ?? '',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      DataCell(Text(
                        product.recep ?? '',
                        style: TextStyle(fontSize: 13),
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
