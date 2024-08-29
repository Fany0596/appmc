import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/pages/registro/registro_controler.dart';


class  RegisterPage extends StatelessWidget {
  RegisterController con = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                _backGroundCover(context),
                _imageUser(context),
                _buttonBack(),
              ],
            ),
            _boxForm(context),
          ],
        ),
      ),
    );
  }
  Widget _buttonBack() {
    return Positioned(
      top: 20,
      left: 20,
      child: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 30,
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
  Widget _boxForm(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _textYourInfo(),
          _textFielName(),
          _textFielLastName(),
          _textFielUser(),
          _textFielPasword(),
          _textFielConfirmPasword(),
          _buttonRegistro(context),
        ],
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
        textAlign: TextAlign.center,
      ),
    );
  }
  Widget _textFielName() {
    return TextField(
      controller: con.nameController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Nombre',
        prefixIcon: Icon(Icons.person_outline),
      ),
    );
  }

  Widget _textFielLastName() {
    return TextField(
      controller: con.lastnameController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Apellido',
        prefixIcon: Icon(Icons.person_outline),
      ),
    );
  }
  Widget _textFielUser() {
    return TextField(
      controller: con.emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Usuario',
        prefixIcon: Icon(Icons.email_outlined),
      ),
    );
  }

  Widget _textFielPasword() {
    return TextField(
      controller: con.passwordController,
      keyboardType: TextInputType.text,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Contraseña',
        prefixIcon: Icon(Icons.lock_outline),
      ),
    );
  }
  Widget _textFielConfirmPasword() {
    return TextField(
      controller: con.confirmPasswordController,
      keyboardType: TextInputType.text,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Confirmar contraseña',
        prefixIcon: Icon(Icons.lock_outline),
      ),
    );
  }

  Widget _buttonRegistro(BuildContext context) {
    return ElevatedButton(
      onPressed: () => con.register(context),
      child: Text('REGISTRAR'),
    );
  }
  Widget _imageUser(BuildContext context){
    return SafeArea(
        child: Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.only(top:60),
          child: GestureDetector(
            onTap:() => con.showAlertDialog(context),
            child: GetBuilder<RegisterController> (// ejecuta los cambio dede este punto
              builder: (value) => CircleAvatar(
                backgroundImage: con.imageFile != null
                    ? FileImage(con.imageFile!)
                    //: con.user.image != null
                    //? NetworkImage(con.user.image!)
                    : AssetImage('assets/img/user.png') as ImageProvider,
                radius: 100,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        )
    );

  }
}
