import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/pages/ventas/update/price/pricem_producto_controller.dart';

class PriceProductoPage extends StatelessWidget {

  final PriceProductoPageController con = Get.put(PriceProductoPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx (() => SingleChildScrollView(
        child: Stack( // posiciona elementos uno sobre otro
        children: [
            _backGroundCover(context),
            _boxForm(context),
            _buttonBack(),
            _encabezado(context),
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
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.39, left: 30, right: 20),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            _textNewCot() ,
            _materialesList(con.materiales),
            _textFielPrecio(),
            _buttonSave(context)

          ],
        ),
    );
  }

  // Texto ingrese datos
  Widget _textNewCot() {
    return Container(
      alignment: Alignment.center,
     margin: EdgeInsets.only(bottom: 30),
      child: Text(
          'INGRESE LOS SIGUIENTES DATOS',
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        //),
      ),
    );
  }


  // boton guardar
  Widget _buttonSave(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        con.createProducto(context);
      },
      child: Text('GUARDAR',
      style: TextStyle(
        fontSize: 18
      ),),
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
            Text(
              '     PRECIO DE MATERIAL',
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

  Widget _materialesList (List<Materiales> materiales){
      return Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.symmetric(horizontal: 20),
        //margin: EdgeInsets.only(top: 10),
        child: DropdownButton(
          underline: Container(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.arrow_drop_down_circle,
            ),
          ),
          elevation: 3,
          isExpanded: true,
          hint: Text(
            'Selecciona un material',
            style: TextStyle(
                fontSize: 20,
              color: Colors.black
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
        margin: EdgeInsets.only(top: 1, bottom: 40, left: 10, right: 10),
        child: TextField(
            controller: con.pmaterialController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Precio Total', //texto fondo
              hintStyle: TextStyle(
                fontSize: 20,
              ),
              prefixIcon: Icon(Icons.attach_money), //icono
            )
        ),
      );
  }
  // boton de regreso
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

