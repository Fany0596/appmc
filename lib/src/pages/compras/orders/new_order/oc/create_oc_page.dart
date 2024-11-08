import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:maquinados_correa/src/models/Client.dart';
import 'package:maquinados_correa/src/models/comprador.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/provedor.dart';
import 'package:maquinados_correa/src/models/vendedor.dart';
import 'package:maquinados_correa/src/pages/compras/orders/new_order/oc/create_oc_controller.dart';

class OcPage extends StatelessWidget {

  OcPageController con = Get.put(OcPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx (() => SingleChildScrollView(
        child: Stack( // posiciona elementos uno sobre otro
          children: [
            _backGroundCover(context),
            _boxForm(context),
            _encabezado(context),
            _textAdd(context)
          ],
        ),
      )),
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
          _textNewCot(),
          _textFielNumber(),
          _cotizacionList(con.cotizacion),
          _provedorList(con.provedor),
          _compradorList(con.comprador),
          _textFielSoli(context),
          _textFielEnt(context),
          _textFieldTipo(),
          _textFieldMoneda(),
          _textFieldCondiciones(),
          _textFieldComent(),
          _buttonSave(context),
        ],
      ),
    );
  }

  // Texto ingrese datos
  Widget _textNewCot() {
    return
      //Container(
      //margin: EdgeInsets.only(top: 20, bottom: 5),
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
  // Texto numero
  Widget _textFielNumber() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
          controller: con.numberController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Número de O.C.', //texto fondo
            prefixIcon: Icon(Icons.numbers), //icono
          ),
      ),
    );
  }
  Widget _textFieldCondiciones() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: DropdownButtonFormField<String>(
        icon: Icon(Icons.arrow_drop_down_circle,
          color: Colors.grey,),
        decoration: InputDecoration(
          hintText: 'Condiciones de pago',
          prefixIcon: Icon(Icons.credit_card),
        ),
        items: [
          DropdownMenuItem(
            child: Text('Crédito'),
            value: 'Crédito',
          ),
          DropdownMenuItem(
            child: Text('Contado'),
            value: 'Contado',
          ),
          DropdownMenuItem(
            child: Text('50 % Anticipo y 50% despues de la entrega del material.'),
            value: '50 % Anticipo y 50% despues de la entrega del material.',
          ),
        ],
        onChanged: (value) {
          con.selectedCondition.value = value!; // Actualizar el valor seleccionado
          con.condicionesController.text = value;
        },
      ),
    );
  }
  Widget _textFieldMoneda() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: DropdownButtonFormField<String>(
        icon: Icon(Icons.arrow_drop_down_circle,
          color: Colors.grey,),
        decoration: InputDecoration(
          hintText: 'Moneda',
          prefixIcon: Icon(Icons.monetization_on_outlined),
        ),
        items: [
          DropdownMenuItem(
            child: Text('MXN'),
            value: 'MXN',
          ),
          DropdownMenuItem(
            child: Text('USD'),
            value: 'USD',
          ),
        ],
        onChanged: (value) {
          con.selectedMoneda.value = value!; // Actualizar el valor seleccionado
          con.monedaController.text = value;
        },
      ),
    );
  }

  Widget _textFielEnt(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      //margin: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          _selectDat(context);
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: con.entController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              hintText: 'Selecciona una fecha de entrega',
              hintStyle: TextStyle(fontSize: 14),
              prefixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDat(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      con.entController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }
  Widget _textFielSoli(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      //margin: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          _selectData(context);
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: con.soliController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              hintText: 'Selecciona una fecha de solicitud',
              hintStyle: TextStyle(fontSize: 14),
              prefixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      con.soliController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }
  // boton guardar
  Widget _buttonSave(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        con.createOc(context);
      },
      child: Text('GUARDAR'),
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
  Widget _textFieldTipo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: DropdownButtonFormField<String>(
        icon: Icon(Icons.arrow_drop_down_circle,
          color: Colors.grey,),
        decoration: InputDecoration(
          hintText: 'Tipo de compra',
          prefixIcon: Icon(Icons.turned_in_not),
        ),
        items: [
          DropdownMenuItem(
            child: Text('Acero'),
            value: 'Acero',
          ),
          DropdownMenuItem(
            child: Text('Insumo'),
            value: 'Insumo',
          ),
        ],
        onChanged: (value) {
          con.selectedTipo.value = value!; // Actualizar el valor seleccionado
          con.tipoController.text = value;
        },
      ),
    );
  }
  Widget _compradorList (List<Comprador> comprador){
    return Container(
      padding: EdgeInsets.only(top: 13, bottom: 0, left: 15, right: 10),
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
          'Selecciona un comprador',
          style: TextStyle(
              fontSize: 16
          ),
        ),
        items: _dropDownItemscc(comprador),
        value: con.idComprador.value == '' ? null : con.idComprador.value,
        onChanged: (option) {
          print('Opcion seleccionada ${option}');
          con.idComprador.value = option.toString();
        },
      ),
    );
  }
  List<DropdownMenuItem<String>> _dropDownItemscc (List<Comprador> comprador){

    List<DropdownMenuItem<String>> list =[];
    comprador.forEach((comprador) {
      list.add(DropdownMenuItem(
        child: Text(comprador.name ?? ''),
        value: comprador.id,
      ));
    });
    return list;
  }
  // imagen
  Widget _textAdd(BuildContext context){
    return SafeArea(
      child: Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top:70),
        child: Column (
          children: [
            Icon(Icons.shopping_basket_outlined, size: 105),
            Text(
              'NUEVA O.C.',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _cotizacionList (List<Cotizacion> cotizacion){
    return Obx(() => Container(
      padding: EdgeInsets.only(top: 13, bottom: 0, left: 15, right: 10),
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
          'Selecciona un número de cotización',
          style: TextStyle(
              fontSize: 16
          ),
        ),
        items: _dropDownItemsc(cotizacion),
        value: con.idCotizaciones.value == '' ? null : con.idCotizaciones.value,
        onChanged: (option) {
          print('Opcion seleccionada ${option}');
          con.idCotizaciones.value = option.toString();
        },
      ),
    ));
  }
  List<DropdownMenuItem<String>> _dropDownItemsc (List<Cotizacion> cotizacion){

    List<DropdownMenuItem<String>> list =[];
    cotizacion.forEach((cotizacion) {
      list.add(DropdownMenuItem(
        child: Text(cotizacion.number ?? ''),
        value: cotizacion.id,
      ));
    });
    return list;
  }
  Widget _textFieldComent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
        controller: con.comentController,
        keyboardType: TextInputType.text,
        maxLines: 3,
        decoration: InputDecoration(
            hintText: 'Comentarios',
            prefixIcon: Container(
                child: Icon(Icons.description)
            )
        ),
      ),
    );
  }
  Widget _provedorList (List<Provedor> provedor){
    return Container(
      padding: EdgeInsets.only(top: 13, bottom: 0, left: 15, right: 10),
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
          'Selecciona un provedor',
          style: TextStyle(
              fontSize: 16
          ),
        ),
        items: _dropDownItems(provedor),
        value: con.idProvedor.value == '' ? null : con.idProvedor.value,
        onChanged: (option) {
          print('Opcion seleccionada ${option}');
          con.idProvedor.value = option.toString();
        },
      ),
    );
  }
  List<DropdownMenuItem<String>> _dropDownItems (List<Provedor> provedor){

    List<DropdownMenuItem<String>> list =[];
    provedor.forEach((provedor) {
      list.add(DropdownMenuItem(
        child: Text(provedor.name ?? ''),
        value: provedor.id,
      ));
    });
    return list;
  }


}

