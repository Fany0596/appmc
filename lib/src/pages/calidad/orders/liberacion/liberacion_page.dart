import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/pages/calidad/orders/liberacion/liberacion_controller.dart';

class LiberacionPage extends StatelessWidget {
  Producto? producto;
  final LiberacionController con = Get.put(LiberacionController());

  LiberacionPage({@required this.producto});

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
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            con.producto!.estatus == 'EN ESPERA'
                ? Container(child: _buttonRechazo(context))
                : Container(),
            con.producto!.estatus == 'EN PROCESO'
                ? Container(child: _buttonRechazo(context))
                : Container(),
            con.producto!.estatus == 'SUSPENDIDO'
                ? Container(child: _buttonRechazo(context))
                : Container(),
            con.producto!.estatus == 'SIG. PROCESO'
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

  Widget _buttonRechazo(BuildContext context) {
    return Container(
      //width: double.infinity,
      margin: EdgeInsets.only(top: 5, right: 30, bottom: 10),
      child: ElevatedButton(
        onPressed: () => con.rechazado(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
        child: Text(
          'RECHAZAR',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
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

  Widget _buttons(BuildContext context) {
    return Column(children: [
      Divider(height: 1, color: Colors.white),
      Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buttonSelectPDF(),
            Container(
              margin: EdgeInsets.only(left: 45, top: 20, bottom: 30),
              child: ElevatedButton(
                onPressed: () => con.liberar(context),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15), backgroundColor: Colors.green),
                child: Text(
                  'LIBERAR',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 45, top: 20, bottom: 30),
              child: ElevatedButton(
                onPressed: () => con.retrabajo(context),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15),
                    backgroundColor: Colors.orange),
                child: Text(
                  'RETRABAJO',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 45, top: 20, bottom: 30),
              child: ElevatedButton(
                onPressed: () => con.rechazado(context),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15), backgroundColor: Colors.red),
                child: Text(
                  'RECHAZAR',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        )
      ])
    ]);
  }

  Widget _buttonSelectPDF() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => con.selectPDF(),
          child: Text('Seleccionar PDF'),
        ),
        Obx(() => con.pdfFileName.value.isNotEmpty
            ? Text('PDF seleccionado: ${con.pdfFileName.value}')
            : SizedBox.shrink()),
      ],
    );
  }
}
