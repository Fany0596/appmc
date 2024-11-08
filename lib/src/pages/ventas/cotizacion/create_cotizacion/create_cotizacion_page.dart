import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:maquinados_correa/src/models/Client.dart';
import 'package:maquinados_correa/src/models/vendedor.dart';
import 'package:maquinados_correa/src/pages/ventas/cotizacion/create_cotizacion/create_cotizacion_controller.dart';

class CotizacionPage extends StatelessWidget {
  CotizacionPageController con = Get.put(CotizacionPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => SingleChildScrollView(
            child: Stack(
              // posiciona elementos uno sobre otro
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
  Widget _backGroundCover(BuildContext context) {
    //build context para porcentaje
    return Container(
        width: double.infinity, //ancho de imagen
        height: MediaQuery.of(context).size.height * 0.38, //alto de imagen
        color: Colors.grey);
  }

  // caja de datos
  Widget _boxForm(BuildContext context) {
    return Container(
      //height: MediaQuery.of(context).size.height*0.70,
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.29, left: 30, right: 20),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _textNewCot(),
          _textFielNumber(),
          _textFielFecha(context),
          _textFieldReq(),
          _textFielEnt(),
          _clientesList(con.clientes),
          _vendedoresList(con.vendedores),
          _textFieldCondiciones(),
          _textFieldDescuento(),
          _textContact(),
          _textFielName(),
          _textFielCorreo(),
          _textFieldPhone(),
          _buttonSave(context),
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

  // Texto numero
  Widget _textFielNumber() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
        controller: con.numberController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Número de cotizacion', //texto fondo
          prefixIcon: Icon(Icons.numbers), //icono
        ),
      ),
    );
  }

  Widget _textFielFecha(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: GestureDetector(
        onTap: () {
          _selectDat(context);
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: con.fechaController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              hintText: 'Fecha',
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
      con.fechaController.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  Widget _textFielEnt() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
        controller: con.entController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Tiempo de entrega', //texto fondo
          prefixIcon: Icon(Icons.timer), //icono
        ),
      ),
    );
  }

  // boton guardar
  Widget _buttonSave(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        con.createCotizacion(context);
      },
      child: Text('GUARDAR'),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25, left: 10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //alignment: Alignment.topLeft,
          children: [
            Image.asset(
              'assets/img/LOGO1.png',
              width: 100, //ancho de imagen
              height: 100, //alto de imagen
            ),
            SizedBox(width: 10),
          ]),
    );
  }

  // imagen
  Widget _textAdd(BuildContext context) {
    return SafeArea(
      child: Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 70),
        child: Column(
          children: [
            Icon(Icons.new_label_outlined, size: 105),
            Text(
              'NUEVA COTIZACION',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textFieldCondiciones() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: DropdownButtonFormField<String>(
        icon: Icon(
          Icons.arrow_drop_down_circle,
          color: Colors.grey,
        ),
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
            child: Text('50 % Anticipo y 50% despues de la entrega.'),
            value: '50 % Anticipo y 50% despues de la entrega.',
          ),
        ],
        onChanged: (value) {
          con.selectedCondition.value =
              value!; // Actualizar el valor seleccionado
          con.condicionesController.text = value;
        },
      ),
    );
  }

  Widget _textFieldReq() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
        controller: con.reqController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            hintText: 'Requerimiento',
            prefixIcon: Container(child: Icon(Icons.quiz_outlined))),
      ),
    );
  }

  Widget _textFieldDescuento() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
        controller: con.descuentoController,
        keyboardType: TextInputType.text,
        maxLines: 2,
        decoration: InputDecoration(
            hintText: 'Descuento',
            prefixIcon: Container(child: Icon(Icons.percent_outlined))),
      ),
    );
  }

  // lista vendedores
  Widget _vendedoresList(List<Vendedores> vendedores) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 35),
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
          'Selecciona un vendedor',
          style: TextStyle(fontSize: 16),
        ),
        items: _dropDownItems(vendedores),
        value: con.idVendedores.value == '' ? null : con.idVendedores.value,
        onChanged: (option) {
          print('Opcion seleccionada ${option}');
          con.idVendedores.value = option.toString();
        },
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropDownItems(List<Vendedores> vendedores) {
    List<DropdownMenuItem<String>> list = [];
    vendedores.forEach((vendedores) {
      list.add(DropdownMenuItem(
        child: Text(vendedores.name ?? ''),
        value: vendedores.id,
      ));
    });
    return list;
  }

  Widget _clientesList(List<Clientes> clientes) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 35),
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
          'Selecciona un cliente',
          style: TextStyle(fontSize: 16),
        ),
        items: _dropDownItemsc(clientes),
        value: con.idClientes.value == '' ? null : con.idClientes.value,
        onChanged: (option) {
          print('Opcion seleccionada ${option}');
          con.idClientes.value = option.toString();
        },
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropDownItemsc(List<Clientes> clientes) {
    List<DropdownMenuItem<String>> list = [];
    clientes.forEach((vendedores) {
      list.add(DropdownMenuItem(
        child: Text(vendedores.name ?? ''),
        value: vendedores.id,
      ));
    });
    return list;
  }

  Widget _textContact() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 1, left: 10, right: 10),
      child: Text(
        'PERSONA DE CONTACTO',
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _textFielName() {
    return Container(
      margin: EdgeInsets.only(top: 1, bottom: 1, left: 10, right: 10),
      child: TextField(
          controller: con.nombreController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Nombre', //texto fondo
            prefixIcon: Icon(Icons.perm_identity), //icono
          )),
    );
  }

  Widget _textFielCorreo() {
    return Container(
      margin: EdgeInsets.only(top: 1, bottom: 1, left: 10, right: 10),
      child: TextField(
          controller: con.correoController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Correo', //texto fondo
            prefixIcon: Icon(Icons.email_outlined), //icono
          )),
    );
  }

  Widget _textFieldPhone() {
    return Container(
      margin: EdgeInsets.only(top: 1, bottom: 5, left: 10, right: 10),
      child: TextField(
        controller: con.telefonoController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
            hintText: 'Telefono', prefixIcon: Icon(Icons.phone)),
      ),
    );
  }
}
