import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          Row(
            children: [
              Expanded(flex: 2, child: _textFielArticulo1()),
              SizedBox(width: 10),
              Expanded(flex: 4, child: _textFielDescr1()),
              SizedBox(width: 10),
              Expanded(flex: 1, child: _parte1()),
              SizedBox(width: 10),
              Expanded(flex: 1, child: _textFielCantidad1()),
              SizedBox(width: 10),
              Expanded(flex: 1, child: _materialesList1()),
              SizedBox(width: 10),
            ],
          ),
          Row(
            children: [
              Expanded(flex: 2, child: _textFielArticulo()),
              SizedBox(width: 10),
              Expanded(flex: 4, child: _textFielDescr()),
              SizedBox(width: 10),
              Expanded(flex: 1, child: _parte()),
              SizedBox(width: 10),
              Expanded(flex: 1, child: _textFielCantidad()),
              SizedBox(width: 10),
              Expanded(flex: 1, child: _materialesList(con.materiales)),
              SizedBox(width: 10),
            ],
          ),
          _buttonSelectPDF(),
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
    return TextField(
        controller: con.articuloController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Articulo',
          border: OutlineInputBorder(),
        ),
    );
  }
  Widget _textFielArticulo1() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Text('Articulo',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
  Widget _textFielDescr1() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text('Descripción',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
  Widget _textFielDescr() {
    return TextField(
        controller: con.descrController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Descripción',
          border: OutlineInputBorder(),
        ),
      enabled: false,
    );
  }
  Widget _materialesList1() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text('Material',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,

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
            color: Colors.black,
          ),
        ),
        elevation: 3,
        isExpanded: true,
        hint: Text(
          'Material',
          style: TextStyle(
            fontSize: 16,
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
  Widget _textFielCantidad1() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text('Cantidad',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
  Widget _textFielCantidad() {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextField(
        controller: con.cantidadController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Cantidad',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
  Widget _parte1() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text('No. Parte/Plano',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
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
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buttonSelectPDF() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => con.selectPDF(),
          child: Text('Seleccionar PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey
          ),
        ),
        Obx(() => con.planopdfName.value.isNotEmpty
            ? Text('PDF seleccionado: ${con.planopdfName.value}')
            : SizedBox.shrink()),
      ],
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
