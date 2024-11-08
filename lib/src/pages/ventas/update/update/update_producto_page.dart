import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/pages/ventas/update/update/update_producto_controller.dart';

class UpdateProductoPage extends StatelessWidget {


  final UpdateProductoPageController con = Get.put(UpdateProductoPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: //Obx (() =>
          SingleChildScrollView(
        child: Stack( // posiciona elementos uno sobre otro
        children: [
            _backGroundCover(context),
            _boxForm(context),
            _buttonBack(),
            _encabezado(context)
          ],
        ),
      )
   // ),
    );
  }

  // fondo gris
  Widget _backGroundCover(BuildContext context){ //build context para porcentaje
    return Container(
        width: double.infinity,  //ancho de imagen
        height: MediaQuery.of(context).size.height *0.38, //alto de imagen
        color: Colors.grey
    );
  }
  // caja de datos
  Widget _boxForm(BuildContext context) {
    return Container(
      //height: MediaQuery.of(context).size.height*0.70,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.29, left: 30, right: 20),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            _textNewCot() ,
            _textFieldDescription(),
            _textFielPrecio(),
            _textFielCantidad(),
            _textFielTotal(),
            _buttonSave(context)

          ],
        ),
    );
  }

  // Texto ingrese datos
  Widget _textNewCot() {
    return
      //Container(
     // margin: EdgeInsets.only(top: 20, bottom: 15),
      //child:
    Text(
        'INGRESE LOS SIGUIENTES DATOS',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      //),
    );
  }

  Widget _textFieldDescription() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
        controller: con.descrController,
        keyboardType: TextInputType.text,
        maxLines: 3,
        decoration: InputDecoration(
            hintText: 'Descripción',
            prefixIcon: Container(
                child: Icon(Icons.description)
            )
        ),
      ),
    );
  }


  // boton guardar
  Widget _buttonSave(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        con.createProducto(context);
      },
      child: Text('GUARDAR'),
    );
  }
  //   return Container(
  //     width: double.infinity,
  //     margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
  //     child: ElevatedButton(
  //         onPressed: () {
  //           con.createProducto(context);
  //         },
  //         style: ElevatedButton.styleFrom(
  //             padding: EdgeInsets.symmetric(vertical: 15)
  //         ),
  //         child: Text (
  //           'GUARDAR',
  //           style: TextStyle(
  //             color: Colors.white,
  //           ),
  //         )
  //     ),
  //   );
  // }

  Widget _encabezado(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25,left: 10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //alignment: Alignment.topLeft,
          children: [Image.asset(
            'assets/img/LOGO1.png',
            width: 100, //ancho de imagen
            height: 100, //alto de imagen
          ),
            SizedBox(width: 10),
            Text(
              '     EDITAR PRODUCTO',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ]
      ),
    );
  }

  Widget _textFielPrecio() {
      return Container(
        margin: EdgeInsets.only(top: 1, bottom: 1, left: 10, right: 10),
        child: TextField(
            controller: con.precioController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Precio Unitario', //texto fondo
              prefixIcon: Icon(Icons.attach_money), //icono
            )
        ),
      );
  }
  Widget _textFielCantidad() {
    return Container(
      margin: EdgeInsets.only(top: 1, bottom: 1, left: 10, right: 10),
      child: TextField(
          controller: con.cantidadController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Cantidad', //texto fondo
            prefixIcon: Icon(Icons.numbers), //icono
          )
      ),
    );
  }
  Widget _textFielTotal() {
    return Container(
      margin: EdgeInsets.only(top: 1, bottom: 1, left: 10, right: 10),
      child: TextField(
          controller: con.totalController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d*\.?\d{0,2}'), // Acepta hasta dos decimales
            ),
          ],
          decoration: InputDecoration(
            hintText: 'Total', //texto fondo
            prefixIcon: Icon(Icons.attach_money_rounded), //icono
          )
      ),
    );
  }
  Widget _buttonBack() {
    return SafeArea( // deja espacio de la barra del telefono
      child: Container(
        margin: EdgeInsets.only(left: 20, top: 120),
        child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 30,
            )
        ),
      ),
    );
  }
}

