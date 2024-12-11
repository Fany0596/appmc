import 'package:flutter/material.dart'; // Importa los widgets y utilidades de flutter para construir interfaces de usuario
import 'package:flutter/services.dart'; // Importa servicios básicos de flutter
import 'package:maquinados_correa/src/models/cotizacion.dart'; // Importa el modelo cotización
import 'package:maquinados_correa/src/pages/calidad/tabla/calidad_tab_controller.dart'; // Importa el controlador para manejar la lógica de la pagina
import 'package:get/get.dart'; // Importa el paquete GetX para la gestión del estado y navegación
import 'package:maquinados_correa/src/widgets/ScrollableTableWrapper.dart'; // Importa un widget para hacer que la tabla sea desplazable

class CalidadTabPage extends StatelessWidget { // Declara una página de interfaz de usuario
  CalidadTabController con = Get.put(
      CalidadTabController()); // Instancia y añade el controlador de calidad usando GetX

  @override
  Widget build(BuildContext context) {  // Método que construye la interfaz de la página
    return Obx(  // Observa cambios en las variables reactivas del controlador
      () => Scaffold( // Define una estructura visual de la página
          drawer: Drawer( // Añade un cajón de menú lateral
            child: Container( // Contenedor para el cajon
              color: Colors.white60, // Define el color de fondo
              child: SingleChildScrollView( // Permite desplazar el contenido verticalmente
                child: Column( // Organiza los widgets en columna
                  children: [
                    Container( // Contenedor para la imagen de perfil
                      margin: EdgeInsets.only(top: 57), // Margen superior
                      child: CircleAvatar( // Muestra la imagen de perfil de forma circular
                        backgroundImage: con.user.value.image !=
                                null // Verifica si hay una imagen del usuario
                            ? NetworkImage(con.user.value
                                .image! // Si existe, usa la imagen de la red
                        )
                            : AssetImage('assets/img/LOGO1.png')
                                as ImageProvider, // Si no, usa la imagen local
                        radius: 70, // Tamaño del circulo
                      ),
                    ),
                    Container( // Contenedor para el nombre de usuario
                      margin: EdgeInsets.only(top: 10), // Margen superior
                      child: Text( // Muestra el nombre del usuario
                        '${con.user.value.name ?? ''}  ${con.user.value.lastname}', // Nombre y apellido del usuario
                        style: TextStyle( // Estilo del texto
                          fontSize: 16, // Tamaño de fuente
                          color: Colors.black, // Color del texto
                          fontWeight: FontWeight.bold, // Texto en negritas
                        ),
                      ),
                    ),
                    GestureDetector( // Detecta el toque en el contenedor
                      onTap: () => con.goToPerfilPage(), // Navega a la página de perfil
                      child: Container( // Contenedor de perfil
                        margin: EdgeInsets.only(top: 40),  // Margen superior
                        padding: EdgeInsets.all(10),  // Espacio interno
                        width: double.infinity, // Ancho total
                        color: Colors.white, // Color de fondo
                        child: Text(
                          'Perfil', // Texto del bóton
                          style: TextStyle(// Estilo del texto
                            fontSize: 13, // Tamaño de fuente
                            color: Colors.black, // Color de texto
                            fontWeight: FontWeight.bold, // Texto en negritas
                          ),
                        ),
                      ),
                    ),
                    Row(// Fila para mostrar los botones
                      children: [
                        Container(  // Contenedor para el bóton de roles
                          margin: EdgeInsets.only(top: 20, left: 20),  // Margen superior e izquierdo
                          child: IconButton(  // Bóton de icono
                              onPressed: () => con.goToRoles(),  // Navega a roles
                              icon: Icon(
                                Icons.supervised_user_circle,  // Icono
                                color: Colors.black,  // Color del icono
                                size: 30,  // Tamaño del icono
                              )),
                        ),
                        Container(  // Contenedor para el boton de ceerrar sesión
                          margin: EdgeInsets.only(top: 20, left: 160), // Margen superior e izquierdo
                          child: IconButton(  // Bóton de icono
                              onPressed: () => con.signOut(),  // Cierra sesión
                              icon: Icon(
                                Icons.power_settings_new,  // Icono de cerrar sesión
                                color: Colors.black,  // Color del icono
                                size: 30,  // Tamaño del icono
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          appBar: AppBar(  // Barra de la aplicación
            title: _encabezado(context),  // Llama al widget encabezado
          ),
          body: ScrollableTableWrapper(child: _table(context))  // Tabla desplazable
      ),
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
