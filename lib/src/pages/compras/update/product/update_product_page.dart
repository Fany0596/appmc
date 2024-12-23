import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/models/product.dart';
import 'package:maquinados_correa/src/pages/compras/update/product/update_product_controller.dart';

class UpdateProductPage extends StatelessWidget {
  Product? product;
  final UpdateProductPageController con = Get.put(UpdateProductPageController());

  UpdateProductPage({@required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx (() => SingleChildScrollView(
        child: Stack( // posiciona elementos uno sobre otro
        children: [
            _backGroundCover(context),
            _boxForm(context),
            _encabezado(context),
            _buttonBack(),
            _textAdd(context)
          ],
        ),
      )
    ),
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
            _materialesList(con.materiales),
            _textFielPrecio(),
            _textFielCantidad(),
            _textFieldUnid(),
            _textFielTotal(),
            _buttonSave(context)

          ],
        ),
    );
  }

  // Texto ingrese datos
  Widget _textNewCot() {
    return Text(
        'INGRESE LOS SIGUIENTES DATOS',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      //),
    );
  }
  Widget _textFieldUnid() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: DropdownButtonFormField<String>(
        icon: Icon(Icons.arrow_drop_down_circle,
          color: Colors.grey,),
        decoration: InputDecoration(
          hintText: 'Unidad',
          prefixIcon: Icon(Icons.horizontal_rule),
        ),
        items: [
          DropdownMenuItem(
            child: Text('Pza.'),
            value: 'Pza.',
          ),
          DropdownMenuItem(
            child: Text('Kg.'),
            value: 'Kg.',
          ),
          DropdownMenuItem(
            child: Text('Mt.'),
            value: 'Mt.',
          ),
        ],
        onChanged: (value) {
          con.selectedUnid.value = value!; // Actualizar el valor seleccionado
          con.unidController.text = value;
        },
      ),
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
  Widget _buttonSave(BuildContext context) {
    return Container(
      //width: double.infinity,
      margin: EdgeInsets.only(top: 5, right:30, bottom: 10 ),
      child: ElevatedButton(
        onPressed: () => con.updateProduct(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
        child: Text(
          'ACTUALIZAR',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }


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
          ]
      ),
    );
  }
  // imagen
  Widget _textAdd(BuildContext context){
    return SafeArea(
      child: Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top:70, bottom: 15),
        child: Column (
          children: [
            Icon(Icons.shopping_cart_outlined, size: 105),
            Text(
              'ARTÍCULO',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 26
              ),
            ),
          ],
        ),
      ),
    );

  }

  // lista vendedores

  Widget _materialesList (List<Materiales> materiales){
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        //margin: EdgeInsets.only(top: 10),
        child: DropdownButton(
          underline: Container(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.arrow_drop_down_circle,
              color: Colors.grey,
            ),
          ),
          elevation: 3,
          isExpanded: true,
          hint: Text(
            'Selecciona un material',
            style: TextStyle(
                fontSize: 16
            ),
          ),
          items: _dropDownItems(materiales),
          value: con.idMateriales.value == '' ? null : con.idMateriales.value,
          onChanged: (option) {
            print('Opcion seleccionada ${option}');
            con.idMateriales.value = option.toString();
          },
        ),
      );
    }
  List<DropdownMenuItem<String>> _dropDownItems (List<Materiales> materiales){

    List<DropdownMenuItem<String>> list =[];
    materiales.forEach((materiales) {
      list.add(DropdownMenuItem(
        child: Text(materiales.name ?? ''),
        value: materiales.id,
      ));
    });
    return list;
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
        margin: EdgeInsets.only(left: 20),
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

