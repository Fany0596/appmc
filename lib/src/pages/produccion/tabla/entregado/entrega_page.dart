import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/pages/produccion/tabla/entregado/entrega_controller.dart';

class EntregaPage extends StatelessWidget {
  Producto? producto;
  final EntregaController con = Get.put(EntregaController());

  EntregaPage({@required this.producto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // posiciona elementos uno sobre otro
                children: [
                  _backGroundCover(context),
                ]),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // posiciona elementos uno sobre otro
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
    return Text(
      'DETERMINACIÓN DEL PRODUCTO',
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _textNewCot(),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            con.producto!.estatus == 'LIBERADO'
                ? Container(child: _buttons(context))
                : Container(),
          ]),
        ],
      ),
    );
  }

  Widget _textNewCot() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 15, left: 20),
      child: Text(
        'Seleccione la determinación del producto',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    return Column( children: [
      Divider(height: 1, color: Colors.white),
      Row(
        children: [
        Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 20, bottom: 5, left: 50, right: 50),
              child: GestureDetector(
                onTap: () {
                  _selectDat(context);
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: con.entregaController,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      hintText: 'Fecha de entrega',
                      hintStyle: TextStyle(fontSize: 14),
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(child:_textFieldEfec()),
        ],
      ),
      Container(
        margin: EdgeInsets.only(left: 5, top: 20, bottom: 30),
        child: ElevatedButton(
          onPressed: () => con.entregado(context),
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(15), backgroundColor: Colors.green),
          child: Text(
            'ENTREGADO',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      )
    ]);
  }
  Widget _textFieldEfec() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 5, left: 50, right: 50),
      child: DropdownButtonFormField<String>(
        alignment: Alignment.center,
        icon: Icon(Icons.arrow_drop_down_circle),
        decoration: InputDecoration(
          hintText: 'Producción fuera de tiempo',
          hintStyle: TextStyle(fontSize: 14),
          border: OutlineInputBorder(),
          //prefixIcon: Icon(Icons.horizontal_rule),
        ),
        items: [
          DropdownMenuItem(
            child: Text('Si'),
            value: 'Si',
          ),
          DropdownMenuItem(
            child: Text('No'),
            value: 'No',
          ),
        ],
        onChanged: (value) {
          con.selectedEfec.value = value!; // Actualizar el valor seleccionado
          con.efectividadController.text = value;
        },
      ),
    );
  }
  Widget _buttonBack() {
    return SafeArea(
      // deja espacio de la barra del telefono
      child: Container(
        margin: EdgeInsets.only(left: 20),
        child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 30,
            )),
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
      con.entregaController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }
}
