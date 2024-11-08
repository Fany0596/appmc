import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/product.dart';
import 'package:maquinados_correa/src/pages/compras/orders/product/compras_product_controller.dart';

class ComprasProductPage extends StatelessWidget {
  Product? product;
  final ComprasProductController con = Get.put(ComprasProductController());

  ComprasProductPage({@required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body:   SingleChildScrollView(
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
          'RECEPCIÓN DE ARTICULO',
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
          _materialesList(),
          _textFielCantidad(),
          _textFielRecep(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              con.product!.estatus == 'SOLICITADO'
                  ? Container(
              child: _buttonSave(context))
                  : Container(),
              con.product!.estatus == 'SOLICITADO'
                  ? Container(
              child: _buttonCancel(context))
              : Container(),
              con.product!.estatus == 'CANCELADO'
                  ? Container(
                  child: _buttonSave(context))
                  : Container(),
              con.product!.estatus == 'RECIBIDO'
                  ? Container(
                  child: _buttonSave(context))
                  : Container(),
              con.product!.estatus == 'RECIBIDO'
                  ? Container(
                  child:  _buttonCancel(context))
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
        controller: con.descrController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Articulo',
          prefixIcon: Icon(Icons.add_circle),
        ),
        enabled: false,
      ),
    );
  }

  Widget _materialesList() {
    return Container(
      margin: EdgeInsets.all(10),
      child:TextField(
        controller: con.nameController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Material',
          prefixIcon: Icon(Icons.egg_alt),
        ),
      ),
    );
  }

  Widget _textFielCantidad() {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextField(
        controller: con.pedidoController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Cantidad recibida',
          prefixIcon: Icon(Icons.numbers),
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
          'RECIBIDO',
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
  Widget _textFielRecep(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      //margin: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          _selectDat(context);
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: con.recepController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              hintText: 'Selecciona una fecha de recepción',
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
      con.recepController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }
}
