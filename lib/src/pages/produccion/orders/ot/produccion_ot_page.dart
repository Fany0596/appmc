import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/pages/produccion/orders/ot/produccion_ot_controller.dart';

class ProduccionOtPage extends StatelessWidget {
  Producto? producto;
  final ProduccionOtController con = Get.put(ProduccionOtController());

  ProduccionOtPage({@required this.producto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Obx (() =>  SingleChildScrollView(
      child: Stack(
        children: [
        Column(
        crossAxisAlignment: CrossAxisAlignment.start, // posiciona elementos uno sobre otro
        children: [
          _backGroundCover(context),
        ]),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // posiciona elementos uno sobre otro
             children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: _encabezado(),
                ),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 1),
                 child: _buttonBack(),
               ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120),
                  child: _textArticulo(),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _boxForm(context),
                ),
              ],
            ),
        ],
      ),
      ),
       ),
    );
  }

  Widget _backGroundCover(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.28,
      color: Colors.grey,
    );
  }

  Widget _encabezado() {
    return Row(
      children: [
        Image.asset(
          'assets/img/LOGO1.png',
          width: 55,
          height: 55,
        ),
        const SizedBox(width: 10),
        Text(
          'MAQUINADOS CORREA',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _textArticulo() {
    return
        Text(
          'ASIGNACIÓN DE ARTICULO',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.black,
          ),

    );
  }

  Widget _boxForm(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(0, 0.085),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textNewCot(),
          _textFielArticulo(),
          _parte(),
          //_textFielPedido(),
          _textFielCantidad(),
          _materialesList(con.materiales),
          _textFielPrecio(),
          _textFielTotal(),
          //_getDatePickerEnabled(context),
          //_entrega(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              con.producto!.estatus == 'POR ASIGNAR'
                  ? Container(
              child: _buttonSave(context))
                  : Container(),
              con.producto!.estatus == 'POR ASIGNAR'
                  ? Container(
              child: _buttonCancel(context))
              : Container(),
              con.producto!.estatus == 'CANCELADO'
                  ? Container(
                  child: _buttonSave(context))
                  : Container(),
              con.producto!.estatus == 'EN ESPERA'
                  ? Container(
                  child: _buttonCancel(context))
                  : Container(),
            ],
          ),

        ],
      ),
    );
  }

  Widget _textNewCot() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 15, left: 20),
      child: Text(
        'INGRESE LOS SIGUIENTES DATOS',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _textFielArticulo() {
    //con.articuloController.text = producto?.articulo ?? '';
    return Container(
      margin: EdgeInsets.all(10),
      child:TextField(
        controller: con.articuloController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Articulo',
          prefixIcon: Icon(Icons.add_circle),
        ),
      ),
    );
  }

  Widget _materialesList(List<Materiales> materiales) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
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
            fontSize: 16,
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

  List<DropdownMenuItem<String>> _dropDownItems(List<Materiales> materiales) {
    List<DropdownMenuItem<String>> list = [];
    materiales.forEach((materiales) {
      list.add(
        DropdownMenuItem(
          child: Text(materiales.name ?? ''),
          value: materiales.id,
        ),
      );
    });
    return list;
  }

  Widget _textFielCantidad() {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextField(
        controller: con.cantidadController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Cantidad',
          prefixIcon: Icon(Icons.numbers),
        ),
      ),
    );
  }

  Widget _parte() {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextField(
        controller: con.parteController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'No. Parte',
          prefixIcon: Icon(Icons.list_outlined),
        ),
      ),
    );
  }

  Widget _textFielTotal() {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextField(
        controller: con.totalController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d{0,2}'),
          ),
        ],
        decoration: InputDecoration(
          hintText: 'Total',
          prefixIcon: Icon(Icons.attach_money_rounded),
        ),
      ),
    );
  }

  Widget _textFielPrecio() {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextField(
        controller: con.precioController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Precio Unitario',
          prefixIcon: Icon(Icons.attach_money),
        ),
      ),
    );
  }

  Widget _buttonSave(BuildContext context) {
    return Container(
      //width: double.infinity,
      margin: EdgeInsets.only(top: 5, right:30, bottom: 10 ),
      child: ElevatedButton(
        onPressed: () => con.updated(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
        child: Text(
          'ASIGNAR',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  Widget _buttonCancel(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, left:30, bottom: 10 ),
      child: ElevatedButton(
        onPressed: () => con.cancelar(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
        child: Text(
          'CANCELAR',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
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
