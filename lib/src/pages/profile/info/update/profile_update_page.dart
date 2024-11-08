import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:maquinados_correa/src/pages/profile/info/update/profile_update_controller.dart';

class ProfileUpdatePage extends StatelessWidget {

  ProfileUpdateController con = Get.put(ProfileUpdateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack( // posiciona elementos uno sobre otro
        children: [
          _backGroundCover(context),
          _boxForm(context),
          _buttonBack(),
          _imageUser(context),
          _encabezado(context),
        ],
      ),
    );
  }
  // boton de regreso
  Widget _buttonBack() {
    return SafeArea( // deja espacio de la barra del telefono
      child: Container(
        margin: EdgeInsets.only(left: 20, top: 110),
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
      height: MediaQuery.of(context).size.height*0.45,
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
            _textYourInfo(),
            _textFielName(),
            _textFielLastName(),
            _buttonUpdate(context)



          ],
        ),
      ),
    );
  }

  // Texto ingrese datos
  Widget _textYourInfo() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: Text(
        'INGRESE DATOS',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
  // Texto nombre
  Widget _textFielName() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
          controller: con.nameController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Nombre', //texto fondo
            prefixIcon: Icon(Icons.person), //icono
          )
      ),
    );
  }
  // Texto apellido
  Widget _textFielLastName() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
          controller: con.lastnameController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Apellido', //texto fondo
            prefixIcon: Icon(Icons.perm_identity_sharp), //icono
          )
      ),
    );
  }

  // boton registo
  Widget _buttonUpdate(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ElevatedButton(
          onPressed: () => con.updateInfo(context),
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15)
          ),
          child: Text (
            'ACTUALIZAR',
            style: TextStyle(
              color: Colors.white,
            ),
          )
      ),
    );
  }
// imagen logo
  Widget _imageUser(BuildContext context){
    return SafeArea(
        child: Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.only(top:60),
          child: GestureDetector(
            onTap:() => con.showAlertDialog(context),
            child: GetBuilder<ProfileUpdateController> (// ejecuta los cambio dede este punto
              builder: (value) => CircleAvatar(
                backgroundImage: con.imageFile != null
                    ? FileImage(con.imageFile!)
                    : con.user.image != null
                    ? NetworkImage(con.user.image!)
                    : AssetImage('assets/img/user.png') as ImageProvider,
                radius: 100,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        )
    );

  }
  Widget _encabezado(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25),
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
  }

