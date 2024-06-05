import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/pages/login/login_controler.dart';


class LoginPage extends StatelessWidget {

  LoginController con = Get.put(LoginController()); // llama al controlador de boton registro

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack( // posiciona elementos uno sobre otro
        children: [
          _backGroundCover(context),
          _boxForm(context),
          //_imageCover(),
          Column( // coloca los elementos en columna uno sobre otro en vertical
            children: [
              _imageCover(),

           ],
          )
        ],
      ),
    );
  }

  Widget _backGroundCover(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Image.asset(
          'assets/img/fondo1.jpg',
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  // Widget _backGroundCover(BuildContext context){ //build context para porcentaje
  //   return SafeArea(
  //     child: Container(
  //       child: Image.asset(
  //         'assets/img/fondo1.jpg',
  //         width: MediaQuery.of(context).size.width *1,  //ancho de imagen
  //         height: MediaQuery.of(context).size.height *1, //alto de imagen
  //
  //       ),
  //     ),
  //   );
  // }
  // caja de formulario de inicio
  Widget _boxForm(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.38,
      margin: EdgeInsets.only(top: 320, left: 50, right: 50),
      //margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.31, left: 50, right: 50),
     // margin: EdgeInsets.symmetric(horizontal: 50, vertical: 350),
      decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.white60,
                blurRadius: 15,
                offset: Offset (0,0.075)
            )
          ]
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            //_textYourInfo(),
            _textFielUser(),
            _textFielPassword(),
            _buttonLogin(),

          ],
        ),
      ),
    );
  }
  // Texto ingrese datos
  Widget _textYourInfo() {
    return Container(
      margin: EdgeInsets.only(top: 90, bottom: 30),
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
  // Texto usuario
  Widget _textFielUser() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: TextField(
          controller: con.emailController,
          keyboardType: TextInputType.emailAddress, //muestra el arroba en el teclado
          decoration: InputDecoration(
            hintText: 'Usuario', //texto fondo
            prefixIcon: Icon(Icons.perm_identity_outlined), //icono
          )
      ),
    );
  }
  // texto usuario
  Widget _textFielPassword() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: TextField(
        controller: con.passwordController,
        keyboardType: TextInputType.text,
        obscureText: true, // coloca puntos al ingresar texto, como contraseña
        decoration: InputDecoration(
            hintText: 'Contraseña', //texto fondo
            prefixIcon: Icon(Icons.lock_outline) //icono
        ),
      ),
    );
  }
  // boton Login
  Widget _buttonLogin() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ElevatedButton(
          onPressed: () => con.login(),
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15)
          ),
          child: Text (
            'LOGIN',
            style: TextStyle(
              color: Colors.white,
            ),
          )
      ),
    );
  }


// imagen logo
  Widget _imageCover(){
    return Container(
      margin: EdgeInsets.only(top:70),
      alignment: Alignment.center,
      child: Image.asset(
        'assets/img/LOGO1.png',
        width: 280, //ancho de imagen
        height: 280, //alto de imagen
      ),
    );
  }
}
