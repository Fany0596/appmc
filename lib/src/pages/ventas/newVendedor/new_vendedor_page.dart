import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:maquinados_correa/src/pages/ventas/newVendedor/new_vendedor_controller.dart';

class VendedoresPage extends StatelessWidget {

  VendedoresPageController con = Get.put(VendedoresPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack( // posiciona elementos uno sobre otro
        children: [
          _backGroundCover(context),
          _boxForm(context),
          _buttonBack(),
          _encabezado(context),
          _textAdd(context)
        ],
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
      height: MediaQuery.of(context).size.height*0.50,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.35, left: 50, right: 40),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black54,
                blurRadius: 15,
                offset: Offset (0,0.085)
            )
          ]
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _textNewCot() ,
            _textFielNombre(),
            _textFielNumber(),
            _textFielCorreo(),
            _buttonSave(context),

          ],
        ),
      ),
    );
  }

  // Texto ingrese datos
  Widget _textNewCot() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
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
  // Texto numero
  Widget _textFielNombre() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
          controller: con.nameController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Nombre del vendedor', //texto fondo
            prefixIcon: Icon(Icons.perm_identity), //icono
          )
      ),
    );
  }
  Widget _textFielNumber() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
          controller: con.numberController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Telefono', //texto fondo
            prefixIcon: Icon(Icons.phone_enabled_outlined), //icono
          )
      ),
    );
  }
  Widget _textFielCorreo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
          controller: con.emailController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Correo', //texto fondo
            prefixIcon: Icon(Icons.email), //icono
          )
      ),
    );
  }


  // boton guardar
  Widget _buttonSave(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ElevatedButton(
          onPressed: () {
            con.createVendedores();
          },
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15)
          ),
          child: Text (
            'GUARDAR',
            style: TextStyle(
              color: Colors.white,
            ),
          )
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
              Icon(Icons.support_agent_sharp, size: 120),
              Text(
                'NUEVO VENDEDOR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28
                ),
              ),
            ],
          ),
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

