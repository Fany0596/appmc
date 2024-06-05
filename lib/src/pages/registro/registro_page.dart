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
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Stack( // posiciona elementos uno sobre otro
  //       children: [
  //         _backGroundCover(context),
  //         _boxForm(context),
  //         _buttonBack(),
  //         _imageUser(context),
  //       ],
  //     ),
  //   );
  // }
  // boton de regreso
  // Widget _buttonBack() {
  //   return SafeArea( // deja espacio de la barra del telefono
  //     child: Container(
  //       margin: EdgeInsets.only(left: 20),
  //       child: IconButton(
  //           onPressed: () => Get.back(),
  //           icon: Icon(
  //             Icons.arrow_back_ios,
  //             color: Colors.white,
  //             size: 30,
  //           )
  //       ),
  //     ),
  //   );
  // }
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
  // // caja de datos
  // Widget _boxForm(BuildContext context) {
  //   return Container(
  //     height: MediaQuery.of(context).size.height*0.55,
  //     margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.35, left: 50, right: 40),
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         boxShadow: <BoxShadow>[
  //           BoxShadow(
  //               color: Colors.black54,
  //               blurRadius: 15,
  //               offset: Offset (0,0.085)
  //           )
  //         ]
  //     ),
  //     child: SingleChildScrollView(
  //       child: Column(
  //         children: [
  //           _textYourInfo(),
  //           _textFielName(),
  //           _textFielLastName(),
  //           _textFielUser(),
  //           _textFielPasword(),
  //           _textFielConfirmPasword(),
  //           _buttonRegistro(context),
  //
  //         ],
  //       ),
  //     ),
  //   );
  // }
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
  // // Texto nombre
  // Widget _textFielName() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //     child: TextField(
  //         controller: con.nameController,
  //         keyboardType: TextInputType.text,
  //         decoration: InputDecoration(
  //           hintText: 'Nombre', //texto fondo
  //           prefixIcon: Icon(Icons.perm_identity_outlined), //icono
  //         )
  //     ),
  //   );
  // }
  // // Texto apellido
  // Widget _textFielLastName() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //     child: TextField(
  //         controller: con.lastnameController,
  //         keyboardType: TextInputType.text,
  //         decoration: InputDecoration(
  //           hintText: 'Apellido', //texto fondo
  //           prefixIcon: Icon(Icons.perm_identity_sharp), //icono
  //         )
  //     ),
  //   );
  // }
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
  // // Texto usuario
  // Widget _textFielUser() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //     child: TextField(
  //         controller: con.emailController,
  //        keyboardType: TextInputType.emailAddress, //muestra el arroba en el teclado
  //         decoration: InputDecoration(
  //           hintText: 'Usuario', //texto fondo
  //           prefixIcon: Icon(Icons.perm_identity_outlined), //icono
  //         )
  //     ),
  //   );
  // }
  // // texto contraseña
  // Widget _textFielPasword() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //     child: TextField(
  //       controller: con.passwordController,
  //       keyboardType: TextInputType.text,
  //       obscureText: true, // coloca puntos al ingresar texto, como contraseña
  //       decoration: InputDecoration(
  //           hintText: 'Contraseña', //texto fondo
  //           prefixIcon: Icon(Icons.lock_outline) //icono
  //       ),
  //     ),
  //   );
  // }
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
  // // confirmar contraseña
  // Widget _textFielConfirmPasword() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //     child: TextField(
  //       controller: con.confirmPasswordController,
  //       keyboardType: TextInputType.text,
  //       obscureText: true, // coloca puntos al ingresar texto, como contraseña
  //       decoration: InputDecoration(
  //           hintText: 'Confirmar contraseña', //texto fondo
  //           prefixIcon: Icon(Icons.lock_outline) //icono
  //       ),
  //     ),
  //   );
  // }
  // boton registo
  // Widget _buttonRegistro(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
  //     child: ElevatedButton(
  //         onPressed: () => con.register(context),
  //         style: ElevatedButton.styleFrom(
  //             padding: EdgeInsets.symmetric(vertical: 15)
  //         ),
  //         child: Text (
  //           'REGISTRAR',
  //           style: TextStyle(
  //             color: Colors.white,
  //           ),
  //         )
  //     ),
  //   );
  // }
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
  // Widget _imageUser(BuildContext context) {
  //   return Container(
  //     alignment: Alignment.topCenter,
  //     margin: EdgeInsets.only(top: 40),
  //     child: GestureDetector(
  //       onTap: () => con.showAlertDialog(context),
  //       child: CircleAvatar(
  //         backgroundImage: con.imageFile != null
  //             ? FileImage(con.imageFile!)
  //             : AssetImage('assets/img/user.png') as ImageProvider,
  //         radius: 100,
  //         backgroundColor: Colors.transparent,
  //       ),
  //     ),
  //   );
  // }
}

// // imagen logo
//   Widget _imageUser(BuildContext context){
//     return SafeArea(
//       child: Container(
//         alignment: Alignment.topCenter,
//         margin: EdgeInsets.only(top:40),
//         child: GestureDetector(
//           onTap:() => con.showAlertDialog(context),
//           child: GetBuilder<RegisterController> (// ejecuta los cambio dede este punto
//             builder: (value) => CircleAvatar(
//               backgroundImage: con.imageFile != null
//                 ? FileImage(con.imageFile!)
//                 : AssetImage('assets/img/user.png') as ImageProvider,
//               radius: 100,
//               backgroundColor: Colors.transparent,
//           ),
//         ),
//       ),
//       )
//     );
//
//   }
// }
