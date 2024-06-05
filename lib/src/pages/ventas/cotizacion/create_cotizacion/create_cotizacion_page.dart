import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:maquinados_correa/src/models/Client.dart';
import 'package:maquinados_correa/src/models/vendedor.dart';
import 'package:maquinados_correa/src/pages/ventas/cotizacion/create_cotizacion/create_cotizacion_controller.dart';

class CotizacionPage extends StatelessWidget {

  CotizacionPageController con = Get.put(CotizacionPageController());

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
    return
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
            hintText: 'Número de cotizacion', //texto fondo
            prefixIcon: Icon(Icons.numbers), //icono
          ),
      ),
    );
  }
  Widget _textFielEnt() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
        controller: con.entController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Tiempo de entrega', //texto fondo
          prefixIcon: Icon(Icons.date_range), //icono
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
              '     MAQUINADOS CORREA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ]
      ),
    );
  }
  // imagen
  Widget _textAdd(BuildContext context){
    return SafeArea(
      child: Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top:70),
        child: Column (
          children: [
            Icon(Icons.new_label_outlined, size: 105),
            Text(
              'NUEVA COTIZACION',
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

  // imagenes
  Widget _cardImage(BuildContext context, File? imageFile, int numberFile){
    return GestureDetector(
          onTap: () => con.showAlertDialog(context, numberFile) ,
          child: Card(
           child: Container(
                padding: EdgeInsets.all(10),
                height: 70,
                width: MediaQuery.of(context).size.width * 0.18,
                child: imageFile != null
                ? Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                )
                : Image (
                  image:AssetImage('assets/img/pdf.png'),
                )
            ),
          ),
    );
  }
  Widget _textFieldCondiciones() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
        controller: con.condicionesController,
        keyboardType: TextInputType.text,
        maxLines: 2,
        decoration: InputDecoration(
            hintText: 'Condiciones de pago',
            prefixIcon: Container(
                child: Icon(Icons.credit_card)
            )
        ),
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
            prefixIcon: Container(
                child: Icon(Icons.percent_outlined)
            )
        ),
      ),
    );
  }
  // lista vendedores

  Widget _vendedoresList (List<Vendedores> vendedores){
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
            style: TextStyle(
                fontSize: 16
            ),
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
  List<DropdownMenuItem<String>> _dropDownItems (List<Vendedores> vendedores){

    List<DropdownMenuItem<String>> list =[];
    vendedores.forEach((vendedores) {
      list.add(DropdownMenuItem(
        child: Text(vendedores.name ?? ''),
        value: vendedores.id,
      ));
    });
    return list;
  }

  Widget _clientesList (List<Clientes> clientes){
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
          style: TextStyle(
              fontSize: 16
          ),
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
  List<DropdownMenuItem<String>> _dropDownItemsc (List<Clientes> clientes){

    List<DropdownMenuItem<String>> list =[];
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
            )
        ),
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
          )
      ),
    );
  }
  Widget _textFieldPhone() {
    return Container(
      margin: EdgeInsets.only(top: 1, bottom: 5, left: 10, right: 10),
      child: TextField(
        controller: con.telefonoController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
            hintText: 'Telefono',
            prefixIcon: Icon(Icons.phone)
        ),
      ),
    );
  }

}

