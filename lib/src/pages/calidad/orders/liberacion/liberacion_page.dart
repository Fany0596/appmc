import 'package:flutter/cupertino.dart';  // Importa los paquetes para widgets de estilo cupertino
import 'package:flutter/material.dart'; // Importa soporte para widgets de material design
import 'package:flutter/services.dart';  // Importa el acceso a servicios de sistema
import 'package:get/get.dart';  // Importa el paquete Getx para gestin de estado
import 'package:maquinados_correa/src/models/producto.dart';  // Importa modelo producto
import 'package:maquinados_correa/src/pages/calidad/orders/liberacion/liberacion_controller.dart';  // Importa controlador de liberación

class LiberacionPage extends StatelessWidget {  // Define la clase que extiende el StatelessWidget para no tener estado mutable
  Producto? producto; // Declara variable producto que contiene los detalles del producto actual
  final LiberacionController con = Get.put(LiberacionController()); // Instancia del controlador y facilitar la gestión de dependencias con Getx

  LiberacionPage({@required this.producto});  // Constructor de LiberacionPage que toma a producto como parametro opcional

  @override
  Widget build(BuildContext context) {  // Construye la interfaz de usuario
    return Scaffold(  // Widget para el diseño de la página
      body: SingleChildScrollView( // Permite el desplazamiento en la pantalla
        child: Stack(  // Permite superponer widgets sobre otros
          children: [
            Column( // Organiza los widgets de forma vertical
                crossAxisAlignment: CrossAxisAlignment.start, // Alinea los elementos a la izquierda
                // posiciona elementos uno sobre otro
                children: [
                  _backGroundCover(context),  // Llama al widget del fondo del encabezado
                ]),
            Column(  // Segunda columna para organizar los widgets de forma vertical
              crossAxisAlignment: CrossAxisAlignment.start,
              // posiciona elementos uno sobre otro
              children: [
                Padding(  // Añade un espacio alrededor del widget _encabezado
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: _encabezado(), // Widget de encabezado
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: _buttonBack(), // Widget del boton de regreso
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120),
                  child: _textArticulo(),  // Widget del texto principal
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _boxForm(context),  // Widget que contiene el formulario
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _backGroundCover(BuildContext context) {  // Widget del fondo del encbezado
    return Container(
      width: double.infinity,  // Ancho del contenedor se ajusta al ancho completo de la pantalla
      height: MediaQuery.of(context).size.height * 0.28,  // Altura proporcional a la pantalla
      color: Colors.grey,  // Color de fondo gris para el encabezado
    );
  }

  Widget _encabezado() {  // Widget de encabezao de la pagina
    return Row(  // Coloca los widgets de forma horizontal
      children: [
        Image.asset(
          'assets/img/LOGO1.png',  // Ruta de la imagen del logo
          width: 55,  // Ancho de la imagen
          height: 55,  // Altura de la imagen
        ),
      ],
    );
  }

  Widget _textArticulo() {  // Widget del texto principal de la página
    return Text(
      'DETERMINACIÓN DEL PRODUCTO',  // Texto a mostrar como título
      textAlign: TextAlign.center,  // Alineación del texto al centro
      style: TextStyle(
        fontWeight: FontWeight.bold,  // Texto en negrita
        fontSize: 30,  // Tamaño de fuente
        color: Colors.black,  // Color del texto negro
      ),
    );
  }

  Widget _boxForm(BuildContext context) {  // Widget de botones segun las opciones
    return Container(
      decoration: BoxDecoration(  // Decoración para el fondo del formulario
        color: Colors.white,  // Fondo blanco
        boxShadow: [
          BoxShadow(  // Sombra alrededor del contenedor para dar profundidad
            color: Colors.black54,  // Color de la sombra
            blurRadius: 15, // Radio de desenfoque de la sombra
            offset: Offset(0, 0.085),  // Desplazamiento de la sombra
          ),
        ],
      ),
      child: Column( // Columna para organizar los widgets verticalmente
        crossAxisAlignment: CrossAxisAlignment.center,  // Alineación centrada
        children: [
          _textNewCot(),  // Texto de instrucción dentro del formulario
          Row(  // Fila para mostrar los botones segun el estado del producto
              mainAxisAlignment: MainAxisAlignment.center, children: [  // Alineación centrada en la fila
            con.producto!.estatus == 'EN ESPERA'  // Mostrar el boton de rechazo si el estatus es 'EN ESPERA'
                ? Container(child: _buttonRechazo(context))
                : Container(),
            con.producto!.estatus == 'EN PROCESO' // Mostrar el boton de rechazo si el estatus es 'EN PROCESO'
                ? Container(child: _buttonRechazo(context))
                : Container(),
            con.producto!.estatus == 'SUSPENDIDO'  // Mostrar el boton de rechazo si el estatus es 'SUSPENDIDO'
                ? Container(child: _buttonRechazo(context))
                : Container(),
            con.producto!.estatus == 'SIG. PROCESO'  // Mostrar botones adicionales si es estatus es ' SIG. PROCESO'
                ? Container(child: _buttons(context))
                : Container(),
          ]),
        ],
      ),
    );
  }

  Widget _textNewCot() {  // Widget que muestra el texto de instrucción del formulario
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 15, left: 20), // Maargen alrededor del texto
      child: Text(
        'Seleccione la determinación del producto', // Texto de instrucción
        style: TextStyle(
          color: Colors.black54,  //Color para el texto
          fontWeight: FontWeight.bold,  // Texto en negrita
          fontSize: 18,  // Tamaño de fuente
        ),
      ),
    );
  }

  Widget _buttonRechazo(BuildContext context) {  // Widget boton de rechazo
    return Container(
      margin: EdgeInsets.only(top: 5, right: 30, bottom: 10), // Margen alrededor del boton
      child: ElevatedButton(
        onPressed: () => con.rechazado(context),  // al presionar llama a la funcion rechazado del controlador
        style: ElevatedButton.styleFrom(  // Estilo del boton
          backgroundColor: Colors.red,  // Color de fondo rojo para el botón
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),  // Tamaño de relleno del boton
        ),
        child: Text(
          'RECHAZAR',  // Texto que aparece en el botón
          style: TextStyle(  // Estilo del texto
            fontSize: 20,  // Tamaño de fuente
            color: Colors.white,  // Color del texto
          ),
        ),
      ),
    );
  }

  Widget _buttonBack() {  // Widget de boton de regreso a la página anterior
    return SafeArea(  // Asegura que el widget no sea cubierto
      child: Container(
        margin: EdgeInsets.only(left: 20),  // Margen izquierdo para el botón
        child: IconButton(
            onPressed: () => Get.back(),  // Al presionar, vuelve a la página anterior
            icon: Icon(
              Icons.arrow_back_ios,  // Icono de flecha para regresar
              color: Colors.white,  // Color del icono
              size: 30,  // Tamaño del icono
            )
        ),
      ),
    );
  }

  Widget _buttons(BuildContext context) {  // Widget que agrupa los botones
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,  // Centra los botones
        children: [
          _buttonSelectPDF(),  // Boton para seleccinar PDF
          Container(  // Contenedor del botón de LIBERAR
            margin: EdgeInsets.only(left: 45, top: 20, bottom: 30),  // Margen alrededor del boton
            child: ElevatedButton(
              onPressed: () => con.liberar(context),  // Al presionar, llama al metodo liberar del controlador
              style: ElevatedButton.styleFrom(  // Estilo del boton
                  padding: EdgeInsets.all(15),  // Relleno del boton
                  backgroundColor: Colors.green), // Color del boton
              child: Text(
                'LIBERAR', // Texto dentro del botón
                style: TextStyle( // Estilo del texto
                    fontSize: 20,   // Tamaño de fuente
                    color: Colors.white  // Color del texto
                ),
              ),
            ),
          ),
          Container(  // Contenedor del boton retrabajo
            margin: EdgeInsets.only(left: 45, top: 20, bottom: 30), // Margen alrededor del botón
            child: ElevatedButton(
              onPressed: () => con.retrabajo(context), // Al presionar llama al metodo retrabajo del controlador
              style: ElevatedButton.styleFrom( // Estilo del botón
                  padding: EdgeInsets.all(15), // Relleno del boton
                  backgroundColor: Colors.orange),  // Color del boton
              child: Text(
                'RETRABAJO',  // Texto dentro del boton
                style: TextStyle(  // Estilo del texto
                    fontSize: 20,   // Tamaño de fuente
                    color: Colors.white  // Color del texto
                ),
              ),
            ),
          ),
          Container(  // Contenedor del botón RECHAZAR
            margin: EdgeInsets.only(left: 45, top: 20, bottom: 30),  // Margen alrededor del botón
            child: ElevatedButton(
              onPressed: () => con.rechazado(context),  // Llama al metodo rechazado del controlador
              style: ElevatedButton.styleFrom(  // Estilo del boton
                  padding: EdgeInsets.all(15), // Relleno del botón
                  backgroundColor: Colors.red),  // Color del botón
              child: Text(
                'RECHAZAR',  // Texto dentro del botón
                style: TextStyle(  // Estilo del texto
                    fontSize: 20,   // Tamaño de fuente
                    color: Colors.white  // Color de texto
                ),
              ),
            ),
          ),
        ],
      )
    ]);
  }

  Widget _buttonSelectPDF() {  // Widget para el boton de seleccionar PDF
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => con.selectPDF(),  // Al presionar, llama al método selectPDF del controlador
          child: Text('Reporte Dimensional'), // Texto del botón
        ),
        Obx(() => con.pdfFileName.value.isNotEmpty  // Verifica si ya se seleccionó un PDF
            ? Text('PDF seleccionado: ${con.pdfFileName.value}')  // Muestra el nombre del archivo PDF seleccionado debajo del boton
            : SizedBox.shrink()),
      ],
    );
  }
}
