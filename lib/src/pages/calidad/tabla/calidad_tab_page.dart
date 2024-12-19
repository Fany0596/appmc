import 'package:flutter/material.dart'; // Importa los widgets y utilidades de flutter para construir interfaces de usuario
import 'package:flutter/services.dart'; // Importa servicios básicos de flutter
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart'; // Importa el modelo cotización
import 'package:maquinados_correa/src/pages/calidad/tabla/calidad_tab_controller.dart'; // Importa el controlador para manejar la lógica de la pagina
import 'package:get/get.dart'; // Importa el paquete GetX para la gestión del estado y navegación
import 'package:maquinados_correa/src/widgets/ScrollableTableWrapper.dart'; // Importa un widget para hacer que la tabla sea desplazable

class CalidadTabPage extends StatelessWidget { // Declara una página de interfaz de usuario
  CalidadTabController con = Get.put(CalidadTabController()); // Instancia y añade el controlador de calidad usando GetX
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
                    child: Column(children: [
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
                    ]))),

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
      body: ScrollableTableWrapper(child: _table(context))
    );
  }

  Widget _encabezado(BuildContext context) {  // Widget del encabezado
    return Container(  // Contenedor del encabezado
      child: Row(mainAxisAlignment: MainAxisAlignment.start, // Alineación
          children: [
        Image.asset(
          'assets/img/LOGO1.png',  // Ruta de la imagen del logo
          width: 55, // Ancho de imagen
          height: 55, // Alto de imagen
        ),
      ]),
    );
  }

  Widget _table(BuildContext context) {  // Widget de la tabla
    return FutureBuilder<List<Cotizacion>>(  // Construye el widget asíncronamente
      future: con.getCotizacion('GENERADA'), // Obtiene las cotizaciones con el status 'GENERADA'
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {  // Verifica si aun esta cargando
          return Center(child: CircularProgressIndicator());  // Muestra un indicador de cagra
        } else if (snapshot.hasError) {  // Verifica si ocurrió un error
          return Center(child: Text('Error: ${snapshot.error}'));  // Muestra el error
        } else {
          List<Cotizacion>? cotizaciones = snapshot.data;  // Guarda los datos obtenidos
          if (cotizaciones == null || cotizaciones.isEmpty) {  // Verifica si no hay datos
            return Center(child: Text('No hay cotizaciones generadas'));  // Muestra un mensaje
          } else {  // Si hay datos
            return DataTable(  // Retorna la tabla
              columns: [
                DataColumn(  // Columna 1
                    label: Text(  // Texto de la columna
                  'COTIZACIÓN',
                  style: TextStyle(  // Estilo del texto
                      fontSize: 17  // Tamaño de fuente
                  ),
                )),
                DataColumn(  // Columna 2
                    label: Text(  // Texto de la columna
                  'O.T.',
                  style: TextStyle(  // Estilo del texto
                      fontSize: 17  // Tamaño de fuente
                  ),
                )),
                DataColumn(  // Columna 3
                    label: Text(  // Texto de la columna
                  'PEDIDO',
                  style: TextStyle(  // Estilo del texto
                      fontSize: 17  // Tamaño de fuente
                  ),
                )),
                DataColumn(  // Columna 4
                    label: Text(  // Texto de la columna
                  'CLIENTE',
                  style: TextStyle(  // Estilo del texto
                      fontSize: 17  // Tamaño de fuente
                  ),
                )),
                DataColumn(  // Columna 5
                  label: Column(  // Columna para texto en doble renglon
                    children: [
                      Text(  // Texto del primer renglon
                        'No. PARTE/',
                        style: TextStyle( // Estilo del texto
                            fontSize: 16.5  // Tamaño de fuente
                        ),
                      ),
                      Text('PLANO', // Texto del segundo renglon
                          style: TextStyle( // Estilo del texto
                              fontSize: 16.5  // Tamaño de fuente
                          )
                      ),
                    ],
                  ),
                ),
                DataColumn(  // Columa 6
                    label: Text(  // Texto de la columna
                  'ARTICULO',
                  style: TextStyle(  // Estilo del texto
                      fontSize: 17  // Tamaño de fuente
                  ),
                )),
                DataColumn(  // Columna 7
                    label: Text(  // Texto de la columna
                  'CANTIDAD',
                  style: TextStyle(  // Estilo del texto
                      fontSize: 17  // Tamaño de fuente
                  ),
                )),
                DataColumn(  // Columna 8
                    label: Text(  // Texto de la columna
                  'ESTATUS',
                  style: TextStyle(  // Estilo del texto
                      fontSize: 17  // Tamaño de fuente
                  ),
                )),
                DataColumn(  // Columna 9
                    label: Text(  // Texto de la columna
                  'OPERADOR',
                  style: TextStyle( // Estilo del texto
                      fontSize: 17  // Tamaño de fuente
                  ),
                )),
                DataColumn(  // Columna 10
                  label: Column(  // Columna para colocar texto en doble renglon
                    children: [
                      Text('TIEMPO',  // Texto del primer renglon
                          style: TextStyle( // Estilo del texto
                              fontSize: 16.5  // Tamaño de fuente
                          )
                      ),
                      Text('TOTAL',  // Texto del segundo renglon
                          style: TextStyle(  // Estilo del texto
                              fontSize: 16.5  // Tamaño de fuente
                          )
                      ),
                    ],
                  ),
                ),
                DataColumn(  // Columna 11
                  label: Column(  // Columna para colocar texto en doble renglon
                    children: [
                      Text('FECHA',  // Texto del primer renglon
                          style: TextStyle(  // Estilo del texto
                              fontSize: 17  // Tamaño de fuente
                          )
                      ),
                      Text('DE ENTREGA',  // Texto del segundo renglon
                          style: TextStyle(  // Estilo del texto
                              fontSize: 17  // Tamaño de fuente
                          )
                      ),
                    ],
                  ),
                ),
              ],
              rows: cotizaciones.expand((cotizacion) {  // Expande los productos en filas
                return cotizacion.producto!
                    .where((producto) => producto.estatus != 'CANCELADO')  // Excluye productos en estatus 'CANCELADO'
                    .map((producto) {  // Mapea cada producto a una fila
                  return DataRow(  // Asigna los datos de los productos por celda
                    cells: [
                      DataCell(  // Columna 1
                          GestureDetector(  // Detecta el toque en la celda
                          onTap: () => con.goToOt(producto),  // Navega a los detalles del producto
                            child: Text(  // Texto de la celda
                              cotizacion.number ?? '',  // Muestra el número de cotización del producto o un campo vacio
                              style: TextStyle(  // Estilo del texto
                                  fontSize: 15  // Tamaño de fuente
                              ),
                            ),
                          )
                      ),
                      DataCell(  // Columna 2
                          GestureDetector(  // Detecta el toque en la celda
                          onTap: () => con.goToOt(producto),  // Navega a los detalles del producto
                            child: Text(  // Texto de la celda
                              producto.ot ?? '',  // Muestra el numero de OT del producto o un campo vacio
                              style: TextStyle(  // Estilo del texto
                                  fontSize: 15  // Tamaño de fuente
                              ),
                            ),
                          )
                      ),
                      DataCell(  // Columa 3
                          GestureDetector(  // Detecta el toque en la celda
                          onTap: () => con.goToOt(producto),  // Navega a los detalles del producto
                            child: Text(  // Texto de la celda
                              producto.pedido ?? '',  // Muesra el pedido del producto o un campo vacio
                              style: TextStyle(  // Estilo del texto
                                  fontSize: 14  // Tamaño de fuente
                              ),
                            ),
                          )
                      ),
                      DataCell(  // Columna 4
                          GestureDetector(  // Detecta el toque en la celda
                          onTap: () => con.goToOt(producto),  // Navega a los detalles del producto
                            child: Text(  // Texto de la celda
                              cotizacion.clientes!.name.toString(),  // Muestra el nombre del cliente de la cotización
                              style: TextStyle(  // Estilo del texto
                                  fontSize: 15  // Tamaño de fuente
                              ),
                            ),
                         )
                      ),
                      DataCell(  // Columna 5
                          GestureDetector(  // Detecta el toque en la celda
                          onTap: () => con.goToOt(producto),  // Navega a los detalles del producto
                            child: Text(  // Texto de la celda
                              producto.parte ?? '',  // Muestra el No. de parte o plano del producto o un campo vacio
                              style: TextStyle(  // Estilo del texto
                                  fontSize: 14  // Tamaño de fuente
                              ),
                            ),
                          )
                      ),
                      DataCell(  // Columna 6
                          GestureDetector(  // Detecta el toque en la celda
                          onTap: () => con.goToOt(producto),  // Navega a los detalles del producto
                            child: Text(  // Texto de la celda
                              producto.articulo ?? '',  // Muestra el nombre del producto o un campo vacio
                              style: TextStyle(  // Estilo del texto
                                  fontSize: 14  // Tamaño de fuente
                              ),
                            ),
                          )
                      ),
                      DataCell(  // Columna 7
                          GestureDetector(  // Detecta el toque en la celda
                          onTap: () => con.goToOt(producto),  // Navega a los detalles del producto
                            child: Text(  // Texto de la celda
                              producto.cantidad.toString(),  // Muestra la cantidad del producto
                              style: TextStyle(  // Estilo del texto
                                  fontSize: 15  // Tamaño de fuente
                              ),
                            ),
                          )
                      ),
                      DataCell(  // Columna 8
                        GestureDetector(  // Detecta el toque en la celda
                          onTap: () => con.goToOt(producto),  // Navega a los detalles del producto
                          child: Container(  // Contenedor para el estatus del producto
                            color: _getColorForStatus(producto.estatus),  // Llama al metodo que asigna el color dependiendo del estatus
                            child: Text(  // Texto de la celda
                              producto.estatus ?? '',  // Muesra el estatus del producto
                              style: TextStyle( // Estilo del texto
                                  fontSize: 15  // Tamaño de fuente
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(  // Columna 9
                          GestureDetector(  // Detecta el toque en la celda
                          onTap: () => con.goToOt(producto),  // Navega alos detalles del producto
                            child: Text(  // Texto de la celda
                              producto.operador ?? '',  // Muestra el operador que tiene el producto
                              style: TextStyle(  // Estilo del texto
                                  fontSize: 15  // Tamaño de fuente
                              ),
                            ),
                          )
                      ),
                      DataCell(  // Columna 10
                        FutureBuilder<Map<String, String>>(  // Maneja el cálculo asíncrono del tiempo estimado
                          future: con.calcularTiempoEstimado(producto.id!),  // Llama a la función calcularTiempoEstimado pasando el ID del producto
                          builder: (context, snapshot) {  // Constructor del FutureBuilder para manejar diferentes estados
                            if (snapshot.connectionState == ConnectionState.waiting) {  // Verifica si el futuro esta en proceso de ejecución
                              return CircularProgressIndicator();  // Muestyra un indicador de carga mientras se espera la respuesta
                            } else if (snapshot.hasError) {  // Verifica si ocurrio un error al obtener el futuro
                              return Text('Error',  // Muestra el texto en caso de fallo
                                  style: TextStyle(  // Estilo del texto
                                      fontSize: 15  // Tamaño de fuente
                                  )
                              );
                            } else {  // Cuando el futuro se resuelve correctamente
                              return Text(snapshot.data?['total'] ?? '',  // Muestra el dato total o un campo vacio si no esta disponible
                                  style: TextStyle(  // Estilo del texto
                                      fontSize: 15  // Tamaño de fuente
                                  )
                              );
                            }
                          },
                        ),
                      ),
                      DataCell(  // Columna 11
                          GestureDetector(  // Detecta el toque en la celda
                          onTap: () => con.goToOt(producto),  // Navega a los detalles del producto
                            child: Text(  // Texto de la celda
                              producto.fecha ?? '',  // Muestra la fecha de entrega del producto
                              style: TextStyle(  // Estilo del texto
                                  fontSize: 15  // Tamaño de fuente
                              ),
                            ),
                          )
                      ),
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

  Color _getColorForStatus(String? estatus) {  // Función para obtener el color según el estatus
    switch (estatus) {  // Verifica el valor del estatus
      case 'EN ESPERA':
        return Colors.grey;  // Devuelve gris si el estatus es 'EN ESPERA'
      case 'RETRABAJO':
        return Colors.yellow;  // Devuelve amarillo si el estatus es 'RETRABAJO'
      case 'SUSPENDIDO':
        return Colors.orange;  // Devuelve naranja si el estatus es 'SUSPENDIDO'
      case 'RECHAZADO':
        return Colors.red;  // Devuelve rojo si el estatus es 'RECHAZADO'
      case 'EN PROCESO':
        return Colors.lightGreenAccent;  // Devuelve verde claro si el estatus es 'EN PROCESO'
      case 'LIBERADO':
        return Colors.green;  // Devuelve verde si el estatus es 'LIBERADO'
      case 'SIG. PROCESO':
        return Colors.blue;  // Devuelve azul si el estatus es 'SIG. PROCESO'
      default:
        return Colors.white; // Devuelve blanco como color por defecto
    }
  }
}
